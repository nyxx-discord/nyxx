import 'dart:html';
import 'package:nyxx/Browser.dart';
import 'package:nyxx/nyxx.dart';

void main() {
  configureNyxxForBrowser();

  FormElement tokenForm = document.querySelector('form.bot-token-form');
  InputElement tokenInput = document.querySelector('input[name="token"]');
  InputElement tokenSubmit = document.querySelector('input[type="submit"]');

  DivElement messages = document.querySelector('.messages');
  assert(messages != null);

  tokenSubmit.disabled = tokenInput.value.length < 1;
  tokenInput.addEventListener('input', (e) {
    tokenSubmit.disabled = tokenInput.value.length < 1;
  });

  tokenForm.addEventListener('submit', (e) {
    e.preventDefault();

    Nyxx client = Nyxx(tokenInput.value);
    client.onMessage.listen((MessageEvent e) {
      DivElement message = new DivElement();
      message.text = e.message.content;
      messages.append(message);
    });

    tokenInput.value = "";
    tokenSubmit.disabled = tokenInput.value.length < 1;
  });

}
