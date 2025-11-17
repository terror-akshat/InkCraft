import 'text_format.dart';

/// Represents a single note with full CRUD capability.
/// Includes JSON serialization for file-based persistence.
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String color; // Hex color code
  final bool pinned;
  final TextFormatting? formatting; // Rich text formatting
  final List<String> tags; // Tags for organization

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.color = '#FFFFFF',
    this.pinned = false,
    this.formatting,
    this.tags = const [],
  });

  /// Create a copy of this note with optional field updates.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    bool? pinned,
    TextFormatting? formatting,
    List<String>? tags,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
      formatting: formatting ?? this.formatting,
      tags: tags ?? this.tags,
    );
  }

  /// Convert Note to JSON for file storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
      'pinned': pinned,
      'formatting': formatting?.toJson(),
      'tags': tags,
    };
  }

  /// Create Note from JSON.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      color: json['color'] as String? ?? '#FFFFFF',
      pinned: json['pinned'] as bool? ?? false,
      formatting: json['formatting'] != null
          ? TextFormatting.fromJson(json['formatting'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  String toString() => 'Note(id: $id, title: $title, pinned: $pinned)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}