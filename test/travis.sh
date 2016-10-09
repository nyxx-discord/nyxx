# Exit on errors
set -e

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency
echo "Checking dartfmt..."
NEEDS_DARTFMT="$(find example lib test -name "*.dart" | xargs pub run dart_style:format -n)"
if [[ ${NEEDS_DARTFMT} != "" ]]
then
  echo "FAILED"
  echo "${NEEDS_DARTFMT}"
  exit 1
fi
echo "PASSED"

# Lazy newlines
echo ""

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
FAILS_ANALYZER="$(find example lib test -name "Client.dart" | xargs dartanalyzer --options analysis_options.yaml)"
if [[ $FAILS_ANALYZER == *"[error]"* ]]
then
  echo "FAILED"
  echo "${FAILS_ANALYZER}"
  exit 1
fi
echo "PASSED"

# Lazy newlines
echo ""

# Lazy newlines
echo ""

if [ "$DISCORD_TOKEN" ]; then
  dart -c test/discord.dart
else
  echo "Discord token not present, skipping Discord tests"
fi
