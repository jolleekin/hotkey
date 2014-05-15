import 'package:hotkey/hotkey.dart' as hotkey;
import 'dart:html';

main() {
  querySelectorAll('button').onClick.listen((MouseEvent e) {
    var b = e.target as ButtonElement;
    querySelector('#msg').text = 'Hotkey bound to an element: ${b.text} clicked';
  });
  hotkey.add('a > b > c', () {
    querySelector('#msg').text = 'Hotkey bound to a function: a then b then c';
  });
  hotkey.processAll();
  hotkey.enable();
}
