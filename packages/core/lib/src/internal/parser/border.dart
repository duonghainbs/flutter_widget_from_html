part of '../core_parser.dart';

const kCssBorder = 'border';
const kCssBorderInherit = 'inherit';

final _elementBorder = Expando<CssBorder>();

CssBorder tryParseBorder(BuildMetadata meta) {
  final existing = _elementBorder[meta.element];
  if (existing != null) return existing;
  var border = const CssBorder();

  for (final style in meta.styles) {
    final key = style.property;
    if (!key.startsWith(kCssBorder)) continue;

    final suffix = key.substring(kCssBorder.length);
    if (suffix.isEmpty && style.term == kCssBorderInherit) {
      border = const CssBorder(inherit: true);
      continue;
    }

    final borderSide = _tryParseBorderSide(style.values);
    if (suffix.isEmpty) {
      border = CssBorder(all: borderSide);
    } else {
      switch (suffix) {
        case kSuffixBottom:
        case kSuffixBlockEnd:
          border = border.copyWith(bottom: borderSide);
          break;
        case kSuffixInlineEnd:
          border = border.copyWith(inlineEnd: borderSide);
          break;
        case kSuffixInlineStart:
          border = border.copyWith(inlineStart: borderSide);
          break;
        case kSuffixLeft:
          border = border.copyWith(left: borderSide);
          break;
        case kSuffixRight:
          border = border.copyWith(right: borderSide);
          break;
        case kSuffixTop:
        case kSuffixBlockStart:
          border = border.copyWith(top: borderSide);
          break;
      }
    }
  }

  return _elementBorder[meta.element] = border;
}

CssBorderSide? _tryParseBorderSide(List<css.Expression> expressions) {
  final width =
      expressions.isNotEmpty ? tryParseCssLength(expressions[0]) : null;
  if (width == null || width.number <= 0) return CssBorderSide.none;

  return CssBorderSide(
    color: expressions.length >= 3 ? tryParseColor(expressions[2]) : null,
    style: expressions.length >= 2
        ? tryParseTextDecorationStyle(expressions[1])
        : null,
    width: width,
  );
}
