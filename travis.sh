#!/usr/bin/env bash
# Exit on errors
set -e

echo "Testing nyxx package..."
cd nyxx/
pub get

echo "---------------------"

if [ "$DISCORD_TOKEN" ]; then
    dart --enable-experiment=non-nullable --no-null-safety --enable-asserts test/travis.dart
else
  echo "Discord token not present, skipping main lib tests"
fi

echo "Testing nyxx.commander package..."
cd ../nyxx.commander/
pub get

echo "---------------------"

if [ "$DISCORD_TOKEN" ]; then
    dart --enable-experiment=non-nullable --no-null-safety --enable-asserts test/commander-test.dart
else
  echo "Discord token not present, skipping commander tests"
fi

echo "Testing nyxx.extensions package..."
cd ../nyxx.extensions/
pub get

echo "---------------------"

dart --enable-experiment=non-nullable --no-null-safety --enable-asserts test/extensions-tests.dart