import 'package:re_editor/re_editor.dart';

/// JavaScript 关键字/保留字。
const List<CodeKeywordPrompt> kJsKeywordPrompts = [
  CodeKeywordPrompt(word: 'break'),
  CodeKeywordPrompt(word: 'case'),
  CodeKeywordPrompt(word: 'catch'),
  CodeKeywordPrompt(word: 'class'),
  CodeKeywordPrompt(word: 'const'),
  CodeKeywordPrompt(word: 'continue'),
  CodeKeywordPrompt(word: 'debugger'),
  CodeKeywordPrompt(word: 'default'),
  CodeKeywordPrompt(word: 'delete'),
  CodeKeywordPrompt(word: 'do'),
  CodeKeywordPrompt(word: 'else'),
  CodeKeywordPrompt(word: 'export'),
  CodeKeywordPrompt(word: 'extends'),
  CodeKeywordPrompt(word: 'false'),
  CodeKeywordPrompt(word: 'finally'),
  CodeKeywordPrompt(word: 'for'),
  CodeKeywordPrompt(word: 'function'),
  CodeKeywordPrompt(word: 'if'),
  CodeKeywordPrompt(word: 'import'),
  CodeKeywordPrompt(word: 'in'),
  CodeKeywordPrompt(word: 'instanceof'),
  CodeKeywordPrompt(word: 'let'),
  CodeKeywordPrompt(word: 'new'),
  CodeKeywordPrompt(word: 'null'),
  CodeKeywordPrompt(word: 'of'),
  CodeKeywordPrompt(word: 'return'),
  CodeKeywordPrompt(word: 'super'),
  CodeKeywordPrompt(word: 'switch'),
  CodeKeywordPrompt(word: 'this'),
  CodeKeywordPrompt(word: 'throw'),
  CodeKeywordPrompt(word: 'true'),
  CodeKeywordPrompt(word: 'try'),
  CodeKeywordPrompt(word: 'typeof'),
  CodeKeywordPrompt(word: 'undefined'),
  CodeKeywordPrompt(word: 'var'),
  CodeKeywordPrompt(word: 'void'),
  CodeKeywordPrompt(word: 'while'),
  CodeKeywordPrompt(word: 'with'),
  CodeKeywordPrompt(word: 'yield'),
  CodeKeywordPrompt(word: 'async'),
  CodeKeywordPrompt(word: 'await'),
  CodeKeywordPrompt(word: 'static'),
];

/// 全局对象/构造器等直接补全项。
const List<CodePrompt> kJsGlobalPrompts = [
  CodeFieldPrompt(word: 'console', type: 'Console'),
  CodeFieldPrompt(word: 'window', type: 'Window'),
  CodeFieldPrompt(word: 'document', type: 'Document'),
  CodeFieldPrompt(word: 'globalThis', type: 'object'),
  CodeFieldPrompt(word: 'Math', type: 'Math'),
  CodeFieldPrompt(word: 'JSON', type: 'JSON'),
  CodeFieldPrompt(word: 'Object', type: 'ObjectConstructor'),
  CodeFieldPrompt(word: 'Array', type: 'ArrayConstructor'),
  CodeFieldPrompt(word: 'String', type: 'StringConstructor'),
  CodeFieldPrompt(word: 'Number', type: 'NumberConstructor'),
  CodeFieldPrompt(word: 'Boolean', type: 'BooleanConstructor'),
  CodeFieldPrompt(word: 'Symbol', type: 'SymbolConstructor'),
  CodeFieldPrompt(word: 'Promise', type: 'PromiseConstructor'),
  CodeFieldPrompt(word: 'Error', type: 'ErrorConstructor'),
  CodeFieldPrompt(word: 'Map', type: 'MapConstructor'),
  CodeFieldPrompt(word: 'Set', type: 'SetConstructor'),
  CodeFieldPrompt(word: 'WeakMap', type: 'WeakMapConstructor'),
  CodeFieldPrompt(word: 'WeakSet', type: 'WeakSetConstructor'),
  CodeFieldPrompt(word: 'Date', type: 'DateConstructor'),
  CodeFieldPrompt(word: 'RegExp', type: 'RegExpConstructor'),
  CodeFieldPrompt(word: 'NaN', type: 'number'),
  CodeFieldPrompt(word: 'Infinity', type: 'number'),
  CodeFunctionPrompt(
    word: 'parseInt',
    type: 'number',
    parameters: {'string': 'string'},
    optionalParameters: {'radix': 'number'},
  ),
  CodeFunctionPrompt(
    word: 'parseFloat',
    type: 'number',
    parameters: {'string': 'string'},
  ),
  CodeFunctionPrompt(
    word: 'isNaN',
    type: 'boolean',
    parameters: {'value': 'any'},
  ),
  CodeFunctionPrompt(
    word: 'isFinite',
    type: 'boolean',
    parameters: {'value': 'any'},
  ),
  CodeFunctionPrompt(
    word: 'encodeURIComponent',
    type: 'string',
    parameters: {'value': 'string'},
  ),
  CodeFunctionPrompt(
    word: 'decodeURIComponent',
    type: 'string',
    parameters: {'value': 'string'},
  ),
  CodeFunctionPrompt(
    word: 'setTimeout',
    type: 'number',
    parameters: {'handler': 'Function', 'timeout': 'number'},
  ),
  CodeFunctionPrompt(
    word: 'clearTimeout',
    type: 'void',
    parameters: {'id': 'number'},
  ),
  CodeFunctionPrompt(
    word: 'setInterval',
    type: 'number',
    parameters: {'handler': 'Function', 'timeout': 'number'},
  ),
  CodeFunctionPrompt(
    word: 'clearInterval',
    type: 'void',
    parameters: {'id': 'number'},
  ),
  CodeFunctionPrompt(
    word: 'fetch',
    type: 'Promise<Response>',
    parameters: {'input': 'string'},
    optionalParameters: {'init': 'RequestInit'},
  ),
];

