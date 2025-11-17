import 'package:flutter/material.dart';

/// Represents a segment of text with formatting
class FormattedTextSegment {
  final String text;
  final TextStyle style;
  final int start;
  final int end;

  FormattedTextSegment({
    required this.text,
    required this.style,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'start': start,
      'end': end,
      'bold': style.fontWeight == FontWeight.bold,
      'italic': style.fontStyle == FontStyle.italic,
      'underline': style.decoration == TextDecoration.underline,
      'strikethrough': style.decoration == TextDecoration.lineThrough,
      'fontSize': style.fontSize,
      'color': style.color?.value,
      'backgroundColor': style.backgroundColor?.value,
    };
  }

  factory FormattedTextSegment.fromJson(Map<String, dynamic> json) {
    return FormattedTextSegment(
      text: json['text'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      style: TextStyle(
        fontWeight: json['bold'] == true ? FontWeight.bold : FontWeight.normal,
        fontStyle: json['italic'] == true ? FontStyle.italic : FontStyle.normal,
        decoration: json['underline'] == true
            ? TextDecoration.underline
            : json['strikethrough'] == true
                ? TextDecoration.lineThrough
                : TextDecoration.none,
        fontSize: json['fontSize'] as double?,
        color: json['color'] != null
            ? Color(json['color'] as int)
            : null,
        backgroundColor: json['backgroundColor'] != null
            ? Color(json['backgroundColor'] as int)
            : null,
      ),
    );
  }
}

/// Formatting types available
enum FormatType {
  bold,
  italic,
  underline,
  strikethrough,
  heading1,
  heading2,
  heading3,
  bulletList,
  numberedList,
  code,
  quote,
}

/// Text formatting data structure
class TextFormatting {
  final List<FormattedTextSegment> segments;
  final String plainText;

  TextFormatting({
    required this.segments,
    required this.plainText,
  });

  Map<String, dynamic> toJson() {
    return {
      'plainText': plainText,
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }

  factory TextFormatting.fromJson(Map<String, dynamic> json) {
    return TextFormatting(
      plainText: json['plainText'] as String? ?? '',
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => FormattedTextSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory TextFormatting.plain(String text) {
    return TextFormatting(
      plainText: text,
      segments: [],
    );
  }

  /// Convert to TextSpan for rendering with support for quotes and code blocks
  TextSpan toTextSpan({TextStyle? baseStyle}) {
    if (plainText.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    // Build spans with formatting
    final List<TextSpan> spans = [];
    int currentIndex = 0;
    final textLength = plainText.length;
    
    // Filter and sort valid segments
    final validSegments = segments.where((seg) => 
      seg.start >= 0 && 
      seg.end <= textLength && 
      seg.start < seg.end
    ).toList()..sort((a, b) => a.start.compareTo(b.start));
    
    for (var segment in validSegments) {
      // Skip if segment overlaps with already processed text
      if (segment.start < currentIndex) continue;
      
      // Add plain text before this segment
      if (segment.start > currentIndex) {
        spans.add(TextSpan(
          text: plainText.substring(currentIndex, segment.start),
          style: baseStyle,
        ));
      }
      
      // Add formatted segment with bounds checking
      final segStart = segment.start.clamp(0, textLength);
      final segEnd = segment.end.clamp(segStart, textLength);
      
      if (segStart < segEnd) {
        spans.add(TextSpan(
          text: plainText.substring(segStart, segEnd),
          style: baseStyle?.merge(segment.style) ?? segment.style,
        ));
        currentIndex = segEnd;
      }
    }
    
    // Add remaining plain text
    if (currentIndex < textLength) {
      spans.add(TextSpan(
        text: plainText.substring(currentIndex),
        style: baseStyle,
      ));
    }
    
    return TextSpan(
      children: spans.isEmpty ? [TextSpan(text: plainText, style: baseStyle)] : spans,
      style: baseStyle,
    );
  }
}
