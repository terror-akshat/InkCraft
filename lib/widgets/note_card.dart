import 'package:flutter/material.dart';
import '../models/note.dart';
import '../themes/app_themes.dart';
import '../utils/data_formatter.dart';

/// Cleaner, card-first note tile with a colored accent strip.
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onPinChanged;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onPinChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppThemes.hexToColor(note.color);

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Accent strip
              Container(
                width: 6,
                height: 110,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title.isEmpty ? 'Untitled' : note.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          if (note.pinned)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.push_pin, size: 16, color: Colors.orange.shade700),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Content preview
                      if (note.formatting != null && note.formatting!.segments.isNotEmpty)
                        RichText(
                          text: note.formatting!.toTextSpan(
                            baseStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          note.content.isEmpty ? 'No content' : note.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (note.tags.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: note.tags.take(2).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.formatDate(note.updatedAt),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
