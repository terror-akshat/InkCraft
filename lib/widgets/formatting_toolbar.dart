import 'package:flutter/material.dart';
import 'color_picker_dialog.dart';

/// Formatting toolbar for rich text editor
class FormattingToolbar extends StatelessWidget {
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onUnderline;
  final VoidCallback? onStrikethrough;
  final VoidCallback? onH1;
  final VoidCallback? onH2;
  final VoidCallback? onH3;
  final VoidCallback? onBulletList;
  final VoidCallback? onNumberedList;
  final VoidCallback? onQuote;
  final VoidCallback? onCode;
  final ValueChanged<Color>? onTextColor;
  final ValueChanged<Color>? onHighlightColor;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final Color currentTextColor;
  final Color? currentHighlightColor;

  const FormattingToolbar({
    super.key,
    this.onBold,
    this.onItalic,
    this.onUnderline,
    this.onStrikethrough,
    this.onH1,
    this.onH2,
    this.onH3,
    this.onBulletList,
    this.onNumberedList,
    this.onQuote,
    this.onCode,
    this.onTextColor,
    this.onHighlightColor,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.currentTextColor = Colors.black,
    this.currentHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _buildToolbarButton(
              context,
              icon: Icons.format_bold,
              onPressed: onBold,
              isActive: isBold,
              tooltip: 'Bold',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_italic,
              onPressed: onItalic,
              isActive: isItalic,
              tooltip: 'Italic',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_underline,
              onPressed: onUnderline,
              isActive: isUnderline,
              tooltip: 'Underline',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_strikethrough,
              onPressed: onStrikethrough,
              isActive: isStrikethrough,
              tooltip: 'Strikethrough',
            ),
            const VerticalDivider(),
            _buildToolbarButton(
              context,
              icon: Icons.title,
              label: 'H1',
              onPressed: onH1,
              tooltip: 'Heading 1',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.title,
              label: 'H2',
              onPressed: onH2,
              tooltip: 'Heading 2',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.title,
              label: 'H3',
              onPressed: onH3,
              tooltip: 'Heading 3',
            ),
            const VerticalDivider(),
            _buildToolbarButton(
              context,
              icon: Icons.format_list_bulleted,
              onPressed: onBulletList,
              tooltip: 'Bullet List',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_list_numbered,
              onPressed: onNumberedList,
              tooltip: 'Numbered List',
            ),
            const VerticalDivider(),
            _buildToolbarButton(
              context,
              icon: Icons.format_quote,
              onPressed: onQuote,
              tooltip: 'Quote',
            ),
            _buildToolbarButton(
              context,
              icon: Icons.code,
              onPressed: onCode,
              tooltip: 'Code Block',
            ),
            const VerticalDivider(),
            _buildColorButton(
              context,
              icon: Icons.format_color_text,
              currentColor: currentTextColor,
              onColorSelected: onTextColor,
              tooltip: 'Text Color',
            ),
            _buildColorButton(
              context,
              icon: Icons.format_color_fill,
              currentColor: currentHighlightColor ?? Colors.transparent,
              onColorSelected: onHighlightColor,
              tooltip: 'Highlight Color',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(
    BuildContext context, {
    required IconData icon,
    String? label,
    VoidCallback? onPressed,
    bool isActive = false,
    required String tooltip,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: label != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Icon(icon, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
    required IconData icon,
    required Color currentColor,
    required ValueChanged<Color>? onColorSelected,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onColorSelected != null
                ? () => _showColorPicker(context, currentColor, onColorSelected)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.onSurface),
                  if (currentColor != Colors.transparent)
                    Positioned(
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: currentColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: currentColor,
        title: 'Choose Color',
      ),
    ).then((color) {
      if (color != null) {
        onColorSelected(color);
      }
    });
  }
}

/// Compact formatting toolbar for mobile
class CompactFormattingToolbar extends StatelessWidget {
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onUnderline;
  final ValueChanged<Color>? onTextColor;
  final VoidCallback? onMore;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Color currentTextColor;

  const CompactFormattingToolbar({
    super.key,
    this.onBold,
    this.onItalic,
    this.onUnderline,
    this.onTextColor,
    this.onMore,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.currentTextColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactButton(context, Icons.format_bold, onBold, isBold),
          _buildCompactButton(context, Icons.format_italic, onItalic, isItalic),
          _buildCompactButton(context, Icons.format_underline, onUnderline, isUnderline),
          _buildCompactButton(context, Icons.format_color_text, () {
            if (onTextColor != null) {
              showDialog(
                context: context,
                builder: (context) => ColorPickerDialog(
                  initialColor: currentTextColor,
                  title: 'Text Color',
                ),
              ).then((color) {
                if (color != null) {
                  onTextColor!(color);
                }
              });
            }
          }, false),
          _buildCompactButton(context, Icons.more_horiz, onMore, false),
        ],
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context,
    IconData icon,
    VoidCallback? onPressed,
    bool isActive,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: isActive
          ? (isDark ? Colors.blue[700] : Colors.blue[100])
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}
