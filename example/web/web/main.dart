import 'dart:html';
import 'package:nyxx/Browser.dart';
import 'package:nyxx/nyxx.dart';

void main() {
  final FormElement tokenForm = document.querySelector('form.bot-token-form');
  final InputElement tokenInput = document.querySelector('input[name="token"]');
  final InputElement tokenSubmit =
      document.querySelector('input[type="submit"]');

  final DivElement messages = document.querySelector('.messages');
  final DivElement bots = document.querySelector('div#bots');
  final TemplateElement botTemplate = bots.querySelector('template');
  assert(messages != null);
  assert(bots != null);
  assert(botTemplate != null);

  tokenSubmit.disabled = tokenInput.value.length < 1;
  tokenInput.addEventListener('input', (e) {
    tokenSubmit.disabled = tokenInput.value.length < 1;
  });

  tokenForm.addEventListener('submit', (e) {
    e.preventDefault();

    final Nyxx client = NyxxBrowser(tokenInput.value);

    final DocumentFragment fragment =
        document.importNode(botTemplate.content, true);
    final DivElement bot = fragment.querySelector('.bot');
    final SpanElement nameElm = bot.querySelector('.bot-name');
    final SpanElement statusElm = bot.querySelector('.bot-status');
    final ButtonElement disconnectButton =
        bot.querySelector('.disconnect-button');
    statusElm.text = client.ready ? "Ready" : "Not ready";
    client.onHttpError.listen((e) {
      statusElm.text = e.response.toString();
    });
    client.onReady.listen((e) {
      nameElm.text = client.self.username + '#' + client.self.discriminator;
      nameElm.title = client.self.id.toString();
    });
    disconnectButton.addEventListener('click', (e) async {
      await client.dispose();
      bot.remove();
    });
    bots.append(bot);

    client.onMessage.listen((MessageEvent e) {
      DivElement message = new DivElement();
      message.text = e.message.content;
      messages.append(message);
    });

    tokenInput.value = "";
    tokenSubmit.disabled = tokenInput.value.length < 1;
  });
}
