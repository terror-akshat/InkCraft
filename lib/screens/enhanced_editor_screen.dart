import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../utils/rich_text_controller.dart';
import '../widgets/formatting_toolbar.dart';
import '../widgets/export_options_sheet.dart';

/// Enhanced editor screen for creating and editing notes with rich text formatting
class EnhancedEditorScreen extends StatefulWidget {
  final NotesService notesService;
  final Note? note;
  final VoidCallback onSave;

  const EnhancedEditorScreen({
    super.key,
    required this.notesService,
    this.note,
    required this.onSave,
  });

  @override
  State<EnhancedEditorScreen> createState() => _EnhancedEditorScreenState();
}

class _EnhancedEditorScreenState extends State<EnhancedEditorScreen> {
  late TextEditingController _titleController;
  late RichTextFieldController _contentController;
  bool _hasChanges = false;
  bool _isSaving = false;
  final bool _showToolbar = true;
  
  // Current formatting state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  Color _currentTextColor = Colors.black;
  Color? _currentHighlightColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = RichTextFieldController(
      text: widget.note?.content ?? '',
      formatting: widget.note?.formatting,
    );
    
    _titleController.addListener(() => _markChanged());
    _contentController.addListener(() {
      _markChanged();
      _updateFormattingState();
    });
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _updateFormattingState() {
    // Always get current style from controller (includes pending style)
    final cursorPos = _contentController.selection.start;
    final style = _contentController.getCurrentStyle(cursorPos);
    
    setState(() {
      _isBold = style.fontWeight == FontWeight.bold;
      _isItalic = style.fontStyle == FontStyle.italic;
      _isUnderline = style.decoration == TextDecoration.underline;
      _isStrikethrough = style.decoration == TextDecoration.lineThrough;
      _currentTextColor = style.color ?? Colors.black;
      _currentHighlightColor = style.backgroundColor;
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.note == null) {
        // Create new note
        await widget.notesService.create(
          _titleController.text,
          _contentController.text,
        );
      } else {
        // Update existing note with formatting
        await widget.notesService.update(
          widget.note!.copyWith(
            title: _titleController.text,
            content: _contentController.text,
            formatting: _contentController.formatting,
          ),
        );
      }

      setState(() => _hasChanges = false);
      widget.onSave();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Note saved successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _onWillPop() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _showExportOptions() {
    if (widget.note != null) {
      showExportOptions(context, widget.note!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the note first')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _contentController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final charCount = _contentController.text.length;
    final readingTime = (wordCount / 200).ceil(); // Assuming 200 words per minute

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          actions: [
            // Export button (only for existing saved notes)
            if (widget.note != null && !_hasChanges)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _showExportOptions,
                tooltip: 'Export & Share',
              ),
            
            // Save status
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Unsaved',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                ),
              ),
            
            // Save button
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isSaving ? null : _saveNote,
              tooltip: 'Save',
            ),
          ],
        ),
        body: Column(
          children: [
            // Content area with enhanced design
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field with enhanced styling
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Note Title',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        textInputAction: TextInputAction.next,
                        maxLines: null,
                      ),
                      const SizedBox(height: 8),
                      
                      // Divider
                      Container(
                        height: 2,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.purple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Rich text content field with enhanced styling
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Start typing your note here...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        onTap: () {
                          // Update formatting state when tapping
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted) {
                              _updateFormattingState();
                            }
                          });
                        },
                      ),
                      
                      const SizedBox(height: 100), // Extra space for toolbar
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced stats bar with icons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[100],
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEnhancedStat(Icons.article_outlined, '$wordCount', 'words'),
                  Container(width: 1, height: 20, color: Colors.grey[400]),
                  _buildEnhancedStat(Icons.text_fields, '$charCount', 'characters'),
                  Container(width: 1, height: 20, color: Colors.grey[400]),
                  _buildEnhancedStat(Icons.schedule, '$readingTime min', 'reading'),
                ],
              ),
            ),

            // Formatting toolbar
            if (_showToolbar)
              FormattingToolbar(
                isBold: _isBold,
                isItalic: _isItalic,
                isUnderline: _isUnderline,
                isStrikethrough: _isStrikethrough,
                currentTextColor: _currentTextColor,
                currentHighlightColor: _currentHighlightColor,
                onBold: () {
                  _contentController.toggleBold(_contentController.selection);
                  _updateFormattingState();
                },
                onItalic: () {
                  _contentController.toggleItalic(_contentController.selection);
                  _updateFormattingState();
                },
                onUnderline: () {
                  _contentController.toggleUnderline(_contentController.selection);
                  _updateFormattingState();
                },
                onStrikethrough: () {
                  _contentController.toggleStrikethrough(_contentController.selection);
                  _updateFormattingState();
                },
                onH1: () => _contentController.applyHeading(_contentController.selection, 1),
                onH2: () => _contentController.applyHeading(_contentController.selection, 2),
                onH3: () => _contentController.applyHeading(_contentController.selection, 3),
                onBulletList: () => _contentController.insertBulletPoint(_contentController.selection),
                onNumberedList: () => _contentController.insertNumberedList(_contentController.selection),
                onQuote: () => _contentController.insertQuote(_contentController.selection),
                onCode: () => _contentController.insertCodeBlock(_contentController.selection),
                onTextColor: (color) {
                  _contentController.applyTextColor(_contentController.selection, color);
                  setState(() => _currentTextColor = color);
                },
                onHighlightColor: (color) {
                  _contentController.applyHighlightColor(_contentController.selection, color);
                  setState(() => _currentHighlightColor = color);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStat(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
