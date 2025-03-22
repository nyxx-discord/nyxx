## 6.6.1
__22.03.2025__

- feat: Properly handle unknown union types.

## 6.6.0
__23.02.2025__

- feat Make `SoundboardSound` have a CDN asset ([`#740`](https://github.com/nyxx-discord/nyxx/pull/740)) - ([`a8650288`](https://github.com/nyxx-discord/nyxx/commit/a8650288))
- feat: Add new connections services ([`#735`](https://github.com/nyxx-discord/nyxx/pull/735)) - ([`afe90236`](https://github.com/nyxx-discord/nyxx/commit/afe90236))
- feat: Add `has_snapshot` message flag ([`#734`](https://github.com/nyxx-discord/nyxx/pull/734)) - ([`385a9667`](https://github.com/nyxx-discord/nyxx/commit/385a9667))
- feat: Add `withComponents` param on webhooks ([`#738`](https://github.com/nyxx-discord/nyxx/pull/738)) - ([`2b8f229c`](https://github.com/nyxx-discord/nyxx/commit/2b8f229c))
- feat: Add incidents data ([`#737`](https://github.com/nyxx-discord/nyxx/pull/737)) - ([`538935b7`](https://github.com/nyxx-discord/nyxx/commit/538935b7))
- chore: Unclutter the pull request template ([`#732`](https://github.com/nyxx-discord/nyxx/pull/732)) - ([`7dc8bae1`](https://github.com/nyxx-discord/nyxx/commit/7dc8bae1))
- fix: Fix the readme example ([`#731`](https://github.com/nyxx-discord/nyxx/pull/731)) - ([`e2ab8081`](https://github.com/nyxx-discord/nyxx/commit/e2ab8081))
- fix: Fix legacy accounts default avatar ([`06d2aee4`](https://github.com/nyxx-discord/nyxx/commit/06d2aee4))

## 6.5.2
__02.11.2024__

- hotfix: Handle `null` member banner ([`#729`](https://github.com/nyxx-discord/nyxx/pull/729)) - ([`7f837e4`](https://github.com/nyxx-discord/nyxx/commit/7f837e492a3c2c25c5f34a6c52d4145caabd3b64))

## 6.5.1
__02.11.2024__

- maintenance: Update github actions ([`#723`](https://github.com/nyxx-discord/nyxx/pull/723)) - ([`5d60dcc3`](https://github.com/nyxx-discord/nyxx/commit/5d60dcc35b26edadfa22f7919df74ece448f85ce))
- bug: Properly expose soundboard ([`#727`](https://github.com/nyxx-discord/nyxx/pull/727)) - ([`f8be20f1`](https://github.com/nyxx-discord/nyxx/commit/f8be20f1c90a2bd52c149fb36b68515d69b44565))
- bug: Fix missing imports ([`#728`](https://github.com/nyxx-discord/nyxx/pull/728)) - ([`8ba1f41a`](https://github.com/nyxx-discord/nyxx/commit/8ba1f41a00106d0dc470f6ad1e098a3564908875))
- docs: More docs and typos ([`#724`](https://github.com/nyxx-discord/nyxx/pull/724)) - ([`b3c242bd`](https://github.com/nyxx-discord/nyxx/commit/b3c242bd86c9bbf0a3cb285741070349bb848380))
- bug: Move logging when connecting ([`#726`](https://github.com/nyxx-discord/nyxx/pull/726)) - ([`3cd8c773`](https://github.com/nyxx-discord/nyxx/commit/3cd8c773d774bd957d7517fa817146045678c4ea))

## 6.5.0
__22.10.2024__

- feature: Add new member flags. ([`#715`](https://github.com/nyxx-discord/nyxx/pull/715)) - ([`e10d0ffb`](https://github.com/nyxx-discord/nyxx/commit/e10d0ffb680e28ed74397875bb6a0a4b2fa411f7))
- feature: Add new fields on message snapshot. ([`#716`](https://github.com/nyxx-discord/nyxx/pull/716)) - ([`57dc3282`](https://github.com/nyxx-discord/nyxx/commit/57dc32826081d60ec4fd905c939b15afe7dc7abe))
- bug: Fix serialization of `before` parameter. ([`#717`](https://github.com/nyxx-discord/nyxx/pull/717)) - ([`091c376f`](https://github.com/nyxx-discord/nyxx/commit/091c376fe80456d18e046ea047072d0271bb4384))
- feature: Recurrence rule can be set to null when updating. ([`#720`](https://github.com/nyxx-discord/nyxx/pull/720)) - ([`aaef80ac`](https://github.com/nyxx-discord/nyxx/commit/aaef80ac469331fa2da06eb776e2708813268b07))
- feature: Add support for soundboard. ([`#708`](https://github.com/nyxx-discord/nyxx/pull/708)) - ([`d93aa122`](https://github.com/nyxx-discord/nyxx/commit/d93aa122965b6d9b11f51dac377ee3c13eefac97))
- feature: Allow polls to be constructed in a interation response. ([`#719`](https://github.com/nyxx-discord/nyxx/pull/719)) - ([`db27c54d`](https://github.com/nyxx-discord/nyxx/commit/db27c54d24be1bb4010457041b7b4d09063e701d))
- feature: Add banner property to member. ([`#676`](https://github.com/nyxx-discord/nyxx/pull/676)) - ([`4041b556`](https://github.com/nyxx-discord/nyxx/commit/4041b5569853d8eac6f2a165a3cb03b736e02cef))
- feature: Fix user avatar decoration, add member avatar decoration. ([`#718`](https://github.com/nyxx-discord/nyxx/pull/718)) - ([`b8e5ba7c`](https://github.com/nyxx-discord/nyxx/commit/b8e5ba7c89dbabd72821b7cd603bdab88cf0e751))
- maintenance: Update integration_tests.yml. ([`527eed5a`](https://github.com/nyxx-discord/nyxx/commit/527eed5a90c83071f5346273426bd0fd20089a60))

## 6.4.3
__08.10.2024__

- bug: Handle missing `mention_roles` field in some message snapshots. ([`#709`](https://github.com/nyxx-discord/nyxx/pull/709)) - ([`d458d9c`](https://github.com/nyxx-discord/nyxx/commit/d458d9c82e621ca24044533cd2ce2d66c0a29186))

## 6.4.2
__05.10.2024__

- bug: Prevent caches from growing forever. ([`#704`](https://github.com/nyxx-discord/nyxx/pull/704)) - ([`c62c23c`](https://github.com/nyxx-discord/nyxx/commit/c62c23c1abe3aa01e970f137579ab9ddbe6f87da)) 

## 6.4.1
__04.10.2024__

- bug: Fix exports ([`d2312de`](https://github.com/nyxx-discord/nyxx/commit/d2312de445547c955a565fc13511cf55fa8bbf76))

## 6.4.0
__04.10.2024__

- feat: Add new permissions ([`#679`](https://github.com/nyxx-discord/nyxx/pull/679)) - ([`c91f050`](https://github.com/nyxx-discord/nyxx/commit/c91f05002d2735990b09296ca67b01359b2b3bf4))
- bug: Make webhook execute apply name/avatar when message doesn't contain any attachments ([`#681`](https://github.com/nyxx-discord/nyxx/pull/681)) - ([`cac408e`](https://github.com/nyxx-discord/nyxx/commit/cac408e0ba3870f7716ee64f938ef63d195ab6ce))
- bug: Add missing `approximateUserInstallCount` to `Application` ([`#683`](https://github.com/nyxx-discord/nyxx/pull/683)) - ([`3e2de40`](https://github.com/nyxx-discord/nyxx/commit/3e2de400d5adb67bc8bc8187198bb90b62a4130a))
- feat: Add missing audit log event types ([`#684`](https://github.com/nyxx-discord/nyxx/pull/684)) - ([`b1b6414`](https://github.com/nyxx-discord/nyxx/commit/b1b6414145cec7b4e4c20b4b199f7e2360290d22))
- feat: Add auditLogReason to followChannel ([`#685`](https://github.com/nyxx-discord/nyxx/pull/685)) - ([`8f7f629`](https://github.com/nyxx-discord/nyxx/commit/8f7f6295d075a6b244d9db33d720a9b324c9063e))
- feat: Add recurrence rules for scheduled events ([`#686`](https://github.com/nyxx-discord/nyxx/pull/686)) - ([`ffc0c08`](https://github.com/nyxx-discord/nyxx/commit/ffc0c08d561bff4aa549f656be8636da1bd8eab7))
- bug: Add missing fields to Message ([`#689`](https://github.com/nyxx-discord/nyxx/pull/689)) - ([`8a469c4`](https://github.com/nyxx-discord/nyxx/commit/8a469c4cb6874c867396dd307271e9379c997377))
- feat: Add type field to Invite ([`#688`](https://github.com/nyxx-discord/nyxx/pull/688)) - ([`e38dbf8`](https://github.com/nyxx-discord/nyxx/commit/e38dbf80b580a165a9a9750fd5c90f2759531678))
- bug: Delete any commands left over in tests ([`#693`](https://github.com/nyxx-discord/nyxx/pull/693)) - ([`7022767`](https://github.com/nyxx-discord/nyxx/commit/7022767bb317ce3bf7cf5eaa44b8e332880f2406))
- feat: Add fetch voice state endpoints ([`#692`](https://github.com/nyxx-discord/nyxx/pull/692)) - ([`b91d782`](https://github.com/nyxx-discord/nyxx/commit/b91d782ea4c10c296e15a6531d6c9c114f5d2a3e))
- feat: Add support for subscriptions ([`#690`](https://github.com/nyxx-discord/nyxx/pull/690)) - ([`8e50682`](https://github.com/nyxx-discord/nyxx/commit/8e50682d752ce0a3576dc493e61d19fe18b354a8))
- feat: Add update onboarding endpoint to GuildManager ([`#687`](https://github.com/nyxx-discord/nyxx/pull/687)) - ([`002cdfc`](https://github.com/nyxx-discord/nyxx/commit/002cdfc53944eb3255d4c1d4173cbc6442fa6b0f))
- feat: Add application emojis ([`#678`](https://github.com/nyxx-discord/nyxx/pull/678)) - ([`56ec264`](https://github.com/nyxx-discord/nyxx/commit/56ec264f25e01edfda97663961b7c7f3afd6929d))
- feat: Improve cache implementation ([`#694`](https://github.com/nyxx-discord/nyxx/pull/694)) - ([`59c0b39`](https://github.com/nyxx-discord/nyxx/commit/59c0b399dfba170d1303040606d16e707b408420))
- bug: Don't modify Cache.keys during iteration ([`#698`](https://github.com/nyxx-discord/nyxx/pull/698)) - ([`8b4b451`](https://github.com/nyxx-discord/nyxx/commit/8b4b4514c6bc1a8612caa17d500b27e2e9ec2876))

## 6.3.1
__11.07.2024__

- bug: poll answer in message object throwing an error. ([`#673`](https://github.com/nyxx-discord/nyxx/pull/673)) - ([`0824294`](https://github.com/nyxx-discord/nyxx/commit/0824294b9d8c372cb93d2cc3c41d0db01be7df38)) 

## 6.3.0
__07.07.2024__

- feat: Add one time purchase SKUs support. ([`#651`](https://github.com/nyxx-discord/nyxx/pull/651)) - ([`b874066`](https://github.com/nyxx-discord/nyxx/commit/b87406632d664085e068920333644c087de20372))
- bug: Include query parameters in CDN requests. ([`#653`](https://github.com/nyxx-discord/nyxx/pull/653)) - ([`f2c33ce`](https://github.com/nyxx-discord/nyxx/commit/f2c33ce13d97b029de4ccc39ad5be0943de7c025)) 
- feat: Add warning logs for rate limits. ([`#654`](https://github.com/nyxx-discord/nyxx/pull/654)) - ([`976d290`](https://github.com/nyxx-discord/nyxx/commit/976d29038868e6f7b91b62652805e721c07694af)) 
- feat: Add `deleteMessages` parameter to `Member.ban`. ([`#656`](https://github.com/nyxx-discord/nyxx/pull/656)) - ([`55c94c3`](https://github.com/nyxx-discord/nyxx/commit/55c94c33992acaa34f6f9612b4deb7d1c620e074)) 
- bug: Ensure `client.close()` cleans up all pending operations. ([`#655`](https://github.com/nyxx-discord/nyxx/pull/655)) - ([`e8d9d5d`](https://github.com/nyxx-discord/nyxx/commit/e8d9d5d8c5cfd07ac005bb790186303a269855cd))
- feat: Add polls support. ([`#644`](https://github.com/nyxx-discord/nyxx/pull/644)) - ([`7908853`](https://github.com/nyxx-discord/nyxx/commit/7908853845a4051b02da2ebc4bd092f8f6bba136))
- bug: Allow non-ascii characters in audit log reasons. ([`#659`](https://github.com/nyxx-discord/nyxx/pull/659)) - ([`27b74b5`](https://github.com/nyxx-discord/nyxx/commit/27b74b5d8c3ec197badf53817d2343546f71d0a0))
- feat: Add `memberUpdate` automod type. ([`#662`](https://github.com/nyxx-discord/nyxx/pull/662)) - ([`a502121`](https://github.com/nyxx-discord/nyxx/commit/a50212110d54e283accaac43e9a3d7a906410b2d))
- feat: Add `blockMemberInteraction` automod action type. ([`#664`](https://github.com/nyxx-discord/nyxx/pull/664)) - ([`50f3377`](https://github.com/nyxx-discord/nyxx/commit/50f3377d9a224687e69c7377111779c862f76ad5))
- feat: Add support for premium buttons. ([`#690`](https://github.com/nyxx-discord/nyxx/pull/690)) - ([`8e50682`](https://github.com/nyxx-discord/nyxx/commit/8e50682d752ce0a3576dc493e61d19fe18b354a8))
- bug: Allow parsing unknown enum values. ([`#655`](https://github.com/nyxx-discord/nyxx/pull/665)) - ([`0a212fd`](https://github.com/nyxx-discord/nyxx/commit/0a212fd94a92423f8e969c298a7e9db5061ad7af)) 
- bug: Fix parsing of message interaction metadata user. ([`#688`](https://github.com/nyxx-discord/nyxx/pull/688)) - ([`9eb5569`](https://github.com/nyxx-discord/nyxx/commit/9eb5569d4fb0580e0aee9dfd2798492f9dbdce95))


## 6.2.1
__03.04.2024__

- bug: Fix parsing integration types when they are not present. ([`#647`](https://github.com/nyxx-discord/nyxx/pull/647)) - ([`89068e7`](https://github.com/nyxx-discord/nyxx/commit/89068e7c2666089c8873daa8863aa41b55a6a0d4))

## 6.2.0
__20.03.2024__

- feat: Add support for Group DM endpoints when using an OAuth client. ([`#600`](https://github.com/nyxx-discord/nyxx/pull/600)) - ([`6ed9657`](https://github.com/nyxx-discord/nyxx/commit/6ed96579dea4ebe32f9aae1dbe846f2bcd4c0cc4))
- feat: Add support for `username` and `avatarUrl` parameters for webhooks. ([`#611`](https://github.com/nyxx-discord/nyxx/pull/611)) - ([`982e0d9`](https://github.com/nyxx-discord/nyxx/commit/982e0d9d2c718c54213dee5c37da4c907f6f1ff7))
- feat: Add `Spanish, LATAM` locale. ([`#610`](https://github.com/nyxx-discord/nyxx/pull/610)) - ([`896004a`](https://github.com/nyxx-discord/nyxx/commit/896004a498d9c2afb6f0f6185ffe1cd5270e0774))
- bug: Fix events being dropped when plugins had async initialization. ([`#612`](https://github.com/nyxx-discord/nyxx/pull/612)) - ([`bb54de1`](https://github.com/nyxx-discord/nyxx/commit/bb54de16257cdf2382976beb755f621f433e356a))
- bug: Return an empty list instead of throwing when fetching the permission overrides of a command that has none. ([`#613`](https://github.com/nyxx-discord/nyxx/pull/613)) - ([`1a4ed82`](https://github.com/nyxx-discord/nyxx/commit/1a4ed8294a244e1a5fe1212f2b41da05c41e4f58))
- feat: Add ratelimits when sending Gateway events. ([`#614`](https://github.com/nyxx-discord/nyxx/pull/614)) - ([`f6ef61b`](https://github.com/nyxx-discord/nyxx/commit/f6ef61bd9f467ba1f7df8d495514464081c0da02))
- bug: Allow any `Flags<Permissions>` in `RoleUpdateBuilder.permissions`. ([`#617`](https://github.com/nyxx-discord/nyxx/pull/617)) - ([`4c7f7fa`](https://github.com/nyxx-discord/nyxx/commit/4c7f7fa6beebc68b10494b7a5d11c85b73240483)) 
- bug: Export types that were previously kept private. ([`#616`])(https://github.com/nyxx-discord/nyxx/pull/616) - ([`a1b2bc6`](https://github.com/nyxx-discord/nyxx/commit/a1b2bc68529b8b646e9f75d0b5ae202bb5604332)) 
- feat: Allow plugins to intercept HTTP requests and Gateway events. ([`#615`](https://github.com/nyxx-discord/nyxx/pull/615)) - ([`ff92f86`](https://github.com/nyxx-discord/nyxx/commit/ff92f86258fa02f6c2a0cf6863523c70924f1fe2))
- bug: Fix `MessageManager.bulkDelete` not serializing the request correctly. ([`#618`](https://github.com/nyxx-discord/nyxx/pull/618)) - ([`797579b`](https://github.com/nyxx-discord/nyxx/commit/797579b7bfd9128386e3cf4e66ac3dc62f948cff)) 
- bug: Fix `GuildDeleteEvent`s not being parsed when `unavailable` was not explicitly set. ([`#619`](https://github.com/nyxx-discord/nyxx/pull/619)) - ([`7ea4070`](https://github.com/nyxx-discord/nyxx/commit/7ea4070d0792dfc7d688eb1fa0a8a20583258f98)) 
- bug: Correct serialization of guild builders. ([`#621`](https://github.com/nyxx-discord/nyxx/pull/621)) - ([`d9593c5`](https://github.com/nyxx-discord/nyxx/commit/d9593c57488285f7b6bb0ad15b6ea3b4db288ed3))
- bug: Correct value of `TriggerType.spam`. ([`#623`](https://github.com/nyxx-discord/nyxx/pull/623)) - ([`463cda9`](https://github.com/nyxx-discord/nyxx/commit/463cda91ed98197b06fd125487722f43fa6a7d35))
- docs: Hide constructors from documentation. ([`#624`](https://github.com/nyxx-discord/nyxx/pull/624)) - ([`3e0ecdf`](https://github.com/nyxx-discord/nyxx/commit/3e0ecdfe4b92ab1ad1639e824973565f50b9e35c))
- bug: Fix parsing role flags in guild templates. ([`#625`](https://github.com/nyxx-discord/nyxx/pull/625)) - ([`495b88f`](https://github.com/nyxx-discord/nyxx/commit/495b88fc03688b84a2b30eb81b5bc0382b943acd)) 
- bug: Fix `isHoisted` attribute in role builders. ([`#627`](https://github.com/nyxx-discord/nyxx/pull/627)) - ([`bb62547`](https://github.com/nyxx-discord/nyxx/commit/bb6254780068aa121c063096f74f0648aa220155))
- bug: Fix all audit log parameters in `StickerManager`, `EmojiManager` and `WebhookManager.update` ([`#628`](https://github.com/nyxx-discord/nyxx/pull/628)) - ([`4ece7f7`](https://github.com/nyxx-discord/nyxx/commit/4ece7f763b80a95816219a9ca09ec45780c266af))
- bug: Fix `interactionsEndpointUrl` being ignored in `ApplicationUpdateBuilder` ([`#628`](https://github.com/nyxx-discord/nyxx/pull/628)) - ([`4ece7f7`](https://github.com/nyxx-discord/nyxx/commit/4ece7f763b80a95816219a9ca09ec45780c266af))
- feat: Add more shortcut methods on models. ([`#628`](https://github.com/nyxx-discord/nyxx/pull/628)) - ([`4ece7f7`](https://github.com/nyxx-discord/nyxx/commit/4ece7f763b80a95816219a9ca09ec45780c266af))
- feat: Add `enforceNonce` to `MessageBuilder`. ([`#631`](https://github.com/nyxx-discord/nyxx/pull/631)) - ([`7407767`](https://github.com/nyxx-discord/nyxx/commit/7407767cd58601103e69397b31043aa5f52e3ef2)) 
- feat: Add missing role tags fields. ([`#632`](https://github.com/nyxx-discord/nyxx/pull/632)) - ([`0deacf8`](https://github.com/nyxx-discord/nyxx/commit/0deacf842177d7e45990828facff4eaa792fe182))
- bug: Correct the default `User-Agent` header. ([`#633`](https://github.com/nyxx-discord/nyxx/pull/633)) - ([`a1d89ca`](https://github.com/nyxx-discord/nyxx/commit/a1d89cad765e965a641ed18dbe7465a88b34d352)) 
- bug: Don't require OAuth2 identify scope when using `NyxxOauth2`. ([`#634`](https://github.com/nyxx-discord/nyxx/pull/634)) - ([`408fe03`](https://github.com/nyxx-discord/nyxx/commit/408fe03e998cbf8d17df68b482502c164cfcbefd))
- feat: Add field to delete events containing the cached entity before it was deleted. ([`#635`](https://github.com/nyxx-discord/nyxx/pull/635)) - ([`1e8d5e5`](https://github.com/nyxx-discord/nyxx/commit/1e8d5e54f3356d144558f0c4114aad67a1aca41d))
- feat: Add builders for auto moderation actions. ([`#636`](https://github.com/nyxx-discord/nyxx/pull/636)) - ([`2e09030`](https://github.com/nyxx-discord/nyxx/commit/2e09030cdbb92c3c6b7222bf34b9c373f38dac44)) 
- bug: Initialize login sooner to avoid dropping logs. ([`#637`](https://github.com/nyxx-discord/nyxx/pull/637)) - ([`02ee8a6`](https://github.com/nyxx-discord/nyxx/commit/02ee8a670cdb5ae8b09156c4a2149487f4aa8304))
- feat: Add `banner` to `UserUpdateBuilder`. ([`#638`](https://github.com/nyxx-discord/nyxx/pull/638)) - ([`42f7bef`](https://github.com/nyxx-discord/nyxx/commit/42f7bef041de3bab6ff432ecc70b63fca21a8621))
- feat: Add `SkuFlags.available`. ([`#638`](https://github.com/nyxx-discord/nyxx/pull/638)) - ([`42f7bef`](https://github.com/nyxx-discord/nyxx/commit/42f7bef041de3bab6ff432ecc70b63fca21a8621))
- feat: Add bungie, domain and roblox connection types. ([`#639`](https://github.com/nyxx-discord/nyxx/pull/639)) - ([`70c9d04`](https://github.com/nyxx-discord/nyxx/commit/70c9d044cf4f61fe312e8ba511f3578d94293c28))
- feat: Add support for user applications. ([`#641`](https://github.com/nyxx-discord/nyxx/pull/641)) - ([`10181ac`](https://github.com/nyxx-discord/nyxx/commit/10181ac7c3f3e3b71433cfa725e31aafcdd56cec))
- feat: Add `bulkBan` to `GuildManager`. ([`#640`](https://github.com/nyxx-discord/nyxx/pull/640)) - ([`6adc5ff`](https://github.com/nyxx-discord/nyxx/commit/6adc5ffbdf97ea0caacd58b32330b1f0347b4279))

## 6.1.0
__09.12.2023__

- feat: Add payload to `EntitlementDeleteEvent`. ([`#599`](https://github.com/nyxx-discord/nyxx/pull/599)) - ([`7a0f346`](https://github.com/nyxx-discord/nyxx/commit/7a0f346677b5c7a8edf7064db722087765864722))
- feat: Add `flags` field to `Sku`. ([`#602`](https://github.com/nyxx-discord/nyxx/pull/602)) - ([`74bf507`](https://github.com/nyxx-discord/nyxx/commit/74bf50762025d35ae8f9dc31379fe81e4e0036d0))
- feat: Add support for select menu default values. ([`#601`](https://github.com/nyxx-discord/nyxx/pull/601)) - ([`5a833f3`](https://github.com/nyxx-discord/nyxx/commit/5a833f3233763b7507c8526d74954db6e62877ac))
- feat: Add `GuildUpdateBuilder.safetyAlertsChannelId`. ([`#596`](https://github.com/nyxx-discord/nyxx/pull/596)) - ([`c1eab88`](https://github.com/nyxx-discord/nyxx/commit/c1eab8883ceb34c1ab0822fe40ea8377a8e5d7d7))
- docs: Enable link to source in package documentation. ([`#607`](https://github.com/nyxx-discord/nyxx/pull/607)) - ([`57ce193`](https://github.com/nyxx-discord/nyxx/commit/57ce193445f9b95304eb9771a9e44a165e423138))
- feat: Add AutoMod message types. ([`#597`](https://github.com/nyxx-discord/nyxx/pull/597)) - ([`3ba7e7e`](https://github.com/nyxx-discord/nyxx/commit/3ba7e7e71a39497863e8f43e7058939eaeb0a878))
- bug: Fix `ButtonBuilder` serialization. ([`#595`](https://github.com/nyxx-discord/nyxx/pull/595)) - ([`a81ee15`](https://github.com/nyxx-discord/nyxx/commit/a81ee15c7cd90c0970a1aa1ac0885d2b13624caf))
- bug: Fix `GuildUpdateBuilder` not being able to unset certain settings. ([`#596`](https://github.com/nyxx-discord/nyxx/pull/596)) - ([`c1eab88`](https://github.com/nyxx-discord/nyxx/commit/c1eab8883ceb34c1ab0822fe40ea8377a8e5d7d7))
- bug: Fix incorrect `PermissionOverwriteBuilder` serialization when creating/updating channels. ([`#596`](https://github.com/nyxx-discord/nyxx/pull/596)) - ([`c1eab88`](https://github.com/nyxx-discord/nyxx/commit/c1eab8883ceb34c1ab0822fe40ea8377a8e5d7d7))
- bug: Fix `GuildManager.listBans` ignoring the provided parameters. ([`#598`](https://github.com/nyxx-discord/nyxx/pull/598)) - ([`d04db1a`](https://github.com/nyxx-discord/nyxx/commit/d04db1ae240ff1f47764f585b95edd5f477c2ba5))
- bug: Correctly export `Credentials` from `package:oauth2` for OAuth2 support. ([`#604`](https://github.com/nyxx-discord/nyxx/pull/604)) - ([`f23cfd2`](https://github.com/nyxx-discord/nyxx/commit/f23cfd27b87560a4fe2da04d21c2be8bb46a3f06))
- bug: Fix members in message interactions not having their guild set. ([`#603`](https://github.com/nyxx-discord/nyxx/pull/603)) - ([`c12ba89`](https://github.com/nyxx-discord/nyxx/commit/c12ba8915f11845df869c981ee025aa12c5b750b))

## 6.0.3
__26.11.2023__

- bug: Fix incorrect serialization of autocompletion interaction responses (again). ([`#591`](https://github.com/nyxx-discord/nyxx/pull/591)) - ([`573c9bc`](https://github.com/nyxx-discord/nyxx/commit/573c9bc6046474b6dfc48c152d938f9bb3e8af1a))
- bug: Try to fix invalid sessions triggered by Gateway reconnects. ([`#592`](https://github.com/nyxx-discord/nyxx/pull/592)) - ([`46f128c`](https://github.com/nyxx-discord/nyxx/commit/46f128c9d165775ec1cee6d129238ee8ec8ae0d8))

## 6.0.2
__16.11.2023__

- bug: Fix incorrect assertions in interaction.respond. ([`#584`](https://github.com/nyxx-discord/nyxx/pull/584)) - ([`f7abb73`](https://github.com/nyxx-discord/nyxx/commit/f7abb730c501bd744a10cf79ff1b92c86be9e9ac))
- bug: Fix incorrect serialization of autocompletion interaction responses. ([`#585`](https://github.com/nyxx-discord/nyxx/pull/585)) - ([`55a8c76`](https://github.com/nyxx-discord/nyxx/commit/55a8c760b3a2cf0b481a3e7b941c9b9fe62cc359))

## 6.0.1
__01.11.2023__

- bug: Fix incorrect serialization of CommandOptionBuilder. ([`#571`](https://github.com/nyxx-discord/nyxx/pull/571)) - ([`9728833`](https://github.com/nyxx-discord/nyxx/commit/9728833a6c28dba05f0032430fae035d56d1bf17))
- bug: Fix customId missing from ButtonBuilder constructor. ([`#570`](https://github.com/nyxx-discord/nyxx/pull/570)) - ([`31ab26d`](https://github.com/nyxx-discord/nyxx/commit/31ab26d4eb1709bb36284029f29be6f13ec0b83b))
- bug: Fix voice states not being cached correctly. ([`#575`](https://github.com/nyxx-discord/nyxx/pull/575)) - ([`758648c`](https://github.com/nyxx-discord/nyxx/commit/758648cc0f0bb3c5741354437498208905e73843))
- bug: Fix incorrect parsing of scheduled events. ([`#576`](https://github.com/nyxx-discord/nyxx/pull/576)) - ([`a78b1f8`](https://github.com/nyxx-discord/nyxx/commit/a78b1f83899b185bb326e53b8c24cfd8872b1f82))
- bug: Fix `ephemeral` parameter not working when responding to message component interactions. ([`#577`](https://github.com/nyxx-discord/nyxx/pull/577)) - ([`2afc142`](https://github.com/nyxx-discord/nyxx/commit/2afc142b84fbf5fef2e2bc5eb042bd65dcf88b57))
- bug: Fix parsing button labels when they are not set. ([`#578`](https://github.com/nyxx-discord/nyxx/pull/578)) - ([`1919613`](https://github.com/nyxx-discord/nyxx/commit/19196139611c945510148ec0e8f8fdee93bd45e2))
- bug: Fix incorrect serialization of TextInputBuilder. ([`#579`](https://github.com/nyxx-discord/nyxx/pull/579)) - ([`08a14be`](https://github.com/nyxx-discord/nyxx/commit/08a14bef7416bf7ce8b39e7134e09b16f7a9a3d4))
- bug: Fix some entities not being cached. ([`#580`](https://github.com/nyxx-discord/nyxx/pull/580)) - ([`ab35012`](https://github.com/nyxx-discord/nyxx/commit/ab3501240db83f40322d84f447738b707154623e))
- bug: Fix entities getting "stuck" in cache due to momentary high use. ([`#580`](https://github.com/nyxx-discord/nyxx/pull/580)) - ([`ab35012`](https://github.com/nyxx-discord/nyxx/commit/ab3501240db83f40322d84f447738b707154623e))
- feat: Add more places entities can be cached from. ([`#580`](https://github.com/nyxx-discord/nyxx/pull/580)) - ([`ab35012`](https://github.com/nyxx-discord/nyxx/commit/ab3501240db83f40322d84f447738b707154623e))

## 6.0.0
__16.10.2023__

- rewrite: The entire library has been rewritten from the ground up. No pre-`6.0.0` code is compatible.  - 
  To explore the rewrite, check out [the API documentation](https://pub.dev/documentation/nyxx) or the [documentation website](https://nyxx.l7ssha.xyz).
  For help migrating, use the [migration tool](https://github.com/abitofevrything/nyxx-migration-script) or join [our Discord server](https://discord.gg/nyxx) for additional help.

#### Changes since 6.0.0-dev.3
- bug: Fix `ModalBuilder` having the incorrect data type. ([`#535`](https://github.com/nyxx-discord/nyxx/pull/535)) - ([`d130e4c`](https://github.com/nyxx-discord/nyxx/commit/d130e4c502acf5c0f8f726c18310f16060310d25))
- feat: Add the new `state` field to `ActivityBuilder`. ([`#556`](https://github.com/nyxx-discord/nyxx/pull/556)) - ([`3630696`](https://github.com/nyxx-discord/nyxx/commit/363069676690b7407ed5d98ace94938b9cf08309))
- bug: Fix `activities` not being sent in the presence update payload. ([`#557`](https://github.com/nyxx-discord/nyxx/pull/557)) - ([`650ee17`](https://github.com/nyxx-discord/nyxx/commit/650ee1756283b14b0cbf056268a14b968ba56660))
- bug: Fix casts when parsing `Snowflake`s triggering errors when using ETF. ([`#559`](https://github.com/nyxx-discord/nyxx/pull/559)) - ([`3402435`](https://github.com/nyxx-discord/nyxx/commit/34024358f1ff733f3122854304cd51e5bb6905c3))
- bug: Fix incorrect payload preventing the client from muting/deafening itself. ([`#561`](https://github.com/nyxx-discord/nyxx/pull/561)) - ([`c31514b`](https://github.com/nyxx-discord/nyxx/commit/c31514b5c260abf1560b9f866ec9c8fbfa46d8e5))
- bug: Correctly export `NyxxPluginState`. ([`#561`](https://github.com/nyxx-discord/nyxx/pull/561)) - ([`c31514b`](https://github.com/nyxx-discord/nyxx/commit/c31514b5c260abf1560b9f866ec9c8fbfa46d8e5))
- feat: Implement all new features since the start of the rewrite (including premium subscriptions). ([`#562`](https://github.com/nyxx-discord/nyxx/pull/562)) - ([`141e444`](https://github.com/nyxx-discord/nyxx/commit/141e444e46828a40c42092f34018cd23fef35a46))
- bug: Fix incorrect parsing of `MessageUpdateEvent`s. ([`#564`](https://github.com/nyxx-discord/nyxx/pull/564)) - ([`17dfca5`](https://github.com/nyxx-discord/nyxx/commit/17dfca56346dcf0314e10ca3485ef7abfecaaa46))
- feat: Add `logger` to plugins and make `name` inferred from `runtimeType` by default. ([`#565`](https://github.com/nyxx-discord/nyxx/pull/565)) - ([`32507f3`](https://github.com/nyxx-discord/nyxx/commit/32507f365461426ab15f175f59337c75cc75d88f))

## 6.0.0-dev.3
__16.09.2023__

- rewrite: Interaction responses now throw errors instead of using assertions. ([`#529`](https://github.com/nyxx-discord/nyxx/pull/529)) - ([`0108748`](https://github.com/nyxx-discord/nyxx/commit/0108748a044060f5cc7ec8a4252fd12fbbf4dcc4))
- rewrite: Improved plugin interface with support for plugin state and a simpler API. ([`#545`](https://github.com/nyxx-discord/nyxx/pull/545)) - ([`e2cd7b4`](https://github.com/nyxx-discord/nyxx/commit/e2cd7b413493b6477bb196ec6b273ab1bde0f07b))
- feat: Added constructors to most builders with multiple configurations. ([`#531`](https://github.com/nyxx-discord/nyxx/pull/531)) - ([`d5fd47d`](https://github.com/nyxx-discord/nyxx/commit/d5fd47d7220e51c71d141b8b43ad57a5d2b776ec))
- feat: Added support for authenticating via OAuth2. ([`0a41de7`](https://github.com/nyxx-discord/nyxx/commit/0a41de773bdf8073bb9e1b11da2daa04c5d0b73f))
- feat: Added `HttpHandler.onRateLimit` for tracking client rate limiting. ([`#532`](https://github.com/nyxx-discord/nyxx/pull/532)) - ([`76209f8`](https://github.com/nyxx-discord/nyxx/commit/76209f8c0c4cf267ff96de7f67354625c607bc2a))
- feat: Parse emoji in reaction events. ([`#533`](https://github.com/nyxx-discord/nyxx/pull/533)) - ([`9d79001`](https://github.com/nyxx-discord/nyxx/commit/9d790014fb7b5c77cb3982253e57d1b96253e898))
- feat: Allow specifying `stdout` and `stderr` in `Logging`. ([`#549`](https://github.com/nyxx-discord/nyxx/pull/549)) - ([`cf5c17d`](https://github.com/nyxx-discord/nyxx/commit/cf5c17debddd7b021c26ab02a98d5c2c3d550ab7))
- feat: Add `NyxxRest.user` to get the current user. ([`#551`](https://github.com/nyxx-discord/nyxx/pull/551)) - ([`18bafed`](https://github.com/nyxx-discord/nyxx/commit/18bafed50f24a5028e46845f26418b3b854a902e))
- feat: `Attachment` now implements `CdnAsset` for easier fetching. ([`#547`](https://github.com/nyxx-discord/nyxx/pull/547)) - ([`e1d7679`](https://github.com/nyxx-discord/nyxx/commit/e1d7679c6e1e650154d778e42e18e23f7fb5b049))
- bug: Fixed emoji in SelectMenuBuilder not being sent correctly. ([`#528`](https://github.com/nyxx-discord/nyxx/pull/528)) - ([`e4f62ab`](https://github.com/nyxx-discord/nyxx/commit/e4f62ab6187df6c3be9440ab68d8c501b296f31c))
- bug: Fixed parsing members in interaction data.  - 
- bug: `DiscordColor` did not allow a value of `0xffffff` (white). ([`#550`](https://github.com/nyxx-discord/nyxx/pull/550)) - ([`e30a8ea`](https://github.com/nyxx-discord/nyxx/commit/e30a8ea9850e8b09b93a3a925e1c5d136e8ccbce))
- bug: Fixed parsing role mentions as role objects in messages. ([`#552`](https://github.com/nyxx-discord/nyxx/pull/552)) - ([`7410c78`](https://github.com/nyxx-discord/nyxx/commit/7410c78719ebdac8bf89d5cb1706b9d4b31ddd23))


## 6.0.0-dev.2
__24.08.2023__

- rewrite: Changed `MessageBuilder.embeds` and `MessageUpdateBuilder.embeds` to use a new `EmbedBuilder` instead of `Embed` objects. ([`#525`](https://github.com/nyxx-discord/nyxx/pull/525)) - ([`28e6ab1`](https://github.com/nyxx-discord/nyxx/commit/28e6ab160a1f8cedfe9912c2a2982f2ae3c76b77))
- rewrite: Changed all builders to be mutable. ([`#524`](https://github.com/nyxx-discord/nyxx/pull/524)) - ([`7b414b8`](https://github.com/nyxx-discord/nyxx/commit/7b414b8e38ef2f0c30186ffbb119cd60a42d42d3))
- rewrite: Implement the interactions & message components API. ([#694](https://github.com/nyxx-discord/nyxx/pull/694)) - ([59c0b39](https://github.com/nyxx-discord/nyxx/commit/59c0b399dfba170d1303040606d16e707b408420))
- rewrite: `ActivityBuilder` is now exported. ([`#513`](https://github.com/nyxx-discord/nyxx/pull/513)) - ([`8989abc`](https://github.com/nyxx-discord/nyxx/commit/8989abc69ee6432cd46104cc55da237e0688502b))
- rewrite: Fixed some typos: `ChannelManager.parseForumChanel` -> `ChannelManager.parseForumChannel` and `chanel` -> `channel` in the docs for `VoiceChannel.videoQualityMode`. ([`#514`](https://github.com/nyxx-discord/nyxx/pull/514)) - ([`1533c76`](https://github.com/nyxx-discord/nyxx/commit/1533c763c62f1fb919fc50ea15483e387378835b))
- rewrite: Added wrappers around CDN endpoints and assets. ([`#511`](https://github.com/nyxx-discord/nyxx/pull/511)) - ([`05c021c`](https://github.com/nyxx-discord/nyxx/commit/05c021c89037bf33ed7e381984561ac1739d897e))
- feat: Added `Permissions.allPermissions`, the set of permission flags with all permissions. ([`#522`](https://github.com/nyxx-discord/nyxx/pull/522)) - ([`b4ea059`](https://github.com/nyxx-discord/nyxx/commit/b4ea0595ed6218a3165aa8435a36f696e508c07a))
- feat: Added `HttpHandler.latency`, `HttpHandler.realLatency`, `Gateway.latency` and `Shard.latency` for tracking the client's latency. ([`#517`](https://github.com/nyxx-discord/nyxx/pull/517)) - ([`fd56dbc`](https://github.com/nyxx-discord/nyxx/commit/fd56dbcd35e77765bebea2ac4de5418198d4b4c0))
- feat: `Flags` now has the `~` and the `^` operators. ([`#510`](https://github.com/nyxx-discord/nyxx/pull/510)) - ([`ebbf2a9`](https://github.com/nyxx-discord/nyxx/commit/ebbf2a9e5d372e62cf10493eed0e88d8fe4ef70a))
- feat: Added `HttpHandler.onRequest` and `HttpHandler.onResponse` streams for tracking HTTP requests and responses. ([`#507`](https://github.com/nyxx-discord/nyxx/pull/507)) - ([`f83aa06`](https://github.com/nyxx-discord/nyxx/commit/f83aa06aa49cf8cdb71f6a8844cd2617f446f432))
- bug: Fixed `MessageUpdateEvent`s causing a parsing error. ([`#521`](https://github.com/nyxx-discord/nyxx/pull/521)) - ([`bce7eaa`](https://github.com/nyxx-discord/nyxx/commit/bce7eaa774fe4b0ad15aa5ca7b07fa5cfbb1386e))
- bug: Fixed classes creating uncaught async errors when `toString()` was invoked on them. ([`#520`](https://github.com/nyxx-discord/nyxx/pull/520)) - ([`4ad3c76`](https://github.com/nyxx-discord/nyxx/commit/4ad3c76eeb6195ac40daa9093a67303aaa527778))
- bug: Empty caches are no longer stored. ([`#518`](https://github.com/nyxx-discord/nyxx/pull/518)) - ([`0e96354`](https://github.com/nyxx-discord/nyxx/commit/0e963547b7da649423c5bb734f0985953c2181f2))
- bug: Fixed stickers causing a parsing error. ([`#509`](https://github.com/nyxx-discord/nyxx/pull/509)) - ([`6ebc790`](https://github.com/nyxx-discord/nyxx/commit/6ebc7907d15334250203cb85dff59c7c72d66697))
- bug: Fixed rate limits not applying correctly when multiple requests were queued. ([`#507`](https://github.com/nyxx-discord/nyxx/pull/507)) - ([`f83aa06`](https://github.com/nyxx-discord/nyxx/commit/f83aa06aa49cf8cdb71f6a8844cd2617f446f432))
- bug: Fixed `applyGlobalRatelimit` in `HttpRequest` not doing anything. ([`#507`](https://github.com/nyxx-discord/nyxx/pull/507)) - ([`f83aa06`](https://github.com/nyxx-discord/nyxx/commit/f83aa06aa49cf8cdb71f6a8844cd2617f446f432))

## 6.0.0-dev.1
__03.07.2023__

- rewrite: The entire library has been rewritten from the ground up. No pre-`6.0.0-dev.1` code is compatible.  - 
  Join our Discord server for updates concerning the migration path and help upgrading.
  For now, check out the new examples and play around with the rewrite to get a feel for it.

## 5.1.1
__11.08.2023__

- bug: Error on ThreadMemberUpdateEvent due invalid event deserialization. ([`c7d1fa5`](https://github.com/nyxx-discord/nyxx/commit/c7d1fa5f482ba9b9b97ab5210789b232b2348256)) 

## 5.1.0
__16.06.2023__

- feature: Support the new unique username system with global display names. ([`#497`](https://github.com/nyxx-discord/nyxx/pull/497)) - ([`9e7b2e8`](https://github.com/nyxx-discord/nyxx/commit/9e7b2e89d5b29b1bed241dab9f458a2f3526f781))
- bug: remove the `!` in the mention string as it has been deprecated. ([`#497`](https://github.com/nyxx-discord/nyxx/pull/497)) - ([`9e7b2e8`](https://github.com/nyxx-discord/nyxx/commit/9e7b2e89d5b29b1bed241dab9f458a2f3526f781))

## 5.0.4
__04.06.2023__

- bug: Fix invalid casts.

## 5.0.3
__11.04.2023__

- bug: Always initialize guild caches. ([`b982753`](https://github.com/nyxx-discord/nyxx/commit/b9827532c9d83c2cd99efb5003df1f5cb23ef306))

## 5.0.2
__08.04.2023__

- bug: TextChannelBuilder and VoiceChannel builder had rateLimitPerUser and videoQualityMode swapped
- documentation: Guild members ([`#470`](https://github.com/nyxx-discord/nyxx/pull/470)) - ([`e165414`](https://github.com/nyxx-discord/nyxx/commit/e16541442e376a9c017cd1d9b69326fa86319427))

## 5.0.1
__18.03.2023__

- documentation: Channel invites ([`#448`](https://github.com/nyxx-discord/nyxx/pull/448)) - ([`f54390d`](https://github.com/nyxx-discord/nyxx/commit/f54390d26099b864c006b39b35663bd8239b3030))
- bug: Correctly dispose all resources on bot stop ([`#451`](https://github.com/nyxx-discord/nyxx/pull/451)) - ([`3d79b2b`](https://github.com/nyxx-discord/nyxx/commit/3d79b2b4eaf11c608b45a49d5249109a47e447b7)) 

## 4.5.1
__19.03.2023__

- bug: Correctly dispose all resources on bot stop ([`#451`](https://github.com/nyxx-discord/nyxx/pull/451)) - ([`3d79b2b`](https://github.com/nyxx-discord/nyxx/commit/3d79b2b4eaf11c608b45a49d5249109a47e447b7))

## 5.0.0
__04.03.2023__

- feature: Add named arguments anywhere we can ([`#396`](https://github.com/nyxx-discord/nyxx/pull/396)) - ([`3ec4562`](https://github.com/nyxx-discord/nyxx/commit/3ec4562f525fde7acda9c3e89b287576110b73ab))
- feature: Make CDN urls more reliable ([`#373`](https://github.com/nyxx-discord/nyxx/pull/373)) - ([`1f68eeb`](https://github.com/nyxx-discord/nyxx/commit/1f68eeb6f2aad0ea99de1b41e8edd208fedace96))
- feature: Dispatch raw events ([`#447`](https://github.com/nyxx-discord/nyxx/pull/447)) - ([`d9b373a`](https://github.com/nyxx-discord/nyxx/commit/d9b373a54e97bc7e0b00ba00bda6e6b94c6fdcf9))
- feature: Implement missing thread features ([`#433`](https://github.com/nyxx-discord/nyxx/pull/433)) - ([`cdb95a7`](https://github.com/nyxx-discord/nyxx/commit/cdb95a7c876f0f27b908ed51f1a14c9ff8043bb6))
- feature:  Add avatar decorations to cdn endpoints ([`#410`](https://github.com/nyxx-discord/nyxx/pull/410)) - ([`e9256a4`](https://github.com/nyxx-discord/nyxx/commit/e9256a45c09f271afd09b18c851cef7fbaf7ae46))

## 4.5.0
__18.02.2023__

- feature: New message types ([`#431`](https://github.com/nyxx-discord/nyxx/pull/431)) - ([`3e7d33a`](https://github.com/nyxx-discord/nyxx/commit/3e7d33ad7bf7536cf636da12b35f7413c99dfd30))
- feature: Thread members details ([`#432`](https://github.com/nyxx-discord/nyxx/pull/432)) - ([`8377c8a`](https://github.com/nyxx-discord/nyxx/commit/8377c8a4159e42851d46314cc5c7ec6eac05aac7))
- feature: Implement guild active threads endpoint ([`#434`](https://github.com/nyxx-discord/nyxx/pull/434)) - ([`ee5f7f2`](https://github.com/nyxx-discord/nyxx/commit/ee5f7f219b47565149966ce60c654e6be178a430))
- feature: Implement missing forum features ([`#433`](https://github.com/nyxx-discord/nyxx/pull/433)) - ([`cdb95a7`](https://github.com/nyxx-discord/nyxx/commit/cdb95a7c876f0f27b908ed51f1a14c9ff8043bb6))
- feature: ETF Encoding ([`#420`](https://github.com/nyxx-discord/nyxx/pull/420)) - ([`c7d3816`](https://github.com/nyxx-discord/nyxx/commit/c7d38160c0a4601dc5a06cc1ecc5df82acb3a819))
- feature: ETF encoding stability and payload compression ([`#421`](https://github.com/nyxx-discord/nyxx/pull/421)) - ([`440b6cd`](https://github.com/nyxx-discord/nyxx/commit/440b6cd917f191366888674058902fe8631068cb))
- feature: Implement @silent messages ([`#442`](https://github.com/nyxx-discord/nyxx/pull/442)) - ([`44b172d`](https://github.com/nyxx-discord/nyxx/commit/44b172d215131c3d6f5153d1624058f9b1850526))
- feature: Implement newly created and member fields in thread create event ([`#441`](https://github.com/nyxx-discord/nyxx/pull/441)) - ([`10c36c5`](https://github.com/nyxx-discord/nyxx/commit/10c36c5facb407ae15e2fd441b55b32b0f630c4a))
- feature: Add flags property to member ([`#437`](https://github.com/nyxx-discord/nyxx/pull/437)) - ([`1da4c0d`](https://github.com/nyxx-discord/nyxx/commit/1da4c0d0b8a1488e4d1646c8a5060508e72b2185))
- feature: Audit log create event ([`#436`](https://github.com/nyxx-discord/nyxx/pull/436)) - ([`b55e85d`](https://github.com/nyxx-discord/nyxx/commit/b55e85de22d0b6311e8ba921f56c1acbe40a2aa6))
- bug: hasMore is optional for guild.fetchActiveThreads() ([`#443`](https://github.com/nyxx-discord/nyxx/pull/443)) - ([`8895684`](https://github.com/nyxx-discord/nyxx/commit/8895684a339363e00057f6b5fbeb6aae8ca978f4))
- bug: Mirror fix #352 to multipart request ([`#445`](https://github.com/nyxx-discord/nyxx/pull/445)) - ([`7121638`](https://github.com/nyxx-discord/nyxx/commit/7121638968cbad5e686c65034c946b394414415c))
- bug: bug: Fix forum channel available tags deserialization
- bug: Fix update member roles equality ([`#438`](https://github.com/nyxx-discord/nyxx/pull/438)) - ([`01f29c7`](https://github.com/nyxx-discord/nyxx/commit/01f29c780b96fd1b06085557879af446f1df1517))
- documentation: Fix comments and nullability in examples ([`#416`](https://github.com/nyxx-discord/nyxx/pull/416)) - ([`24a85ec`](https://github.com/nyxx-discord/nyxx/commit/24a85ec90323c034f4591d7c2dd0afdd32022bd6))
- documentation: Add message intent to readme ([`#428`](https://github.com/nyxx-discord/nyxx/pull/428)) - ([`e3a6730`](https://github.com/nyxx-discord/nyxx/commit/e3a67305c6e2ea154b58d49565a01dd9a40a5a7b))

## 5.0.0-dev.2
__26.01.2023__

- sync with dev branch (up to 4.5.0-dev.0)  - 

## 4.5.0-dev.0
__26.01.2023__

- feature: New message types ([`#431`](https://github.com/nyxx-discord/nyxx/pull/431)) - ([`3e7d33a`](https://github.com/nyxx-discord/nyxx/commit/3e7d33ad7bf7536cf636da12b35f7413c99dfd30))
- feature: Thread members details ([`#432`](https://github.com/nyxx-discord/nyxx/pull/432)) - ([`8377c8a`](https://github.com/nyxx-discord/nyxx/commit/8377c8a4159e42851d46314cc5c7ec6eac05aac7))
- feature: Implement guild active threads endpoint ([`#434`](https://github.com/nyxx-discord/nyxx/pull/434)) - ([`ee5f7f2`](https://github.com/nyxx-discord/nyxx/commit/ee5f7f219b47565149966ce60c654e6be178a430))
- feature: Implement missing forum features ([`#433`](https://github.com/nyxx-discord/nyxx/pull/433)) - ([`cdb95a7`](https://github.com/nyxx-discord/nyxx/commit/cdb95a7c876f0f27b908ed51f1a14c9ff8043bb6))
- feature: ETF Encoding ([`#420`](https://github.com/nyxx-discord/nyxx/pull/420)) - ([`c7d3816`](https://github.com/nyxx-discord/nyxx/commit/c7d38160c0a4601dc5a06cc1ecc5df82acb3a819))
- feature: ETF encoding stability and payload compression ([`#421`](https://github.com/nyxx-discord/nyxx/pull/421)) - ([`440b6cd`](https://github.com/nyxx-discord/nyxx/commit/440b6cd917f191366888674058902fe8631068cb))
- documentation: Fix comments and nullability in examples ([`#416`](https://github.com/nyxx-discord/nyxx/pull/416)) - ([`24a85ec`](https://github.com/nyxx-discord/nyxx/commit/24a85ec90323c034f4591d7c2dd0afdd32022bd6))
- documentation: Add message intent to readme ([`#428`](https://github.com/nyxx-discord/nyxx/pull/428)) - ([`e3a6730`](https://github.com/nyxx-discord/nyxx/commit/e3a67305c6e2ea154b58d49565a01dd9a40a5a7b))

## 4.4.1
__22.01.2023__

- hotfix: Fix ratelimit handling ([`#435`](https://github.com/nyxx-discord/nyxx/pull/435)) - ([`80b0ac9`](https://github.com/nyxx-discord/nyxx/commit/80b0ac9856807b074dca55d73e588f873713c702))

## 4.4.0
__12.12.2022__

- feature: Improve error handling and logging ([`#403`](https://github.com/nyxx-discord/nyxx/pull/403)) - ([`8b7e67b`](https://github.com/nyxx-discord/nyxx/commit/8b7e67b209dd7c685d3ffae11030342a77afed5f))
- bug: Fix build() for GuildEventBuilder
- bug: Update exports

## 4.4.0-dev.0
__20.11.2022__

- feature: Improve error handling and logging ([`#403`](https://github.com/nyxx-discord/nyxx/pull/403)) - ([`8b7e67b`](https://github.com/nyxx-discord/nyxx/commit/8b7e67b209dd7c685d3ffae11030342a77afed5f))

## 4.3.0
__19.11.2022__

- feature: Add retry with backoff to network operations (gateway and http) ([`#395`](https://github.com/nyxx-discord/nyxx/pull/395)) - ([`0c666f1`](https://github.com/nyxx-discord/nyxx/commit/0c666f19c591bda6d15b372711a4345b4a880e90))
- feature: automoderation regexes ([`#393`](https://github.com/nyxx-discord/nyxx/pull/393)) - ([`6f27937`](https://github.com/nyxx-discord/nyxx/commit/6f279372b28fe35866d0713de1acc5887c46881d))
- feature: add support for interaction webhooks ([`#397`](https://github.com/nyxx-discord/nyxx/pull/397)) - ([`a255e3a`](https://github.com/nyxx-discord/nyxx/commit/a255e3a67d94c03483a60d3a94315c8f0c932960))
- feature: Forward `RetryOptions` ([`#402`](https://github.com/nyxx-discord/nyxx/pull/402)) - ([`fb6a902`](https://github.com/nyxx-discord/nyxx/commit/fb6a90254e4de349a6a376102b97ab944943680a))
- bug: Fixed bug when getting IInviteWithMeta  - 
- bug: Emit bot start to plugins only when ready ([`#392`](https://github.com/nyxx-discord/nyxx/pull/392)) - ([`8b47436`](https://github.com/nyxx-discord/nyxx/commit/8b47436878f64fbc91469aa5811e9569bf298965))
- bug: fix builder not building when editing a guild member ([`#405`](https://github.com/nyxx-discord/nyxx/pull/405)) - ([`ffbfadf`](https://github.com/nyxx-discord/nyxx/commit/ffbfadf6142328ab70ca6dbac82ec1d1e14054d3))

## 5.0.0-dev.1
__15.11.2022__

- feature: Add named arguments anywhere we can ([`#396`](https://github.com/nyxx-discord/nyxx/pull/396)) - ([`3ec4562`](https://github.com/nyxx-discord/nyxx/commit/3ec4562f525fde7acda9c3e89b287576110b73ab))

This version also includes fixes from 4.2.1

## 4.3.0-dev.1
__15.11.2022__

- feature: add support for interaction webhooks ([`#397`](https://github.com/nyxx-discord/nyxx/pull/397)) - ([`a255e3a`](https://github.com/nyxx-discord/nyxx/commit/a255e3a67d94c03483a60d3a94315c8f0c932960))

This version also includes fixes from 4.2.1

## 4.2.1
__15.11.2022__

- hotfix: fix component deserialization failing when `customId` is `null`

## 4.3.0-dev.0
__14.11.2022__

- feature: Add retry with backoff to network operations (gateway and http) ([`#395`](https://github.com/nyxx-discord/nyxx/pull/395)) - ([`0c666f1`](https://github.com/nyxx-discord/nyxx/commit/0c666f19c591bda6d15b372711a4345b4a880e90))
- feature: automoderation regexes ([`#393`](https://github.com/nyxx-discord/nyxx/pull/393)) - ([`6f27937`](https://github.com/nyxx-discord/nyxx/commit/6f279372b28fe35866d0713de1acc5887c46881d))
- bug: Emit bot start to plugins only when ready ([`#392`](https://github.com/nyxx-discord/nyxx/pull/392)) - ([`8b47436`](https://github.com/nyxx-discord/nyxx/commit/8b47436878f64fbc91469aa5811e9569bf298965))

## 4.2.0
__13.11.2022__

- feature: missing forum channel features ([`#433`](https://github.com/nyxx-discord/nyxx/pull/433)) - ([`cdb95a7`](https://github.com/nyxx-discord/nyxx/commit/cdb95a7c876f0f27b908ed51f1a14c9ff8043bb6))
- feature: Add `activeDeveloper` flag ([`#388`](https://github.com/nyxx-discord/nyxx/pull/388)) - ([`d6f692e`](https://github.com/nyxx-discord/nyxx/commit/d6f692eea72566ddcef7549e498de095ff3fc983))
- feature: Add support for new select menus components feature: Prefer using throw over returning Future.error  - 
- bug: Fix null-assert error on shard disposal; don't reconnect shard after disposing ([`#386`](https://github.com/nyxx-discord/nyxx/pull/386)) - ([`ac38200`](https://github.com/nyxx-discord/nyxx/commit/ac3820070b00591ae5d137e2bc776db42ef962fa))
- bug: Cache user when fetching ([`#384`](https://github.com/nyxx-discord/nyxx/pull/384)) - ([`2bca86e`](https://github.com/nyxx-discord/nyxx/commit/2bca86e160ed813c94d981d126f1049009bcbf8d))
- bug: add message content to client ([`#389`](https://github.com/nyxx-discord/nyxx/pull/389)) - ([`6cb667a`](https://github.com/nyxx-discord/nyxx/commit/6cb667afb117ce606bcfaed685d79b77fc4c1f4e)) 

## 4.2.0-dev.0
__11.11.2022__

- feature: missing forum channel features ([`#433`](https://github.com/nyxx-discord/nyxx/pull/433)) - ([`cdb95a7`](https://github.com/nyxx-discord/nyxx/commit/cdb95a7c876f0f27b908ed51f1a14c9ff8043bb6))
- bug: Cache user when fetching ([`#384`](https://github.com/nyxx-discord/nyxx/pull/384)) - ([`2bca86e`](https://github.com/nyxx-discord/nyxx/commit/2bca86e160ed813c94d981d126f1049009bcbf8d))

## 4.1.3
__01.11.2022__

- bug: Combine decompressed gateway payloads before parsing them

## 4.1.2
__30.10.2022__

- bug: Correctly emit connected event in `ShardManager` ([`#381`](https://github.com/nyxx-discord/nyxx/pull/381)) - ([`95b7179`](https://github.com/nyxx-discord/nyxx/commit/95b717910d561f2c6e275cf0b71a122a53c98f5c))

## 4.1.1
__23.10.2022__

- bug: Fix deserialize the emoji id of the forum tag ([`#378`](https://github.com/nyxx-discord/nyxx/pull/378)) - ([`9a5df7b`](https://github.com/nyxx-discord/nyxx/commit/9a5df7bcb36422f7bfbde4bd1b55ab8e8950b84a))

## 4.1.0
__25.09.2022__

- feature: Add `invitesDisabled` feature ([`#370`](https://github.com/nyxx-discord/nyxx/pull/370)) - ([`93140c0`](https://github.com/nyxx-discord/nyxx/commit/93140c0ed13630d71c927ebd937561935fdf31b9))
- feature: Add pending for member screening ([`#371`](https://github.com/nyxx-discord/nyxx/pull/371)) - ([`ef9adef`](https://github.com/nyxx-discord/nyxx/commit/ef9adef7c14e39164eb8a16b3774c837aac9fa3d))
- feature: member screening events ([`#372`](https://github.com/nyxx-discord/nyxx/pull/372)) - ([`5a5af0e`](https://github.com/nyxx-discord/nyxx/commit/5a5af0e34d57b0a17a9f7bc923b28c3b0b19453c))
- feature: Cache guild events ([`#369`](https://github.com/nyxx-discord/nyxx/pull/369)) - ([`b5cdb98`](https://github.com/nyxx-discord/nyxx/commit/b5cdb982d8a7b65208c52e788635983a2271b1f0))
- feature: Refactor internal shard system ([`#368`](https://github.com/nyxx-discord/nyxx/pull/368)) - ([`6ea3bcf`](https://github.com/nyxx-discord/nyxx/commit/6ea3bcf242baf97ae54c4016987b04261c24218a))
- feature: Event to notify change of connection status ([`#364`](https://github.com/nyxx-discord/nyxx/pull/364)) - ([`e3a35ff`](https://github.com/nyxx-discord/nyxx/commit/e3a35ffebb7fbe9df08234bb3616aad57289bcf6))
- feature: feature: auto moderation ([`#393`](https://github.com/nyxx-discord/nyxx/pull/393)) - ([`6f27937`](https://github.com/nyxx-discord/nyxx/commit/6f279372b28fe35866d0713de1acc5887c46881d))
- bug: Fixup shard disconnect event 

## 5.0.0-dev.0
__20.09.2022__

- refactor: Make CDN urls more reliable ([`#373`](https://github.com/nyxx-discord/nyxx/pull/373)) - ([`1f68eeb`](https://github.com/nyxx-discord/nyxx/commit/1f68eeb6f2aad0ea99de1b41e8edd208fedace96))

## 4.1.0-dev.4
__15.09.2022__

- feature: Add `invitesDisabled` feature ([`#370`](https://github.com/nyxx-discord/nyxx/pull/370)) - ([`93140c0`](https://github.com/nyxx-discord/nyxx/commit/93140c0ed13630d71c927ebd937561935fdf31b9))
- feature: Add pending for member screening ([`#371`](https://github.com/nyxx-discord/nyxx/pull/371)) - ([`ef9adef`](https://github.com/nyxx-discord/nyxx/commit/ef9adef7c14e39164eb8a16b3774c837aac9fa3d))
- feature: member screening events ([`#372`](https://github.com/nyxx-discord/nyxx/pull/372)) - ([`5a5af0e`](https://github.com/nyxx-discord/nyxx/commit/5a5af0e34d57b0a17a9f7bc923b28c3b0b19453c))

## 4.1.0-dev.3
__03.09.2022__

- feature: Cache guild events ([#682](https://github.com/nyxx-discord/nyxx/pull/682)) - ([71b4424](https://github.com/nyxx-discord/nyxx/commit/71b4424c850a94fd8808f901462583c830a70cb5))

## 4.1.0-dev.2
__28.08.2022__

- bug: Fixup shard disconnect event

## 4.1.0-dev.1
__28.08.2022__

- feature: Refactor internal shard system ([`#368`](https://github.com/nyxx-discord/nyxx/pull/368)) - ([`6ea3bcf`](https://github.com/nyxx-discord/nyxx/commit/6ea3bcf242baf97ae54c4016987b04261c24218a))
- feature: Event to notify change of connection status ([`#364`](https://github.com/nyxx-discord/nyxx/pull/364)) - ([`e3a35ff`](https://github.com/nyxx-discord/nyxx/commit/e3a35ffebb7fbe9df08234bb3616aad57289bcf6))

## 4.1.0-dev.0
__20.08.2022__

- feature: feature: auto moderation ([`#393`](https://github.com/nyxx-discord/nyxx/pull/393)) - ([`6f27937`](https://github.com/nyxx-discord/nyxx/commit/6f279372b28fe35866d0713de1acc5887c46881d))
## 4.0.0
__29.07.2022__

- breaking: Fix typo in `IHttpResponseSucess` 
- breaking: Remove `threeDayThreadArchive` and `sevenDayThreadArchive` guild features
- breaking: Remove all deprecated members  - 
- bug: Fix ratelimiting
  - breaking: All calls to the API are now made via `IHttpRoute`s instead of `String`s.
  - Construct routes by creating an `IHttpRoute()` and `add`ing `HttpRoutePart`s or by calling the helper methods on the route.
- feature: Move to Gateway & API v10 ([`#325`](https://github.com/nyxx-discord/nyxx/pull/325)) - ([`c134c64`](https://github.com/nyxx-discord/nyxx/commit/c134c645e6de4a9164e177ae15abb2e3502eecf6))
  - Added the Message Content privileged intent
- feature: Add guild Audit Log options
- feature: Implement forum channels ([`#332`](https://github.com/nyxx-discord/nyxx/pull/332)) - ([`4f58d70`](https://github.com/nyxx-discord/nyxx/commit/4f58d70032d33144556489580136afabbb18bfb0))
- feature: Implement guild Welcome Screen & Channel
- feature: Add missing Audit log types
- feature: Implement guild Banners
- feature: Implement partial presences
- feature: Add missing guild properties
- feature: Add missing reaction endpoints
- feature: Handle websocket disconnections
- feature: Implement clean client shutdown
- feature: Add `limitLength` to `MessageBuilder` ([`#356`](https://github.com/nyxx-discord/nyxx/pull/356)) - ([`763b054`](https://github.com/nyxx-discord/nyxx/commit/763b054a284984fa5f84e794f4d093be04d8154f))
- feature: Add paginated bans ([`#326`](https://github.com/nyxx-discord/nyxx/pull/326)) - ([`6ebe590`](https://github.com/nyxx-discord/nyxx/commit/6ebe590a5e37928d18723a14ef2cc86b291a47c1))
- feature: Remove dollar prefix for identify payload ([`#361`](https://github.com/nyxx-discord/nyxx/pull/361)) - ([`362adcb`](https://github.com/nyxx-discord/nyxx/commit/362adcb14b08a310d2ed43bca8178ebe74a77f1d))
- bug: Fix mention string, and use a better approach to retrieve everyone role  - 
- bug: Fix incorrect guild URLs
- bug: Fix incorrect file encoding
- bug: Fix member editing
- bug: Fix serialization issues ([`#351`](https://github.com/nyxx-discord/nyxx/pull/351)) - ([`405cffb`](https://github.com/nyxx-discord/nyxx/commit/405cffb313a1fcb54c372e6f53158a09e442af66))
- bug: Fix uninitialized fields

## 4.0.0-dev.2
__12.06.2022__

- feature: Add missing emoji endpoints ([`#346`](https://github.com/nyxx-discord/nyxx/pull/346)) - ([`b9afdeb`](https://github.com/nyxx-discord/nyxx/commit/b9afdeb03a92137199b451b46550420ab8fa7a7a))
- feature: Add `threadName` on `IWebhook#execute()` ([`#348`](https://github.com/nyxx-discord/nyxx/pull/348)) - ([`cfc7820`](https://github.com/nyxx-discord/nyxx/commit/cfc78201954c639378645dd7dacc4de151996edf))
- feature: Implement graceful shutdown ([`#347`](https://github.com/nyxx-discord/nyxx/pull/347)) - ([`6444aae`](https://github.com/nyxx-discord/nyxx/commit/6444aaeb13f47b9ad9578b2545db3635581f5d4d))
- feature: Implement forum channels ([`#332`](https://github.com/nyxx-discord/nyxx/pull/332)) - ([`4f58d70`](https://github.com/nyxx-discord/nyxx/commit/4f58d70032d33144556489580136afabbb18bfb0))
- feature: Implement Dynamic Bucket Rate Limits ([`#316`](https://github.com/nyxx-discord/nyxx/pull/316)) - ([`866fa57`](https://github.com/nyxx-discord/nyxx/commit/866fa57f18e0a6ac2bf00ec2ed928236c10b759c))
- feature: Implement paginated bans ([`#326`](https://github.com/nyxx-discord/nyxx/pull/326)) - ([`6ebe590`](https://github.com/nyxx-discord/nyxx/commit/6ebe590a5e37928d18723a14ef2cc86b291a47c1))
- feature: Implement missing guild properties
- bug: Fixed disconnecting user from voice
- bug: failed to edit guild members ([`#328`](https://github.com/nyxx-discord/nyxx/pull/328)) - ([`e242892`](https://github.com/nyxx-discord/nyxx/commit/e242892d686de30d155358273639107dd75335af))
- bug: Invalid serialization of query params ([`#352`](https://github.com/nyxx-discord/nyxx/pull/352)) - ([`ed867d6`](https://github.com/nyxx-discord/nyxx/commit/ed867d665778010faa6d3705333ecc52367ec14a))
- bug: Fix some serialization bugs ([`#351`](https://github.com/nyxx-discord/nyxx/pull/351)) - ([`405cffb`](https://github.com/nyxx-discord/nyxx/commit/405cffb313a1fcb54c372e6f53158a09e442af66))

## 4.0.0-dev.1
__09.05.2022__

- feature: Handle no internet on websocket
- bug: Remove Error form IHttpResponseError ([`#324`](https://github.com/nyxx-discord/nyxx/pull/324)) - ([`fc438e4`](https://github.com/nyxx-discord/nyxx/commit/fc438e4468bef1363ca1f6d94fbaefdfe92f36dc))
  - Fixup field names on IHttpResponseError
  - Fixup IHttpResponseSuccess name
- feature: Move to API v10 ([`#325`](https://github.com/nyxx-discord/nyxx/pull/325)) - ([`c134c64`](https://github.com/nyxx-discord/nyxx/commit/c134c645e6de4a9164e177ae15abb2e3502eecf6))

## 4.0.0-dev.0
__31.03.2022__

- feature: Fix target id property and add guild audit logs options ([`#307`](https://github.com/nyxx-discord/nyxx/pull/307)) - ([`5683012`](https://github.com/nyxx-discord/nyxx/commit/56830125c79666a5e2d31588a175b8043075e609))

## 3.4.2
__22.04.2022__

- bug: Fix setting `channel` to `null` in MemberBuilder causing errors

## 3.4.1
__10.04.2022__

- bug: bugfix: failed to edit guild members

## 3.4.0
__09.04.2022__

- feature: Add `@bannerUrl()` method
- feature: Implement paginated bans

## 3.3.1
__30.03.2022__

- bug: Fix member not being initialized in IMessage

## 3.3.0
__15.03.2022__

- feature: Guild emoji improvements
  - Added missing properties on `IBaseGuildEmoji`.
  - Partial emoji can be now resolved to it's full instance with `resolve()` method
  - Author of emoji can be now resolved with `fetchCreator()`
- feature: Allow editing messages to remove content
- feature: Add previous state to *UpdateEvents
- bug: fix: initialize name and format values for PartialSticker
- bug: Make IHttpResponseError subclass Exception
- bug: Update documentation

## 3.3.0-dev.1
__05.03.2022__

- feature: Guild emoji improvements
  - Added missing properties on `IBaseGuildEmoji`. 
  - Partial emoji can be now resolved to it's full instance with `resolve()` method
  - Author of emoji can be now resolved with `fetchCreator()`
- bug: Make IHttpResponseError subclass Exception
- bug: Update documentation

## 3.3.0-dev.0
__08.02.2022__

- feature: Implement TextInput component type

## 3.2.7
__08.02.2022__

- bugfix: Remove noop constructor parameters. Deprecate old parameters on INyxxFactory

## 3.2.6
__01.02.2022__

- bugfix: Fix permission serialisation

## 3.2.5
__30.01.2022__

- bugfix: Serialization error with permissions on ChannelBuilder. Fixes #294
- bugfix: Fix MemberBuilder serialization json error

## 3.2.4
__23.01.2022__

- bugfix: Properly serialize member edit payload. Fixes #291
- bugfix: Improve shard searching mechanism. Fixes #290
- bugfix: Fix message deserialization bug with roleMentions. Fixes #289

## 3.2.3
__10.01.2022__

- Fixup invalid formatting of emoji in BaseGuildEmoji.formatForMessage

## 3.2.2
__08.01.2022__

- Fix message edit behavior
- Fix `addEmbed` behavior on message builder

## 3.2.1
__01.01.2022__

- Fixup bug with deserialization of new field on voice guild channel introduced in previous release

## 3.2.0
__31.12.2021__

- Add missing ActivityTypes
- Fix deserialization of presence update event
- Implement voice channel region

## 3.1.1
__29.12.2021__

- Correctly expose `builder` parameter in `IMember#edit`

## 3.1.0
__28.12.2021__

- Implement patches needed for external sharding feature
- Implement boost progress bar
- Implement timeouts
  - deprecation of edit method parameters in favor of `MemberBuilder` class. In next major release all parameters except `builder`
    and `auditReason` will be removed 
- Fix incorrectly initialised onDmReceived and onSelfMention streams

## 3.0.1
__21.12.2021__

- Fix CliItegration plugin not working with IgnoreExceptions
- Use logger instead of print
- Fix typo in file name
- Nullable close code
- Missing ActivityBuilder

## 3.0.0
__19.12.2021__

- Implemented new interface-based entity model.
  > All concrete implementations of entities are now hidden behind interfaces which exports only behavior which is
  > intended for end developer usage. For example: User is now not exported and its interface `IUser` is available for developers.
  > This change shouldn't have impact of end developers.
- Implemented basic plugin system for reusable framework plugins (Currently available plugins: Logging, CliIntegration, IgnoreExceptions)
  > INyxx now implements `IPluginManager` inteface which allows registering plugin via `registerPlugin`. Developers can create their
  > own plugins which can access various hooks inside INyxx instance. For now plugins system allows hooking up to
  > `onRegister`, `onBotStart` and `onBotStop`.
- Improved cache system. Cache abstractions provided by nyxx are now compatible with `MapMixin<Snowflake, T>`
  > `SnowflakeCache` now implements `MapMixin<Snowflake, T>` and is compatibile with Map
- Allowed running bot as REST only. It enables extensions that only require nyxx entities and http capabilities.
  > Internals of nyxx were rewritten to allow running entirely in REST mode without websocket connection.
  > Previously similar behavior was available but wasn't working as intended.
- Implemented ITextVoiceTextChannel.
  > Discords beta feature `chat in voice channels` was implemented in form of `ITextVoiceTextChannel` interface
- Added support for Guild Scheduled Events
- Do not send auth header when it's not needed
- Added support for Dart 2.15
- Fixup message update payload deserialization
- Implement multiple files uploads. Fixes #226
- Implement missing webhook endpoints. Fixes #235
- Implement get thread member endpoint; Fixes #234
- Implement edit thread channel functionality; Fixes #247
- Fix few message update event deserialization bugs
- Fix TODOs and all analyzer issues

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development.

## 3.0.0-dev.2
__02.12.2021__ 

- Fixup message update payload deserialization

## 3.0.0-dev.1
__02.12.2021__

- Implement multiple files uploads. Fixes #226
- Implement missing webhook endpoints. Fixes #235
- Implement get thread member endpoint; Fixes #234
- Implement edit thread channel functionality; Fixes #247
- Fix few message update event deserialization bugs
- Fix TODOs and all analyzer issues

## 3.0.0-dev.0
__24.11.2021__

- Implemented new interface-based entity model. 
  > All concrete implementations of entities are now hidden behind interfaces which exports only behavior which is 
  > intended for end developer usage. For example: User is now not exported and its interface `IUser` is available for developers.
  > This change shouldn't have impact of end developers. 
- Implemented basic plugin system for reusable framework plugins (Currently available plugins: Logging, CliIntegration, IgnoreExceptions)
  > INyxx now implements `IPluginManager` inteface which allows registering plugin via `registerPlugin`. Developers can create their
  > own plugins which can access various hooks inside INyxx instance. For now plugins system allows hooking up to
  > `onRegister`, `onBotStart` and `onBotStop`.
- Improved cache system. Cache abstractions provided by nyxx are now compatible with `MapMixin<Snowflake, T>`
  > `SnowflakeCache` now implements `MapMixin<Snowflake, T>` and is compatibile with Map
- Allowed running bot as REST only. It enables extensions that only require nyxx entities and http capabilities.
  > Internals of nyxx were rewritten to allow running entirely in REST mode without websocket connection.
  > Previously similar behavior was available but wasn't working as intended.
- Implemented ITextVoiceTextChannel.
  > Discords beta feature `chat in voice channels` was implemented in form of `ITextVoiceTextChannel` interface 
- Do not send auth header when it's not needed
- Added support for Dart 2.15

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development. 

## 2.1.1
__02.11.2021__

- Fix #236
- Fix #237

## 2.1.0
__22.10.2021__

- Add pending to member
- use case-insensitive name comparison in _registerCommandHandlers

## 2.0.5
_15.10.2021_

- Move to Apache 2 license

## 2.0.4
_09.10_2021_

- Fix #215 - invalid application url was generated with zero permissions (592c4dcc)

## 2.0.3
_04.10.2021_

- Fix #214 - Invalid date in embed timestamp (07d855f1)

## 2.0.2
_03.10.2021_

- fix deserialization of autocomplete interaction

## 2.0.1
_03.10.2021_

 - Fix editMember function declaration

## 2.0.0
_03.10.2021_

Second major stable version of nyxx. Since 1.0 changed a lot - internal are completely rewritten, bots should work faster
and more stable and reliable

 - Implemented message components
 - Reworked rate limits implementation
 - Reworked sharding
 - Reworked http internals. Now all raw api calls are accessible.
 - Rework entity structure allowing more flexibility and partial instantiating
 - Slash commands implementation

## 2.0.0-rc.3
_25.04.2021_

> **Release Candidate 2 for stable version. Requires dart sdk 2.12**

 - Removed `w_transport` and replaced it with `http` package for http module and websockets from `dart:io` (18d0163, 5644937, 9b863a4, 06482f9)
 - Fix replacing embed field. Order of fields is now preserved (f667c2a)
 - Dart2native support (1c6a4f3)
 - Rewrite of internal object structure (ff8953d)
 - Expose raw api call api (f297cc0)
 - Add support for gateway transport compression (fd090dd)
 - Moved to v8 on REST and gateway (423173d)
 - Intents value is now required and added to Nyxx constructor (2b3e002)
 - Added ability to configure cache (163eca9)
 - Implemented stickers (16f2b79)
 - Implemented inline replies (e412ec9)
 - Added raw shard event stream (627f4a0)
 - Fix message reaction events were not triggered when cache misses message (fedbd88)
 - New utils related to slash commands (8e46b71) @HarryET
 - Fixed bug where message with only files cannot be sent (1092624)
 - Fixed setPresence method (fbb9c39) @One-Nub
 - Added missing delete() method to IChannel (131ecc0)
 - Added support for stage channels
 - Added cache options for user 

## 1.0.2
_08.09.2020_

- Fix guild embed channel deserialization
- Fix store and news channel deserialization

## 1.0.1
_29.08.2020_

- Fix voice state cache being not initialized properly.

## 1.0.0
_24.08.2020_

> **Stable release - breaks with previous versions - this version required Dart 2.9 stable and non-nullable experiment to be enabled to function**

> **`1.0.0` drops support for browser. Nyxx will now run only on VM**

 - `nyxx` package contains only basic functionality - everything else is getting own package
   - `main lib package`
        * Fixed errors and exceptions to be more self-explanatory
        * Added new and fixed old examples. Added additional documentation, fixed code to be more idiomatic
        * Logger fixes. User is now able to use their logger implementation. Or disable logging whatsover 
        * New internal http submodule - errors got from discord are always returned to end user. Improved ratelimits and errors hadling
        * Now initial presence can be specified
        * Added support for conneting to voice channel. No audio support by now tho
        * Cache no longer needed for bot to function properly
            - There is now difference between cached and uncached objects
            - Events will provide objects if cache but also raw data received from websocket (etc. snowflakes)
            - Better cache handling with better events performance
        * Implemented missing API features
        * **Added support for sharding. Bot now spawn isolate per shard to handle incoming data**
        * Fixed websocket connectin issues. Now lib should reliably react to websocket errors
        * Added `MemberChunkEvent` to client. Invoked when event is received on websocket.
        * Lib will try to properly close ws connections when process receives SIGTERM OR SIGINT.
        * Added support to shutdown hooks. Code in these hooks will be run before disposing and closed shards and/or client
        * Fixed and moved around docs
        * New internal structure of lib
        * Added extensions for `String` and `int` for more convenient way to convert them to `Snowflake`
        * Added support for gateway intents
        * `Snowflake` objects are now ints
        * Implemented member search endpoints for websocket and API
        * Added missing wrappers for data from discord
        * `==` operator fixes for objects
        
## [0.30.0](https://github.com/l7ssha/nyxx/compare/0.24.0...0.30.0)
_Tue 07.02.2019_

*This version drops support for Dart SDK 1.x; Nyxx now only supports Dart 2.0+ including dev sdk.*

*Changelog can be incomplete - it's hard to track changes across few months*

- **Features added**
  * **SUPPORT FOR DART 2.0+**
  * **ADDED SUPPORT FOR VOICE via Lavalink**
  * **PERMISSIONS OVERHAUL**
    - Proper permissions handling
  * **COMMANDS FRAMEWORK REWRITTEN**
    - Dispatch pipe is completely rewritten. Bot should operate about 2-8x faster
    - Allowed to declare single method commands without using classes
    - Added support for specify custom restrictions to commands handlers
    - Classes now have to be annotated with `Module` instead of `Command`
    - `Remainder` can now called data to `List<String>` or `String`
    - Added `Preprocessor` and `Posprocessor`
    - Removed help system
  * **COMMANDS PARSER**
    - Allows to define simple commands handlers
  * **Nyxx can be now used in browser**
  * Many additions to `Member` and `User` classes
  * Changed internal library structure
  * Implemented Iterable for Channel to query messages
  * Added typing event per channel
  * Using `v7` api endpoint
  * Added support for zlib compressed gateway payload
  * Added endpoints for Guild, Emoji, Role, Member
  * Added utils module
  * Allowed to download attachments. (`Downloadable` interface)
  * Implemented new Discord features (Priority speaker, Slowmode)
  * Added `DiscordColor` class
  * Added `Binder` util
  * Added `Cache`
  * Added `MessageBuilder`
  * Added interfaces `Downloadable`, `Mentionable`, `Debugable`, `Disposable`, `GuildEntity`
- **Bug fixes**
  * **Lowered memory usage**
  * **Websocket fixed**
  * Fixed Emojis comparing
  * Fixed searching in Emojis unicode
  * Code cleanup and style fixes
  * Proper error handling for `CommandsFramework`
  * Gateway fixes
  * Object deserializing fixes
  * Memory and performance improvements
  * Random null exceptions
  * Emojis CDN fixes
  * Few fixes for ratelimitter
- **Changes**
  * **Docs are rewritten**
  * **Faster deserialization**
  * **Embed builders rewritten**
  * Removed autosharding.
  * Every object which has id is now subclass of `SnowflakeEntity`.
  * Snowflakes are default id entities
  * Internal nyxx API changes
  * Cooldown cache rewritten
  * Presence sending fixes
  * Title is not required for EmbedBuilder
  * Removed unnecessary dependencies

## [0.24.0](https://github.com/l7ssha/nyxx/compare/0.23.1...0.24.0)
_Tue 03.08.2018_

- **Changes**
  * nyxx now supports Dart 2.0
  * Added Interactivity module
  * Added few methods to `CommandContext`
  * Rewritten `CooldownCache`

- **Bug fixes**
  * Fixed `Command` help generating error
  * Fixed Emojis equals operator

## [0.23.1](https://github.com/l7ssha/nyxx/compare/0.23.0...0.23.1)
_Tue 31.07.2018_

- **Bug fixes**
  * Fixed `MessageDeleteEvent` deserializing error
  * Fixed checking for channel nsfw for CommandsFramework

## [0.23.0](https://github.com/l7ssha/nyxx/compare/0.22.1...0.23.0)
_Mon 30.07.2018_

- **New features**
  * Support for services - DEPENDENCY INJECTION
  * Support for type parsing
  * Logging support
  * Listener for messages for channel
  * Automatic registering Services and Commands
  * `Remainder` annotation which captures all remaining text
  * Permissions are now **READ/WRITE** - added PermissionsBuilder
  * Checking for topics and if channel is nsfw for commands
- **Bug fixes**
  * Fixed error throwing
  * Text in quotes is one String
  * Fixed StreamControllers to be broadcast
  * Removed unnecessary fields from DMChannel and GroupDMChannel
  * Big performance improvement of CommandFramework
  * Fixed Permissions opcode
  * `delay()` changed to `nextMessage()`
- **Deprecations**
  * Deprecated browser target  
  * Removed MirrorsCommandFramework and InstanceCommandFramework

## [0.22.1](https://github.com/l7ssha/nyxx/compare/0.22.0...0.22.1)
_Wed 11.07.2018_

- **Bug fixes**
  * Fixed bug with sending Emoji. `toString()` now return proper representation ready to send via message
- **New features**
  * Searching in `EmojisUnicode` is now handled by future.
  * toString() in `User`, `Channel`, `Role` now returns mention instead of content, name etc.

## [0.22.0](https://github.com/l7ssha/nyxx/compare/0.21.5...0.22.0)
_Wed 11.07.2018_

- **Bug fixes**
  * Next serialization bug fixes
- **New features**
  * Added support for [audit logs](https://discordapp.com/developers/docs/resources/audit-log)
  * Searching in `EmojisUnicode` based on shortcode
  
## [0.21.5](https://github.com/l7ssha/nyxx/compare/0.21.4...0.21.5)
_Fri 09.07.2018_

- **Bug fixes**
  * Fixed embed serialization
  
## [0.21.4](https://github.com/l7ssha/nyxx/compare/0.21.3...0.21.4)
_Fri 09.07.2018_

- **Bug fixes**
  * Fixed embed serialization
  
  
## [0.21.3](https://github.com/l7ssha/nyxx/compare/0.21.2...0.21.3)
_Fri 08.07.2018_

- **Bug fixes**
  * Fixed embed serialization
- **Added few Docs**


## [0.21.2](https://github.com/l7ssha/nyxx/compare/0.21.1...0.21.2)
_Fri 06.07.2018_

- **Bug fixes**
  * Added overrides
  * Implemented hashCode
  * Fixed return type for `delay()` in Command class


## [0.21.1](https://github.com/l7ssha/nyxx/compare/0.21.0...0.21.1)
_Fri 06.07.2018_

- **Bug fixes**
  * Fixed constructors in MessageChannel and TextChannel


## [0.21.0](https://github.com/l7ssha/nyxx/compare/0.20.0...0.21.0)
_Fri 06.07.2018_

- **New features**
  * Support for sending files, attaching files in embed
  * Added missing gateway events
  * Replaced String ids with `Snowflake` type
- **Bug fixes**
