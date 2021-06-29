## 2.0.0-rc.1

- Added `TrackStuck` and `TrackException` events.
- Removed `type` property from `TrackEndEvent`
- Changed `position` property from `PlayerUpdateStateEvent` type to `int?` to avoid deserializing errors when using Andesite instead of Lavalink