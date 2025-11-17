import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

/// Service for exporting notes to various formats
class ExportService {
  /// Export note as plain text
  Future<File> exportAsText(Note note) async {
    final directory = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln(note.title);
    buffer.writeln('=' * note.title.length);
    buffer.writeln();
    buffer.writeln('Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(note.createdAt)}');
    if (note.updatedAt != note.createdAt) {
      buffer.writeln('Updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(note.updatedAt)}');
    }
    if (note.tags.isNotEmpty) {
      buffer.writeln('Tags: ${note.tags.join(', ')}');
    }
    buffer.writeln();
    buffer.writeln(note.content);

    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Export note as Markdown
  Future<File> exportAsMarkdown(Note note) async {
    final directory = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.md';
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln('# ${note.title}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('**Created:** ${DateFormat('MMM dd, yyyy').format(note.createdAt)}');
    if (note.updatedAt != note.createdAt) {
      buffer.writeln('**Updated:** ${DateFormat('MMM dd, yyyy').format(note.updatedAt)}');
    }
    if (note.tags.isNotEmpty) {
      buffer.writeln('**Tags:** ${note.tags.map((t) => '`$t`').join(', ')}');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    
    // Process content with basic markdown formatting
    buffer.writeln(note.content);

    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Export note as HTML
  Future<File> exportAsHtml(Note note) async {
    final directory = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.html';
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('  <title>${note.title}</title>');
    buffer.writeln('  <style>');
    buffer.writeln('    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; }');
    buffer.writeln('    h1 { color: ${note.color}; border-left: 5px solid ${note.color}; padding-left: 15px; }');
    buffer.writeln('    .metadata { color: #666; font-size: 0.9em; margin-bottom: 20px; }');
    buffer.writeln('    .tag { background: ${note.color}; color: white; padding: 3px 10px; border-radius: 10px; font-size: 0.8em; margin-right: 5px; }');
    buffer.writeln('    .content { white-space: pre-wrap; }');
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <h1>${note.title}</h1>');
    buffer.writeln('  <div class="metadata">');
    buffer.writeln('    <p><strong>Created:</strong> ${DateFormat('MMM dd, yyyy - hh:mm a').format(note.createdAt)}</p>');
    if (note.updatedAt != note.createdAt) {
      buffer.writeln('    <p><strong>Updated:</strong> ${DateFormat('MMM dd, yyyy - hh:mm a').format(note.updatedAt)}</p>');
    }
    if (note.tags.isNotEmpty) {
      buffer.write('    <p><strong>Tags:</strong> ');
      for (var tag in note.tags) {
        buffer.write('<span class="tag">$tag</span>');
      }
      buffer.writeln('</p>');
    }
    buffer.writeln('  </div>');
    buffer.writeln('  <div class="content">');
    buffer.writeln(_escapeHtml(note.content));
    buffer.writeln('  </div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Export multiple notes as text
  Future<File> exportMultipleAsText(List<Note> notes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_sanitizeFileName(fileName)}_${DateTime.now().millisecondsSinceEpoch}.txt');

    final buffer = StringBuffer();
    buffer.writeln('NOTES EXPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('Exported: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}');
    buffer.writeln('Total Notes: ${notes.length}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      buffer.writeln();
      buffer.writeln('[${ i + 1}/${notes.length}] ${note.title}');
      buffer.writeln('-' * 50);
      buffer.writeln('Created: ${DateFormat('MMM dd, yyyy').format(note.createdAt)}');
      if (note.tags.isNotEmpty) {
        buffer.writeln('Tags: ${note.tags.join(', ')}');
      }
      buffer.writeln();
      buffer.writeln(note.content);
      buffer.writeln();
      buffer.writeln('=' * 50);
    }

    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Get content as string for clipboard
  String getContentAsString(Note note) {
    final buffer = StringBuffer();
    buffer.writeln(note.title);
    buffer.writeln();
    buffer.writeln(note.content);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Created: ${DateFormat('MMM dd, yyyy').format(note.createdAt)}');
    if (note.tags.isNotEmpty) {
      buffer.writeln('Tags: ${note.tags.join(', ')}');
    }
    return buffer.toString();
  }

  /// Sanitize filename
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, name.length > 50 ? 50 : name.length);
  }

  /// Escape HTML special characters
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
