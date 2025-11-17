import 'package:flutter/material.dart';
import '../models/text_format.dart';

/// Controller for managing rich text with formatting
class RichTextFieldController extends TextEditingController {
  List<FormattedTextSegment> _segments = [];
  TextStyle _pendingStyle = const TextStyle();
  bool _hasPendingStyle = false;
  
  RichTextFieldController({super.text, TextFormatting? formatting}) {
    if (formatting != null) {
      _segments = formatting.segments;
    }
  }
  
  @override
  set text(String newText) {
    super.text = newText;
    _cleanupSegments();
  }

  /// Get current formatting
  TextFormatting get formatting => TextFormatting(
        plainText: text,
        segments: _segments,
      );

  /// Set formatting from TextFormatting object
  set formatting(TextFormatting value) {
    _segments = value.segments;
    text = value.plainText;
    _cleanupSegments();
  }
  
  /// Clean up invalid segments (beyond text length)
  void _cleanupSegments() {
    final textLength = text.length;
    _segments.removeWhere((seg) => 
      seg.start < 0 || 
      seg.end > textLength || 
      seg.start >= seg.end
    );
    
    // Clamp remaining segments to valid range
    _segments = _segments.map((seg) {
      final start = seg.start.clamp(0, textLength);
      final end = seg.end.clamp(start, textLength);
      return FormattedTextSegment(
        text: text.substring(start, end),
        style: seg.style,
        start: start,
        end: end,
      );
    }).where((seg) => seg.start < seg.end).toList();
  }

  /// Get pending style for new text (MS Word-like behavior)
  TextStyle get pendingStyle => _hasPendingStyle ? _pendingStyle : const TextStyle();
  
  /// Get current text style at cursor position
  TextStyle getCurrentStyle(int cursorPosition) {
    // If we have pending style, return it
    if (_hasPendingStyle) {
      return _pendingStyle;
    }
    
    for (var segment in _segments) {
      if (cursorPosition >= segment.start && cursorPosition < segment.end) {
        return segment.style;
      }
    }
    
    // Return style of previous character if cursor is at segment boundary
    if (cursorPosition > 0) {
      for (var segment in _segments) {
        if (cursorPosition == segment.end && segment.end > segment.start) {
          return segment.style;
        }
      }
    }
    
    return const TextStyle();
  }
  
  /// Set pending style (for MS Word-like continuous formatting)
  void setPendingStyle(TextStyle style) {
    _pendingStyle = style;
    _hasPendingStyle = true;
    notifyListeners();
  }
  
  /// Clear pending style
  void clearPendingStyle() {
    _hasPendingStyle = false;
    _pendingStyle = const TextStyle();
  }

  /// Apply formatting to selected text OR set pending style for cursor
  void applyFormatting(
    TextSelection selection, {
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    Color? textColor,
    Color? backgroundColor,
    double? fontSize,
  }) {
    // Get current style at selection or cursor
    final currentStyle = getCurrentStyle(selection.start);

    // Create new style with modifications
    final newStyle = TextStyle(
      fontWeight: bold == true
          ? FontWeight.bold
          : (bold == false ? FontWeight.normal : currentStyle.fontWeight),
      fontStyle: italic == true
          ? FontStyle.italic
          : (italic == false ? FontStyle.normal : currentStyle.fontStyle),
      decoration: underline == true
          ? TextDecoration.underline
          : strikethrough == true
              ? TextDecoration.lineThrough
              : (underline == false || strikethrough == false
                  ? TextDecoration.none
                  : currentStyle.decoration),
      color: textColor ?? currentStyle.color,
      backgroundColor: backgroundColor,
      fontSize: fontSize ?? currentStyle.fontSize,
    );

    // If no text is selected, set pending style for next input
    if (selection.start == selection.end) {
      setPendingStyle(newStyle);
      return;
    }

    // Remove overlapping segments
    _segments.removeWhere((segment) =>
        (segment.start >= selection.start && segment.start < selection.end) ||
        (segment.end > selection.start && segment.end <= selection.end) ||
        (segment.start < selection.start && segment.end > selection.end));

    // Add new segment
    final newSegment = FormattedTextSegment(
      text: text.substring(selection.start, selection.end),
      style: newStyle,
      start: selection.start,
      end: selection.end,
    );

    _segments.add(newSegment);
    _segments.sort((a, b) => a.start.compareTo(b.start));
    
    _cleanupSegments();
    notifyListeners();
  }

  /// Toggle bold on selection OR at cursor
  void toggleBold(TextSelection selection) {
    final current = getCurrentStyle(selection.start);
    applyFormatting(
      selection,
      bold: current.fontWeight != FontWeight.bold,
    );
  }

  /// Toggle italic on selection
  void toggleItalic(TextSelection selection) {
    final current = getCurrentStyle(selection.start);
    applyFormatting(
      selection,
      italic: current.fontStyle != FontStyle.italic,
    );
  }

  /// Toggle underline on selection
  void toggleUnderline(TextSelection selection) {
    final current = getCurrentStyle(selection.start);
    applyFormatting(
      selection,
      underline: current.decoration != TextDecoration.underline,
    );
  }

  /// Toggle strikethrough on selection
  void toggleStrikethrough(TextSelection selection) {
    final current = getCurrentStyle(selection.start);
    applyFormatting(
      selection,
      strikethrough: current.decoration != TextDecoration.lineThrough,
    );
  }

  /// Apply text color to selection
  void applyTextColor(TextSelection selection, Color color) {
    applyFormatting(selection, textColor: color);
  }

  /// Apply highlight/background color to selection
  void applyHighlightColor(TextSelection selection, Color color) {
    applyFormatting(selection, backgroundColor: color);
  }

