# Overview
**hotkey** is a Dart library that enables the binding of hotkeys
(keyboard shortcuts) to `Element`'s or `Function`'s. The library allows a wide
range of hotkeys, from simple ones that consist of only single letters to
complex ones that consist of a series of keys with `CTRL`, `SHIFT`, and `ALT`
modifiers.
# Bind Hotkeys to Functions
```` dart
import 'package:hotkey/hotkey.dart' as hotkey;

hotkey.add('a>b>c | x>y>z', () => print('A then B then C or X then Y then Z'));
hotkey.add('CTRL+R > CTRL+R', () => print('CTRL+R then CTRL+R'));
hotkey.add('SHIFT+T', () => print('SHIFT+T'));
hotkey.add('CTRL+SHIFT+ALT+A', () => print('CTRL+SHIFT+ALT+A'));

hotkey.enable();
````
# Bind Hotkeys to Elements

1. If the element `e` is editable (`textarea`, `input[type=tel]`, `input[type=text]`,
   `input[type=tel]`, `input[type=email]`, `input[type=pasword]` with `disabled`
   attribute set to `false` or `isContentEditable` set to `true`), `e.focus` is
   called
2. Otherwise, `e.click` is called

## Option 1 - Declarative

HTML
```` html    
<a href="#inbox" data-hotkey="G>I" title="(G then I)">Inbox</a>

<button data-hotkey="CTRL+ENTER | ALT+S" title="(Ctrl+Enter or Alt+S)">Send</button>

<button data-hotkey="ESC" title="(Esc)">Cancel</button>

<input type="search" data-hotkey="/" title="(/)" placeholder="Search the store" />

<button data-hotkey="CTRL+SHIFT+ALT+M > G > G > G">Magic Button</button>
````

DART
```` dart
import 'package:hotkey/hotkey.dart' as hotkey;

hotkey.processAll();
hotkey.enable();
````

## Option 2 - Programmatic
```` dart
import 'package:hotkey/hotkey.dart' as hotkey;

hotkey.add('g > i', inboxAnchorElement);
hotkey.add('ctrl+enter | alt+s', sendButton);
hotkey.add('esc', cancelButton);

hotkey.enable();
````
# API Reference
```` dart
/**
 * The attribute used to store a hotkey for an [Element].
 */
const HOTKEY_ATTRIBUTE = 'data-hotkey';

/**
 * The delimiter to separate hotkeys in [HOTKEY_ATTRIBUTE].
 *
 * For example, to bind two hotkeys 'CTRL+ENTER' and 'ALT+S' to a button,
 * set its [HOTKEY_ATTRIBUTE] to 'CTRL+ENTER | ALT+S'.
 */
const HOTKEY_DELIMITER = '|';

/**
 * The delimiter to separate key combinations within a hotkey.
 *
 * '>' is used instead of ',' to allow ',' to be used as an hotkey.
 *
 * Example: 'CTRL+M > CTRL+I' means pressing CTRL + G then CTRL + I.
 */
const KEY_COMBINATION_DELIMITER = '>';

/**
 * Allowed key identifiers used in hotkeys.
 */
const ALLOWED_KEY_IDENTIFIERS = const {
  // See the source code.
};

/**
 * Looks for elements with [HOTKEY_ATTRIBUTE] attribute in the document and
 * hook up the hotkeys.
 *
 * If [removeHotkeyAttribute] is `true`, [HOTKEY_ATTRIBUTE] attribute will be
 * removed.
 */
void processAll({bool removeHotkeyAttribute: true});

/**
 * Adds the hotkey [hotkey] to the target [target].
 *
 * A hotkey is a series of key combinations separated by [KEY_COMBINATION_DELIMITER].
 * A key combination can be any character defined by [ALLOWED_KEY_IDENTIFIERS]
 * combined with three key modifiers CTRL, SHIFT, and ALT in order.
 *
 * Examples of valid hotkeys: 'A', 'G>I', 'CTRL+K > CTRL+D', 'CTRL+SHIFT+ALT+A'.
 *
 * Examples of invalid hotkeys:
 * * 'A,B': wrong delimiter
 * * 'CTRL+ALT': missing key identifier
 * * 'ALT+CTRL+B': wrong order of CTRL and ALT
 *
 * [target] is either an [Element] or a [Function].
 * * If [target] is Function, it is called without any argument
 * * If [target] is an editable element (textarea, input[type=text], ...),
 * [target.focus] is called
 * * Else, [target.click] is called
 *
 * A target can have many hotkeys, but a hotkey can only have one target.
 *
 * Throws an [ArgumentError] if the hotkey association cannot be established.
 */
void add(String hotkey, target);

/**
 * Removes [hotkey] from [target].
 *
 * If [hotkey] is `null`, removes all hotkeys associated with [target].
 *
 * Returns `true` on success.
 */
bool remove(String hotkey, target);

/**
 * Enables hotkeys globally.
 */
void enable();

/**
 * Disables hotkeys globally.
 */
void disable();

````