#!/usr/bin/env bash
set -euo pipefail

echo "Checking for unexported classes...."

find lib -type f -name '*.dart' -exec grep -nPo '(?<=class )[A-Z]\w+' {} + | while IFS=: read -r file line class; do
    if ! grep -q "$class" lib/nyxx.dart; then
        echo "$file:$line: $class"
    fi
done

echo
echo "Checking for Gateway events not handled by updateCacheWith..."

find lib/src/models/gateway/events -type f -name '*.dart' -exec grep -nPo '(?<=class )[A-Z]\w+(?= extends DispatchEvent)' {} + | while IFS=: read -r file line class; do
    if ! grep -q "$class" lib/src/utils/cache_helpers.dart; then
        echo "$file:$line: $class"
    fi
done

echo
echo "Checking for Gateway events without a corresponding stream in EventMixin..."

find lib/src/models/gateway/events -type f -name '*.dart' -exec grep -nPo '(?<=class )[A-Z]\w+(?= extends DispatchEvent)' {} + | while IFS=: read -r file line class; do
    if ! grep -q "$class" lib/src/event_mixin.dart; then
        echo "$file:$line: $class"
    fi
done
