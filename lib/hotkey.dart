/**
 * A library that enables the binding of hotkeys (keyboard shortcuts) to
 * [Element]'s or [Function]'s.
 *
 * To use this library, import it as follows:
 *     import 'package:hotkey/hotkey.dart' as hotkey;
 *
 * Since all functions in this library are top level, an alias is recommended
 * to avoid name collision and ambiguity.
 */
library hotkey;

import 'dart:html';

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
  8: 'BACKSPACE',
  9: 'TAB',
  13: 'ENTER',
  19: 'PAUSE',
  20: 'CAPS_LOCK',
  27: 'ESC',
  32: 'SPACE',
  33: 'PAGE_UP',
  34: 'PAGE_DOWN',
  35: 'END',
  36: 'HOME',
  37: 'LEFT',
  38: 'UP',
  39: 'RIGHT',
  40: 'DOWN',
  45: 'INSERT',
  46: 'DELETE',
  48: '0',
  49: '1',
  50: '2',
  51: '3',
  52: '4',
  53: '5',
  54: '6',
  55: '7',
  56: '8',
  57: '9',
  65: 'A',
  66: 'B',
  67: 'C',
  68: 'D',
  69: 'E',
  70: 'F',
  71: 'G',
  72: 'H',
  73: 'I',
  74: 'J',
  75: 'K',
  76: 'L',
  77: 'M',
  78: 'N',
  79: 'O',
  80: 'P',
  81: 'Q',
  82: 'R',
  83: 'S',
  84: 'T',
  85: 'U',
  86: 'V',
  87: 'W',
  88: 'X',
  89: 'Y',
  90: 'Z',
  91: 'LWIN',
  92: 'RWIN',
  112: 'F1',
  113: 'F2',
  114: 'F3',
  115: 'F4',
  116: 'F5',
  117: 'F6',
  118: 'F7',
  119: 'F8',
  120: 'F9',
  121: 'F10',
  122: 'F11',
  123: 'F12',
  144: 'NUM_LOCK',
  145: 'SCROL_LLOCK',
  186: ';',
  187: '=',
  188: ',',
  189: '-',
  190: '.',
  191: '/',
  192: '`',
  219: '[',
  220: '\\',
  221: ']',
  222: '\''
};

/**
 * Looks for elements with [HOTKEY_ATTRIBUTE] attribute in the document and
 * hook up the hotkeys.
 *
 * If [removeHotkeyAttribute] is `true`, [HOTKEY_ATTRIBUTE] attribute will be
 * removed.
 */
void processAll({bool removeHotkeyAttribute: true}) {
  for (var e in querySelectorAll('[$HOTKEY_ATTRIBUTE]')) {
    var hotkeys = e.attributes[HOTKEY_ATTRIBUTE].split(HOTKEY_DELIMITER);
    for (var hotkey in hotkeys) {
      add(hotkey, e);
    }
    if (removeHotkeyAttribute) e.attributes.remove(HOTKEY_ATTRIBUTE);
  }
}

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
void add(String hotkey, target) {
  if (target is! Element && target is! Function) {
    throw new ArgumentError('[target] must be an [Element] or a [Function].');
  }

  var parts = _split(hotkey);
  for (var part in parts) {
    if (!_isValidKeyCombination(part)) {
      throw new ArgumentError('Hotkey "$hotkey" contains invalid combination "$part".');
    }
  }

  var node = _tree;

  for (var i = 0, end = parts.length - 1; i < end; i++) {
    var part = parts[i];
    if (node[part] == null) node[part] = <String, dynamic>{};
    node = node[part];

    // Adding 'A>B>C' while 'A>B' already exists.
    // 'A>B>C' is shadowed and will never be realized.
    if (node is! Map) {
      throw new ArgumentError('Hotkey "$hotkey" is shadowed by other hotkeys.');
    }
  }

  // Adding 'A>B' while 'A>B>C' already exists.
  // 'A>B>C' is shadowed and will never be realized.
  if (node[parts.last] != null) {
    throw new ArgumentError('Hotkey "$hotkey" shadows other hotkey(s).');
  }

  node[parts.last] = target;
}

/**
 * Removes [hotkey] from [target].
 *
 * If [hotkey] is `null`, removes all hotkeys associated with [target].
 *
 * Returns `true` on success.
 */
bool remove(String hotkey, target) {
  if (hotkey != null) return _removeSingle(_tree, target, _split(hotkey));
  return _removeAll(_tree, target);
}

