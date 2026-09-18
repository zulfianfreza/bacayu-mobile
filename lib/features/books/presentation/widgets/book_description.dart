import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Renders a book description.
///
/// Descriptions come back from Google Books as an HTML *fragment*, not a
/// document — a handful of `<p>`/`<br>`/`<b>`/`<i>`/`<ul>` tags and the usual
/// entities. This deliberately is not an HTML engine: it renders that subset
/// properly and drops anything else, so a stray tag (or one Google never
/// closed) can never end up printed at the reader. Plain text passes straight
/// through as a single paragraph.
class BookDescription extends StatelessWidget {
  const BookDescription({
    super.key,
    required this.html,
    this.style,
    this.paragraphSpacing = 8,
  });

  final String html;

  /// Defaults to the app's body style.
  final TextStyle? style;

  /// Vertical gap between two blocks.
  final double paragraphSpacing;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTypography.body;
    final blocks = parseDescriptionHtml(html, base);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: EdgeInsets.only(
              left: block.isListItem ? 12 : 0,
              bottom: paragraphSpacing,
            ),
            child: Text.rich(
              block.isListItem
                  ? TextSpan(
                      children: [
                        const TextSpan(text: '•  '),
                        block.span,
                      ],
                    )
                  : block.span,
            ),
          ),
      ],
    );
  }
}

/// One block of a description: a paragraph, or one bullet of a list.
typedef DescriptionBlock = ({InlineSpan span, bool isListItem});

/// Splits [html] into blocks and applies [base] to every span it produces.
///
/// Pure, so the tag handling can be tested without pumping a widget.
List<DescriptionBlock> parseDescriptionHtml(String html, TextStyle base) {
  // A `<br>` is content, not structure: it becomes a line break inside the
  // block it appears in.
  final text = html.replaceAll(
    RegExp(r'<br\s*/?>', caseSensitive: false),
    '\n',
  );

  final boundary = RegExp(
    r'<(/?)(p|div|ul|ol|li)\b[^>]*>',
    caseSensitive: false,
  );

  final blocks = <DescriptionBlock>[];
  final buffer = StringBuffer();
  var isListItem = false;

  void flush() {
    final chunk = buffer.toString();
    buffer.clear();

    // Block tags come in pairs, so half the flushes are empty by construction.
    if (_plainText(chunk).trim().isEmpty) return;
    blocks.add((
      span: TextSpan(children: _inlineSpans(chunk, base)),
      isListItem: isListItem,
    ));
  }

  var index = 0;
  for (final match in boundary.allMatches(text)) {
    buffer.write(text.substring(index, match.start));
    index = match.end;

    final closing = match.group(1) == '/';
    final tag = match.group(2)!.toLowerCase();

    if (tag == 'li') {
      flush();
      isListItem = !closing;
    } else {
      // p / div / ul / ol only end the block that just finished.
      flush();
    }
  }
  buffer.write(text.substring(index));
  flush();

  return blocks;
}

/// Builds the styled runs for one block: bold, italic, and everything else.
List<InlineSpan> _inlineSpans(String raw, TextStyle base) {
  // Group 1 is the closing slash, group 2 the tag — same shape as the block
  // boundary above, so both read the match the same way.
  final emphasis = RegExp(r'<(/)?(b|strong|i|em)\s*>', caseSensitive: false);
  final spans = <InlineSpan>[];
  var bold = false;
  var italic = false;
  var index = 0;

  void add(String chunk) {
    final text = _decodeEntities(_stripTags(chunk));
    if (text.isEmpty) return;
    spans.add(
      TextSpan(
        text: text,
        style: base.copyWith(
          fontWeight: bold ? FontWeight.w700 : null,
          fontStyle: italic ? FontStyle.italic : null,
        ),
      ),
    );
  }

  for (final match in emphasis.allMatches(raw)) {
    add(raw.substring(index, match.start));
    index = match.end;

    final closing = match.group(1) == '/';
    final tag = match.group(2)!.toLowerCase();
    if (tag == 'b' || tag == 'strong') {
      bold = !closing;
    } else {
      italic = !closing;
    }
  }
  add(raw.substring(index));

  return spans;
}

String _stripTags(String input) => input.replaceAll(RegExp(r'<[^>]*>'), '');

String _plainText(String input) => _decodeEntities(_stripTags(input));

const _entities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'mdash': '—',
  'ndash': '–',
  'hellip': '…',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
};

String _decodeEntities(String input) {
  if (!input.contains('&')) return input;

  return input.replaceAllMapped(RegExp(r'&(#[xX]?[0-9a-fA-F]+|[a-zA-Z]+);'), (
    match,
  ) {
    final body = match.group(1)!;

    if (body.startsWith('#')) {
      final isHex = body.length > 1 && (body[1] == 'x' || body[1] == 'X');
      final code = int.tryParse(
        body.substring(isHex ? 2 : 1),
        radix: isHex ? 16 : 10,
      );
      return code == null ? match.group(0)! : String.fromCharCode(code);
    }

    // Unknown entity: leave it exactly as it came, rather than swallowing it.
    return _entities[body.toLowerCase()] ?? match.group(0)!;
  });
}
