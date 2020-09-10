#!/bin/bash

# Copy readme
cp README.md nyxx/README.md
cp README.md nyxx.commander/README.md
cp README.md nyxx.extensions/README.md

echo "Publish nyxx"
cd nyxx || exit; pub publish;

echo "Publish nyxx"
cd ../nyxx.commander || exit; pub publish;

echo "Publish nyxx"
cd ../nyxx.extensions || exit; pub publish;
