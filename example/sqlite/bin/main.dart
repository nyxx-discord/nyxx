import 'package:nyxx/Vm.dart';
import 'package:sqlite2/sqlire.dart';

import 'dart:io';

main() async {
  var db = Database.inMemory();
  await db.execute("CREATE TABLE tags (name text, content text)");
  await db.execute("INSERT INTO tags VALUES ('haha', '😂')");

  var client = NyxxVm(Platform.environment['DISCORD_TOKEN']);

  client.onMessage.listen((msg) async {
    if (msg.message.content.startsWith("?tag haha")) {
      await msg.message.channel.send(
          content:
              (await (await db.query("SELECT * FROM tags WHERE name='haha'"))
                  .first)['content']);
    }
  });

  db.close();
}
