## 2.0.0
_03.10.2021_

> Bumped version to 2.0 for compatibility with nyxx

- Initial implementation (covers 100% of lavalink API)

## 2.0.0-rc.1

- Added `TrackStuck` and `TrackException` events.
- Removed `type` property from `TrackEndEvent`
- Changed `position` property from `PlayerUpdateStateEvent` type to `int?` to avoid deserializing errors when using Andesite instead of Lavalink
- Updated `Exception` model
