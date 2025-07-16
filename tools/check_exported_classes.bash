#!/usr/bin/env bash
set -euo pipefail

find lib -type f -name '*.dart' -exec grep -nPo '(?<=class )[A-Z]\w+' {} + | while IFS=: read -r file line class; do
    if ! grep -q "$class" lib/nyxx.dart; then
        echo "$file:$line: $class"
    fi
done