  /// Apply heading style
  void applyHeading(TextSelection selection, int level) {
    double fontSize;
    switch (level) {
      case 1:
        fontSize = 32;
        break;
      case 2:
        fontSize = 24;
        break;
      case 3:
        fontSize = 20;
        break;
      default:
        fontSize = 16;
    }
    applyFormatting(
      selection,
      fontSize: fontSize,
      bold: true,
    );
  }

  /// Clear all formatting
  void clearFormatting() {
    _segments.clear();
    clearPendingStyle();
    notifyListeners();
  }
  
  /// Insert bullet point at cursor or convert selection to bullet
  void insertBulletPoint(TextSelection selection) {
    final cursorPos = selection.start;
    
    // Find start of current line
    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    // Find end of current line
    int lineEnd = cursorPos;
    while (lineEnd < text.length && text[lineEnd] != '\n') {
      lineEnd++;
    }
    
    // Get current line text
    final currentLine = text.substring(lineStart, lineEnd);
    
    // Check if line already has bullet or numbered list
    if (currentLine.startsWith('• ') || 
        currentLine.startsWith('  • ') ||  // Sub-bullet
        RegExp(r'^\d+\.\s').hasMatch(currentLine) ||
        currentLine.startsWith('> ') ||
        currentLine.trim().isEmpty) {
      return; // Already has marker or empty
    }
    
    // Determine indent level (for sub-bullets in future)
    int indentLevel = 0;
    final prevLineStart = lineStart > 0 ? lineStart - 1 : 0;
    if (prevLineStart > 0) {
      int prevLineStartPos = prevLineStart;
      while (prevLineStartPos > 0 && text[prevLineStartPos - 1] != '\n') {
        prevLineStartPos--;
      }
      final prevLine = text.substring(prevLineStartPos, prevLineStart);
      if (prevLine.startsWith('  • ')) {
        indentLevel = 1; // Sub-bullet
      }
    }
    
    // Insert bullet at line start
    final bullet = indentLevel > 0 ? '  • ' : '• ';
    final newText = text.substring(0, lineStart) + bullet + text.substring(lineStart);
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + bullet.length),
    );
    
    // Adjust segments
    for (var i = 0; i < _segments.length; i++) {
      final seg = _segments[i];
      if (seg.start >= lineStart) {
        _segments[i] = FormattedTextSegment(
          text: seg.text,
          style: seg.style,
          start: seg.start + bullet.length,
          end: seg.end + bullet.length,
        );
      }
    }
    
    notifyListeners();
  }
  
  /// Insert numbered list item
  void insertNumberedList(TextSelection selection) {
    final cursorPos = selection.start;
    
    // Find start of current line
    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    // Count existing numbered items to get next number
    int itemNumber = 1;
    final lines = text.substring(0, lineStart).split('\n');
    for (var line in lines.reversed) {
      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        final match = RegExp(r'^(\d+)\.').firstMatch(line);
        if (match != null) {
          itemNumber = int.parse(match.group(1)!) + 1;
          break;
        }
      }
    }
    
    // Insert number at line start
    final prefix = '$itemNumber. ';
    final newText = text.substring(0, lineStart) + prefix + text.substring(lineStart);
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + prefix.length),
    );
    
    // Adjust segments
    for (var i = 0; i < _segments.length; i++) {
      final seg = _segments[i];
      if (seg.start >= lineStart) {
        _segments[i] = FormattedTextSegment(
          text: seg.text,
          style: seg.style,
          start: seg.start + prefix.length,
          end: seg.end + prefix.length,
        );
      }
    }
    
    notifyListeners();
  }
  
  /// Insert code block or format selection as code
  void insertCodeBlock(TextSelection selection) {
    if (selection.start == selection.end) {
      // Insert code block template
      const codeTemplate = '\n```\n\n```\n';
      final cursorPos = selection.start;
      final newText = text.substring(0, cursorPos) + codeTemplate + text.substring(cursorPos);
      value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos + 5), // Position inside code block
      );
    } else {
      // Wrap selection in code markers
      final selectedText = text.substring(selection.start, selection.end);
      final codeText = '`$selectedText`';
      final newText = text.substring(0, selection.start) + codeText + text.substring(selection.end);
      value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + codeText.length),
      );
    }
    
    notifyListeners();
  }
  
  /// Insert quote
  void insertQuote(TextSelection selection) {
    final cursorPos = selection.start;
    
    // Find start of current line
    int lineStart = cursorPos;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    // Check if line already has quote marker
    if (lineStart < text.length && text.substring(lineStart).startsWith('> ')) {
      return; // Already has quote
    }
    
    // Insert quote marker at line start
    final newText = text.substring(0, lineStart) + '> ' + text.substring(lineStart);
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + 2),
    );
    
    // Adjust segments
    for (var i = 0; i < _segments.length; i++) {
      final seg = _segments[i];
      if (seg.start >= lineStart) {
        _segments[i] = FormattedTextSegment(
          text: seg.text,
          style: seg.style,
          start: seg.start + 2,
          end: seg.end + 2,
        );
      }
    }
    
    notifyListeners();
  }

  /// Check if current selection has specific formatting
  bool hasFormatting(
    TextSelection selection, {
    bool? bold,
    bool? italic,
    bool? underline,
  }) {
    if (selection.start == selection.end) return false;

    final style = getCurrentStyle(selection.start);

    if (bold != null && (style.fontWeight == FontWeight.bold) != bold) {
      return false;
    }
    if (italic != null && (style.fontStyle == FontStyle.italic) != italic) {
      return false;
    }
    if (underline != null &&
        (style.decoration == TextDecoration.underline) != underline) {
      return false;
    }

    return true;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Ensure segments are valid before building
    _cleanupSegments();
    
    if (_segments.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    return formatting.toTextSpan(baseStyle: style);
  }
}
