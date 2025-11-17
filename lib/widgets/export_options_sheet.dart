import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/note.dart';
import '../services/share_service.dart';

/// Bottom sheet for export and share options
class ExportOptionsSheet extends StatelessWidget {
  final Note note;
  final ShareService _shareService = ShareService();

  ExportOptionsSheet({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Share & Export',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Options
          _buildOption(
            context,
            icon: Icons.picture_as_pdf,
            iconColor: Colors.red,
            title: 'Export as PDF',
            subtitle: 'Colorful formatted PDF',
            onTap: () => _exportAsPdf(context),
          ),
          _buildOption(
            context,
            icon: Icons.print,
            iconColor: Colors.blue,
            title: 'Print',
            subtitle: 'Print or save as PDF',
            onTap: () => _printNote(context),
          ),
          _buildOption(
            context,
            icon: Icons.text_fields,
            iconColor: Colors.green,
            title: 'Export as Text',
            subtitle: 'Plain text format',
            onTap: () => _exportAsText(context),
          ),
          _buildOption(
            context,
            icon: Icons.code,
            iconColor: Colors.orange,
            title: 'Export as Markdown',
            subtitle: 'Markdown format',
            onTap: () => _exportAsMarkdown(context),
          ),
          _buildOption(
            context,
            icon: Icons.html,
            iconColor: Colors.purple,
            title: 'Export as HTML',
            subtitle: 'Web page format',
            onTap: () => _exportAsHtml(context),
          ),
          const Divider(),
          _buildOption(
            context,
            icon: Icons.share,
            iconColor: Colors.teal,
            title: 'Share Content',
            subtitle: 'Share via apps',
            onTap: () => _shareContent(context),
          ),
          _buildOption(
            context,
            icon: Icons.copy,
            iconColor: Colors.indigo,
            title: 'Copy to Clipboard',
            subtitle: 'Copy note content',
            onTap: () => _copyToClipboard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _exportAsPdf(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Generating PDF...');
      await _shareService.shareAsPdf(note);
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessSnackBar(context, 'PDF exported successfully');
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar(context, 'Failed to export PDF: $e');
    }
  }

  Future<void> _printNote(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Preparing print...');
      final pdfFile = await _shareService.saveAsPdf(note);
      final pdfBytes = await pdfFile.readAsBytes();
      Navigator.of(context).pop(); // Close loading dialog
      
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: note.title,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar(context, 'Failed to print: $e');
    }
  }

  Future<void> _exportAsText(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Exporting as text...');
      await _shareService.shareAsText(note);
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessSnackBar(context, 'Text exported successfully');
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar(context, 'Failed to export text: $e');
    }
  }

  Future<void> _exportAsMarkdown(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Exporting as markdown...');
      await _shareService.shareAsMarkdown(note);
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessSnackBar(context, 'Markdown exported successfully');
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar(context, 'Failed to export markdown: $e');
    }
  }

  Future<void> _exportAsHtml(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Exporting as HTML...');
      await _shareService.shareAsHtml(note);
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessSnackBar(context, 'HTML exported successfully');
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar(context, 'Failed to export HTML: $e');
    }
  }

  Future<void> _shareContent(BuildContext context) async {
    try {
      await _shareService.shareContent(note);
      _showSuccessSnackBar(context, 'Shared successfully');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share: $e');
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      await _shareService.copyToClipboard(note);
      _showSuccessSnackBar(context, 'Copied to clipboard');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to copy: $e');
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Show export options bottom sheet
Future<void> showExportOptions(BuildContext context, Note note) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ExportOptionsSheet(note: note),
  );
}