/**
 * Enables hotkeys globally.
 */
void enable() {
  if (_sub == null) _sub = Element.keyDownEvent
      .forTarget(window, useCapture: true)
      .listen(_detectHotKey);
}

/**
 * Disables hotkeys globally.
 */
void disable() {
  _sub.cancel();
  _sub = null;
}

/**
 * Splits a hotkey string into a series of key combinations.
 */
_split(s) => s.replaceAll(' ', '').toUpperCase().split(KEY_COMBINATION_DELIMITER);

/**
 * Removes all hotkeys associated with [target] from [tree].
 *
 * Returns `true` on success.
 */
bool _removeAll(Map tree, target) {
  var result = false;
  for (var key in tree.keys.toList()) {
    var child = tree[key];
    if (child is Map) {
      if (_removeAll(child, target)) {
        if (child.isEmpty) tree.remove(key);
        result = true;
      }
    } else if (child == target) {
      tree.remove(key);
      result = true;
    }
  }
  return result;
}

/**
 * Removes a hotkey defined by [parts] for the target [target] from [tree].
 */
bool _removeSingle(tree, target, List<String> parts) {
 if (tree is Map) {
   var key = parts.first;
   var child = tree[key];
   if (parts.length > 1) {
     parts.removeAt(0);
     if (_removeSingle(child, target, parts)) {
       if (child.isEmpty) tree.remove(key);
       return true;
     }
   } else if (child == target) {
     tree.remove(key);
     return true;
   }
 }
 return false;
}

/**
 * Tests if [e] is an editable element.
 */
bool _isEditable(Element e) {
  if (e is TextAreaElement) return !e.disabled;
  if (e is InputElement) {
    return !e.disabled  && (e.type == 'tel' ||
                            e.type == 'text' ||
                            e.type == 'email' ||
                            e.type == 'search' ||
                            e.type == 'password');
  }
  while (e != null) {
    if (e.isContentEditable) return true;
    e = e.parent;
  }
  return false;
}

/**
 * Returns the true active element.
 *
 * This function works across any Shadow DOM boundaries.
 */
Element _getActiveElement(Element root) {
  if (root == null) root = document.activeElement;
  while (root.shadowRoot != null) {
    root = root.shadowRoot.activeElement;
  }
  return root;
}

void _detectHotKey(KeyboardEvent e) {
  if (!ALLOWED_KEY_IDENTIFIERS.containsKey(e.keyCode)) return;
  var activeElement = _getActiveElement(e.target);
  if (_isEditable(activeElement) && !e.ctrlKey && !e.altKey) return;

  var key = '';
  if (e.ctrlKey) key += 'CTRL+';
  if (e.shiftKey) key += 'SHIFT+';
  if (e.altKey) key += 'ALT+';
  key += ALLOWED_KEY_IDENTIFIERS[e.keyCode];

  _node = _node[key];
  if (_node == null) _node = _tree[key];
  if (_node == null) _node = _tree;

  if (_node is Map) return;
  if (_node is InputElement && _node.disabled) return;
  if (_node is ButtonElement && _node.disabled) return;

  if (_node is Function) {
    _node();
  } else if (_isEditable(_node)) {
    _node.focus();
  } else {
    _node.click();
  }

  _node = _tree;
  e.preventDefault();
  e.stopPropagation();
}

bool _isValidKeyCombination(String key) {
  var match = _keyRegExp.firstMatch(key);
  if (match != null) {
    var identifier = match.group(match.groupCount);
    if (ALLOWED_KEY_IDENTIFIERS.values.contains(identifier)) return true;
  }
  return false;
}

final _keyRegExp = new RegExp(r'^(?:CTRL\+)?(?:SHIFT\+)?(?:ALT\+)?(.+)');

/**
 * The hotkey tree.
 *
 * Keys are strings, defining parts of hotkeys.
 *
 * Leaves are [Element]'s or [Function]'s.
 *
 * Example:
 *     {
 *       'G': {
 *         'I': <a href="#inbox">Inbox</a>,
 *         'S': <a href="#sent">Sent</a>],
 *       },
 *       'CTRL+R': {
 *         'CTRL+R': function rename() {...}
 *       }
 *     }
 *
 * There are three hotkeys in the above example:
 * * 'G,I': Go to Inbox
 * * 'G,S': Go to Sent
 * * 'CTRL+R,CTRL+R': Call function `rename`.
 */
final _tree = <String, dynamic>{};
var _node = _tree;
var _sub;
