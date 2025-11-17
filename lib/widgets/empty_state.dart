import 'package:flutter/material.dart';

/// Widget displayed when there are no notes to show.
class EmptyState extends StatelessWidget {
  final String? searchQuery;

  const EmptyState({
    super.key,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF667EEA).withOpacity(0.2), Color(0xFF764BA2).withOpacity(0.2)]
                      : [Color(0xFF667EEA).withOpacity(0.1), Color(0xFF764BA2).withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? Color(0xFF667EEA).withOpacity(0.3)
                      : Color(0xFF667EEA).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                searchQuery != null && searchQuery!.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.note_add_rounded,
                size: 80,
                color: isDark ? const Color(0xFF667EEA) : const Color(0xFF764BA2),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              searchQuery != null && searchQuery!.isNotEmpty
                  ? 'No notes found'
                  : 'No notes yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              searchQuery != null && searchQuery!.isNotEmpty
                  ? 'Try adjusting your search terms\nor create a new note'
                  : 'Start organizing your thoughts\nby creating your first note',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Hint with icon
            if (searchQuery == null || searchQuery!.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Color(0xFF667EEA).withOpacity(0.15)
                    : Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF667EEA).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      size: 20,
                      color: isDark ? const Color(0xFF667EEA) : const Color(0xFF764BA2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap the "New Note" button below',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}