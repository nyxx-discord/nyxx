export 'dart:ffi';
import 'dart:io';

/// The name of the zstd library on the current platform.
final zstdLibraryName = Platform.isWindows
    ? 'zstd.dll'
    : Platform.isMacOS
        ? 'libzstd.dylib'
        : 'libzstd.so';
