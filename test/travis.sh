# Install the linter
pub global activate linter

# Check code for errors
pub global run linter lib/

if [ "$DISCORD_TOKEN" ]; then
  timeout 60 dart test/discord.dart
else
  echo "Discord token not present, skipping Discord tests"
fi
