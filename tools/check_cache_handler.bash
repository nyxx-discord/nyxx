#!/usr/bin/env bash
set -euo pipefail

find lib/src/models/gateway/events -type f -name '*.dart' -exec grep -nPo '(?<=class )[A-Z]\w+(?= extends DispatchEvent)' {} + | while IFS=: read -r file line class; do
    if ! grep -q "$class" lib/src/utils/cache_helpers.dart; then
        echo "$file:$line: $class"
    fi
done
