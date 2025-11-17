import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';

/// Editor screen for creating and editing notes.
/// Shows unsaved changes confirmation dialog.
class EditorScreen extends StatefulWidget {
  final NotesService notesService;
  final Note? note;
  final VoidCallback onSave;

  const EditorScreen({
    super.key,
    required this.notesService,
    this.note,
    required this.onSave,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    
    _titleController.addListener(() => _markChanged());
    _contentController.addListener(() => _markChanged());
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
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
        // Update existing note
        await widget.notesService.update(
          widget.note!.copyWith(
            title: _titleController.text,
            content: _contentController.text,
          ),
        );
      }

      setState(() => _hasChanges = false);
      widget.onSave();
      
      if (mounted) {
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
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard ?? false) {
      Navigator.of(context).pop();
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 2,
          actions: [
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Unsaved',
                          style: TextStyle(color: Colors.orange),
                        ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.displayLarge,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Start typing...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                heroTag: 'editor_save_fab',
                onPressed: _isSaving ? null : _saveNote,
                label: const Text('Save'),
                icon: const Icon(Icons.check),
              )
            : null,
      ),
    );
  }
}