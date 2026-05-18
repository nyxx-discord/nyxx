import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:nyxx/src/api_options.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/ffi_real.dart';
import 'package:zstd_ffi/_zstd.dart';

Stream<dynamic> decompressZStdTransport(Stream<List<int>> raw) {
  final library = DynamicLibrary.open(zstdLibraryName);
  final zstd = ZStd(library);

  final inputSize = zstd.ZSTD_DStreamInSize();
  final inputPtr = malloc<ZSTD_inBuffer>();
  inputPtr.ref.src = malloc<Uint8>(inputSize).cast<Void>();

  final outputSize = zstd.ZSTD_DStreamOutSize();
  final outputPtr = malloc<ZSTD_outBuffer>();
  outputPtr.ref.dst = malloc<Uint8>(outputSize).cast<Void>();
  outputPtr.ref.size = outputSize;

  final dctx = zstd.ZSTD_createDCtx();
  if (dctx == nullptr) {
    malloc.free(inputPtr.ref.src);
    malloc.free(inputPtr);
    malloc.free(outputPtr.ref.dst);
    malloc.free(outputPtr);

    throw NyxxException('Unable to initialise Zstd dctx');
  }
  zstd.ZSTD_initDStream(dctx);

  var lastRet = 0;

  return raw.transform(StreamTransformer.fromHandlers(
    handleData: (chunk, output) {
      if (chunk is! Uint8List) {
        chunk = Uint8List.fromList(chunk);
      }

      final result = BytesBuilder(copy: true);

      for (int i = 0; i * inputSize < chunk.length; i++) {
        final currentSlice = Uint8List.sublistView(chunk, i * inputSize, min(i * inputSize + inputSize, chunk.length));
        inputPtr.ref
          ..src.cast<Uint8>().asTypedList(inputSize).setAll(0, currentSlice)
          ..size = currentSlice.length
          ..pos = 0;

        while (inputPtr.ref.pos < inputPtr.ref.size) {
          outputPtr.ref.pos = 0;

          lastRet = zstd.ZSTD_decompressStream(dctx, outputPtr, inputPtr);
          if (zstd.ZSTD_isError(lastRet) != 0) {
            throw NyxxException('Error decoding zstd stream: $lastRet');
          }

          // Copy contents out of buffer that will be reused.
          result.add(outputPtr.ref.dst.cast<Uint8>().asTypedList(outputPtr.ref.pos));
        }
      }

      output.add(result.takeBytes());
    },
    handleDone: (output) {
      zstd.ZSTD_freeDCtx(dctx);
      malloc.free(inputPtr.ref.src);
      malloc.free(inputPtr);
      malloc.free(outputPtr.ref.dst);
      malloc.free(outputPtr);
      output.close();
    },
  ));
}
