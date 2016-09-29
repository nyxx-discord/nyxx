# Exit on errors
set -e

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency
echo "Checking dartfmt..."
NEEDS_DARTFMT="$(find bin lib test -name "*.dart" | xargs pub run dart_style:format -n)"
if [[ ${NEEDS_DARTFMT} != "" ]]
then
  echo "FAILED"
  echo "${NEEDS_DARTFMT}"
  exit 1
fi
echo "PASSED"

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
FAILS_ANALYZER="$(find bin lib test -name "*.dart" | xargs dartanalyzer --options analysis_options.yaml)"
if [[ $FAILS_ANALYZER == *"[error]"* ]]
then
  echo "FAILED"
  echo "${FAILS_ANALYZER}"
  exit 1
fi
echo "PASSED"

# 2nd check for errors and bad practices.
dartanalyzer --fatal-warnings --fatal-hints --fatal-lints  lib/

if [ "$DISCORD_TOKEN" ]; then
  timeout 60 dart -c test/discord.dart
else
  echo "Discord token not present, skipping Discord tests"
fi
