import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_bar.dart' as local_search;
import '../utils/data_formatter.dart';
import 'enhanced_editor_screen.dart';
import 'settings_screen.dart';

/// Home screen displaying all notes with search and create functionality.
class HomeScreen extends StatefulWidget {
  final NotesService notesService;

  const HomeScreen({super.key, required this.notesService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isGridView = false; // Grid/List view toggle

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await widget.notesService.getAll();
      setState(() {
        _notes = notes;
        _applySearch(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notes: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _applySearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateToEditor({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnhancedEditorScreen(
          notesService: widget.notesService,
          note: note,
          onSave: _loadNotes,
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    try {
      await widget.notesService.delete(note.id);
      await _loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting note: $e')),
      );
    }
  }

  Future<void> _togglePin(Note note) async {
    try {
      await widget.notesService.togglePin(note);
      await _loadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar area
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.12),
                            child: Icon(Icons.note_alt_outlined, color: theme.colorScheme.onPrimary),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(_isGridView ? Icons.view_agenda_rounded : Icons.grid_view_rounded, color: theme.colorScheme.onPrimary),
                            onPressed: () => setState(() => _isGridView = !_isGridView),
                            tooltip: _isGridView ? 'List View' : 'Grid View',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.settings_rounded, color: theme.colorScheme.onPrimary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsScreen(
                                    onThemeChanged: (mode) {},
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('My Notes', style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                      const SizedBox(height: 6),
                      Text('${_filteredNotes.length} ${_filteredNotes.length == 1 ? 'note' : 'notes'}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.9))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Search bar (use SearchBar widget)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: local_search.SearchBar(onChanged: _applySearch),
            ),
          ),

          // Pinned notes strip (if any)
          if (_filteredNotes.any((n) => n.pinned))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 0, 12),
                child: SizedBox(
                  height: 126,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 0, right: 16),
                    itemCount: _filteredNotes.where((n) => n.pinned).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final pinned = _filteredNotes.where((n) => n.pinned).toList()[index];
                      return SizedBox(
                        width: 320,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                          child: InkWell(
                            onTap: () => _navigateToEditor(note: pinned),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pinned.title.isEmpty ? 'Untitled' : pinned.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.headlineSmall,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.push_pin, size: 16, color: Colors.orange.shade700),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      pinned.content.isEmpty ? 'No content' : pinned.content,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(DateFormatter.formatDate(pinned.updatedAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          
          // Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filteredNotes.isEmpty
                  ? SliverFillRemaining(
                      child: EmptyState(searchQuery: _searchQuery),
                    )
                  : _isGridView
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final note = _filteredNotes[index];
                                return NoteCard(
                                  note: note,
                                  onTap: () => _navigateToEditor(note: note),
                                  onDelete: () => _deleteNote(note),
                                  onPinChanged: (_) => _togglePin(note),
                                );
                              },
                              childCount: _filteredNotes.length,
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final note = _filteredNotes[index];
                                return NoteCard(
                                  note: note,
                                  onTap: () => _navigateToEditor(note: note),
                                  onDelete: () => _deleteNote(note),
                                  onPinChanged: (_) => _togglePin(note),
                                );
                              },
                              childCount: _filteredNotes.length,
                            ),
                          ),
                        ),
          
          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () => _navigateToEditor(),
        label: const Text('New Note'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}