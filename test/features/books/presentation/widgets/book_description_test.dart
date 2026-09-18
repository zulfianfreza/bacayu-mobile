import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/presentation/widgets/book_description.dart';

void main() {
  const base = TextStyle(fontSize: 15);

  List<DescriptionBlock> parse(String html) => parseDescriptionHtml(html, base);

  /// All the text of one block, styles flattened away.
  String textOf(DescriptionBlock block) {
    final buffer = StringBuffer();
    block.span.visitChildren((span) {
      if (span is TextSpan && span.text != null) buffer.write(span.text);
      return true;
    });
    return buffer.toString();
  }

  TextStyle? styleOf(DescriptionBlock block, String text) {
    TextSpan? found;
    block.span.visitChildren((span) {
      if (span is TextSpan && span.text == text) found = span;
      return true;
    });
    return found?.style;
  }

  test('each paragraph becomes its own block', () {
    final blocks = parse('<p>First para.</p><p>Second para.</p>');

    expect(blocks, hasLength(2));
    expect(textOf(blocks[0]), 'First para.');
    expect(textOf(blocks[1]), 'Second para.');
  });

  test('plain text with no markup is a single paragraph', () {
    final blocks = parse('Just a description.');

    expect(blocks, hasLength(1));
    expect(textOf(blocks.single), 'Just a description.');
  });

  test('an unclosed paragraph tag still splits, rather than leaking tags', () {
    final blocks = parse('<p>One<p>Two');

    expect(blocks, hasLength(2));
    expect(textOf(blocks[0]), 'One');
    expect(textOf(blocks[1]), 'Two');
  });

  test('br is a line break inside the same block', () {
    final blocks = parse('Line one<br/>Line two');

    expect(blocks, hasLength(1));
    expect(textOf(blocks.single), 'Line one\nLine two');
  });

  test('bold and italic carry through to the span', () {
    final blocks = parse('<p>plain <b>bold</b> plain <i>italic</i></p>');

    expect(textOf(blocks.single), 'plain bold plain italic');
    expect(styleOf(blocks.single, 'bold')?.fontWeight, FontWeight.w700);
    expect(styleOf(blocks.single, 'italic')?.fontStyle, FontStyle.italic);
    // Untouched runs stay in the base style — no emphasis leaks onto them.
    expect(styleOf(blocks.single, 'plain ')?.fontWeight, isNull);
    expect(styleOf(blocks.single, 'plain ')?.fontStyle, isNull);
  });

  test('list items become bulleted blocks, and the list itself does not', () {
    final blocks = parse('<ul><li>First</li><li>Second</li></ul>');

    expect(blocks, hasLength(2));
    expect(blocks.every((block) => block.isListItem), isTrue);
    expect(textOf(blocks[0]), 'First');
    expect(textOf(blocks[1]), 'Second');
  });

  test('a paragraph after a list is not a list item', () {
    final blocks = parse('<ul><li>Item</li></ul><p>After</p>');

    expect(blocks, hasLength(2));
    expect(blocks[0].isListItem, isTrue);
    expect(blocks[1].isListItem, isFalse);
  });

  test('known entities are decoded, unknown ones survive untouched', () {
    final blocks = parse('Tom &amp; Jerry &mdash; 100&#37; &#x2014; &weird;');

    expect(textOf(blocks.single), 'Tom & Jerry — 100% — &weird;');
  });

  test('tags it does not handle are dropped, their text kept', () {
    final blocks = parse(
      '<p><span class="x">Kept</span><a href="http://e.com">link</a></p>',
    );

    expect(textOf(blocks.single), 'Keptlink');
  });

  test('empty and whitespace-only blocks are dropped', () {
    final blocks = parse('<p></p><p>   </p><p>Real</p>');

    expect(blocks, hasLength(1));
    expect(textOf(blocks.single), 'Real');
  });

  test('the base style is applied to every span', () {
    final blocks = parse('<p>Text</p>');

    final span = blocks.single.span as TextSpan;
    final child = span.children!.single as TextSpan;
    expect(child.style?.fontSize, base.fontSize);
  });
}
