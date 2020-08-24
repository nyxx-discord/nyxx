#!/bin/bash

# Copy readme
cp README.md nyxx/README.md
cp README.md nyxx.commander/README.md
cp README.md nyxx.extensions/README.md

# Copy changelog
cp CHANGELOG.md nyxx/CHANGELOG.md
cp CHANGELOG.md nyxx.commander/CHANGELOG.md
cp CHANGELOG.md nyxx.extensions/CHANGELOG.md

echo "Publish nyxx"
cd nyxx || exit; pub publish;

echo "Publish nyxx"
cd ../nyxx.commander || exit; pub publish;

echo "Publish nyxx"
cd ../nyxx.extensions || exit; pub publish;
