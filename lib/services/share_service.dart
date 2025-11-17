import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import 'pdf_generator_service.dart';
import 'export_service.dart';

/// Service for sharing notes in various formats
class ShareService {
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  final ExportService _exportService = ExportService();

  /// Share note as PDF
  Future<void> shareAsPdf(Note note, {bool includeMetadata = true}) async {
    try {
      final pdfFile = await _pdfService.generateNotePdf(
        note,
        includeMetadata: includeMetadata,
      );
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: note.title,
        text: 'Sharing note: ${note.title}',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Share note as plain text
  Future<void> shareAsText(Note note) async {
    try {
      final textFile = await _exportService.exportAsText(note);
      
      await Share.shareXFiles(
        [XFile(textFile.path)],
        subject: note.title,
        text: 'Sharing note: ${note.title}',
      );
    } catch (e) {
      throw Exception('Failed to share text: $e');
    }
  }

  /// Share note as Markdown
  Future<void> shareAsMarkdown(Note note) async {
    try {
      final mdFile = await _exportService.exportAsMarkdown(note);
      
      await Share.shareXFiles(
        [XFile(mdFile.path)],
        subject: note.title,
        text: 'Sharing note: ${note.title}',
      );
    } catch (e) {
      throw Exception('Failed to share markdown: $e');
    }
  }

  /// Share note as HTML
  Future<void> shareAsHtml(Note note) async {
    try {
      final htmlFile = await _exportService.exportAsHtml(note);
      
      await Share.shareXFiles(
        [XFile(htmlFile.path)],
        subject: note.title,
        text: 'Sharing note: ${note.title}',
      );
    } catch (e) {
      throw Exception('Failed to share HTML: $e');
    }
  }

  /// Share note content as plain text (no file)
  Future<void> shareContent(Note note) async {
    try {
      final content = _exportService.getContentAsString(note);
      await Share.share(
        content,
        subject: note.title,
      );
    } catch (e) {
      throw Exception('Failed to share content: $e');
    }
  }

  /// Copy note content to clipboard
  Future<void> copyToClipboard(Note note) async {
    try {
      final content = _exportService.getContentAsString(note);
      await Clipboard.setData(ClipboardData(text: content));
    } catch (e) {
      throw Exception('Failed to copy to clipboard: $e');
    }
  }

  /// Share multiple notes as single PDF
  Future<void> shareMultipleAsPdf(
    List<Note> notes, {
    String fileName = 'Notes Export',
    bool includeMetadata = true,
  }) async {
    try {
      final pdfFile = await _pdfService.generateMultiNotePdf(
        notes,
        includeMetadata: includeMetadata,
        fileName: fileName,
      );
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: fileName,
        text: 'Sharing ${notes.length} notes',
      );
    } catch (e) {
      throw Exception('Failed to share multiple notes as PDF: $e');
    }
  }

  /// Share multiple notes as text file
  Future<void> shareMultipleAsText(
    List<Note> notes, {
    String fileName = 'Notes Export',
  }) async {
    try {
      final textFile = await _exportService.exportMultipleAsText(notes, fileName);
      
      await Share.shareXFiles(
        [XFile(textFile.path)],
        subject: fileName,
        text: 'Sharing ${notes.length} notes',
      );
    } catch (e) {
      throw Exception('Failed to share multiple notes as text: $e');
    }
  }

  /// Save note as file to device
  Future<File> saveAsPdf(Note note, {bool includeMetadata = true}) async {
    return await _pdfService.generateNotePdf(
      note,
      includeMetadata: includeMetadata,
    );
  }

  /// Save note as text file
  Future<File> saveAsText(Note note) async {
    return await _exportService.exportAsText(note);
  }

  /// Save note as markdown file
  Future<File> saveAsMarkdown(Note note) async {
    return await _exportService.exportAsMarkdown(note);
  }

  /// Save note as HTML file
  Future<File> saveAsHtml(Note note) async {
    return await _exportService.exportAsHtml(note);
  }
}