/// `foo.` 后的成员补全:按接收对象名映射。
const Map<String, List<CodePrompt>> kJsMemberPrompts = {
  'console': [
    CodeFunctionPrompt(
      word: 'log',
      type: 'void',
      parameters: {'message': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'info',
      type: 'void',
      parameters: {'message': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'warn',
      type: 'void',
      parameters: {'message': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'error',
      type: 'void',
      parameters: {'message': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'debug',
      type: 'void',
      parameters: {'message': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'trace',
      type: 'void',
      parameters: {'message': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'table',
      type: 'void',
      parameters: {'data': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'group',
      type: 'void',
      parameters: {'label': 'string'},
    ),
    CodeFunctionPrompt(word: 'groupEnd', type: 'void'),
    CodeFunctionPrompt(word: 'clear', type: 'void'),
  ],
  'JSON': [
    CodeFunctionPrompt(
      word: 'stringify',
      type: 'string',
      parameters: {'value': 'any'},
      optionalParameters: {'replacer': 'Function', 'space': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'parse',
      type: 'any',
      parameters: {'text': 'string'},
      optionalParameters: {'reviver': 'Function'},
    ),
  ],
  'Math': [
    CodeFieldPrompt(word: 'PI', type: 'number'),
    CodeFieldPrompt(word: 'E', type: 'number'),
    CodeFunctionPrompt(word: 'random', type: 'number'),
    CodeFunctionPrompt(
      word: 'floor',
      type: 'number',
      parameters: {'x': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'ceil',
      type: 'number',
      parameters: {'x': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'round',
      type: 'number',
      parameters: {'x': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'abs',
      type: 'number',
      parameters: {'x': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'min',
      type: 'number',
      parameters: {'a': 'number', 'b': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'max',
      type: 'number',
      parameters: {'a': 'number', 'b': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'pow',
      type: 'number',
      parameters: {'x': 'number', 'y': 'number'},
    ),
    CodeFunctionPrompt(
      word: 'sqrt',
      type: 'number',
      parameters: {'x': 'number'},
    ),
  ],
  'Object': [
    CodeFunctionPrompt(
      word: 'keys',
      type: 'string[]',
      parameters: {'obj': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'values',
      type: 'any[]',
      parameters: {'obj': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'entries',
      type: 'any[][]',
      parameters: {'obj': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'assign',
      type: 'any',
      parameters: {'target': 'any', 'source': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'freeze',
      type: 'any',
      parameters: {'obj': 'any'},
    ),
  ],
  'Array': [
    CodeFunctionPrompt(
      word: 'from',
      type: 'any[]',
      parameters: {'iterable': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'isArray',
      type: 'boolean',
      parameters: {'value': 'any'},
    ),
    CodeFunctionPrompt(word: 'of', type: 'any[]', parameters: {'items': 'any'}),
  ],
  'Promise': [
    CodeFunctionPrompt(
      word: 'resolve',
      type: 'Promise<any>',
      parameters: {'value': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'reject',
      type: 'Promise<never>',
      parameters: {'reason': 'any'},
    ),
    CodeFunctionPrompt(
      word: 'all',
      type: 'Promise<any[]>',
      parameters: {'iterable': 'Promise[]'},
    ),
    CodeFunctionPrompt(
      word: 'race',
      type: 'Promise<any>',
      parameters: {'iterable': 'Promise[]'},
    ),
  ],
};
