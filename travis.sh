#!/usr/bin/env bash
# Exit on errors
set -e

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency

echo "Testing nyxx package..."
cd nyxx/
pub get

# Lazy newlines
echo ""

if [ "$DISCORD_TOKEN" ]; then
    dart --enable-experiment=non-nullable --no-null-safety test/travis.dart
else
  echo "Discord token not present, skipping Discord tests"
fi

echo "Testing nyxx.commander package..."
cd ../nyxx.commander/
pub get

# Lazy newlines
echo ""

if [ "$DISCORD_TOKEN" ]; then
    dart --enable-experiment=non-nullable --no-null-safety test/commander-test.dart
else
  echo "Discord token not present, skipping Discord tests"
fi

echo "Testing nyxx.extensions package..."
cd ../nyxx.extensions/
pub get

# Lazy newlines
echo ""

if [ "$DISCORD_TOKEN" ]; then
    dart --enable-experiment=non-nullable --no-null-safety test/extensions-tests.dart
else
  echo "Discord token not present, skipping Discord tests"
fi