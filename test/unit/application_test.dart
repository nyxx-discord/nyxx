import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/application/app_team.dart';
import 'package:nyxx/src/core/application/client_oauth2_application.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/nyxx_rest.mock.dart';

const exampleAppTeamPayload = <String, dynamic>{
  "id": 567,
  "icon": 'example_icon_hash',
  'owner_user_id': 987654321,
  "members": [
    {
      "user": {
        "username": "l7ssha",
        "discriminator": "6712",
        "id": 123456789,
      },
      "membership_state": 10
    },
    {
      "user": {
        "username": "another_account",
        "discriminator": "123",
        "avatar": "this_is_new_hash",
        "id": 987654321,
      },
      "membership_state": 10
    }
  ]
};

const exampleClientOAuth2ApplicationPayload = <String, dynamic>{
  "flags": 0x0101,
  "owner": {
    'username': 'l7ssha',
    'discriminator': '6712',
    'id': 123456789,
    'avatar': null,
    'bot': false,
    'system': null,
    'public_flags': 1 << 0,
    'banner': 'banner-hash',
    'accent_color': 0x808080,
  },
  'description': "this is example description",
  'name': 'this-is-app-name',
  'icon': null,
  'rpcOrigins': null,
  'id': 123456,
};

main() {
  test("test constructor AppTeam", () {
    final resultEntity = AppTeam(exampleAppTeamPayload);

    expect(resultEntity.ownerMember.user.id, equals(resultEntity.ownerId));
    expect(resultEntity.teamIconUrl, equals("https://cdn.${Constants.cdnHost}/team-icons/567/example_icon_hash.png"));
  });

  test("test constructor OAuth2Info", () {
    final resultEntity = ClientOAuth2Application(exampleClientOAuth2ApplicationPayload, NyxxRestMock());

    expect(resultEntity, isA<ClientOAuth2Application>());
    expect(resultEntity.getInviteUrl(), equals("https://${Constants.host}/oauth2/authorize?client_id=123456&scope=bot%20applications.commands"));
    expect(
        resultEntity.getInviteUrl(10), equals("https://${Constants.host}/oauth2/authorize?client_id=123456&scope=bot%20applications.commands&permissions=10"));
    expect(resultEntity.iconUrl(), isNull);

    Map<String, dynamic> cloneExampleClientOAuth2ApplicationPayload = Map.from(exampleClientOAuth2ApplicationPayload);
    cloneExampleClientOAuth2ApplicationPayload['icon'] = 'test';

    final resultEntityWithIcon = ClientOAuth2Application(cloneExampleClientOAuth2ApplicationPayload, NyxxRestMock());
    expect(resultEntityWithIcon.iconUrl(), "https://cdn.discordapp.com/app-icons/123456/test.png?size=512");
  });
}
