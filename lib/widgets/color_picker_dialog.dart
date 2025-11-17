import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

/// Beautiful color picker dialog for text and background colors
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;
  final bool showRecentColors;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    this.title = 'Pick a color',
    this.showRecentColors = true,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ColorPicker(
          color: selectedColor,
          onColorChanged: (Color color) {
            setState(() => selectedColor = color);
          },
          width: 44,
          height: 44,
          borderRadius: 22,
          heading: Text(
            'Select color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subheading: Text(
            'Select shade',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: false,
            ColorPickerType.primary: true,
            ColorPickerType.accent: true,
            ColorPickerType.bw: false,
            ColorPickerType.custom: true,
            ColorPickerType.wheel: true,
          },
          customColorSwatchesAndNames: _getCustomSwatches(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Map<ColorSwatch<Object>, String> _getCustomSwatches() {
    return <ColorSwatch<Object>, String>{
      ColorTools.createPrimarySwatch(const Color(0xFFFF5252)): 'Red',
      ColorTools.createPrimarySwatch(const Color(0xFFFF4081)): 'Pink',
      ColorTools.createPrimarySwatch(const Color(0xFFE040FB)): 'Purple',
      ColorTools.createPrimarySwatch(const Color(0xFF7C4DFF)): 'Deep Purple',
      ColorTools.createPrimarySwatch(const Color(0xFF536DFE)): 'Indigo',
      ColorTools.createPrimarySwatch(const Color(0xFF448AFF)): 'Blue',
      ColorTools.createPrimarySwatch(const Color(0xFF40C4FF)): 'Light Blue',
      ColorTools.createPrimarySwatch(const Color(0xFF18FFFF)): 'Cyan',
      ColorTools.createPrimarySwatch(const Color(0xFF64FFDA)): 'Teal',
      ColorTools.createPrimarySwatch(const Color(0xFF69F0AE)): 'Green',
      ColorTools.createPrimarySwatch(const Color(0xFFB2FF59)): 'Light Green',
      ColorTools.createPrimarySwatch(const Color(0xFFEEFF41)): 'Lime',
      ColorTools.createPrimarySwatch(const Color(0xFFFFFF00)): 'Yellow',
      ColorTools.createPrimarySwatch(const Color(0xFFFFD740)): 'Amber',
      ColorTools.createPrimarySwatch(const Color(0xFFFFAB40)): 'Orange',
      ColorTools.createPrimarySwatch(const Color(0xFFFF6E40)): 'Deep Orange',
    };
  }
}

/// Quick color picker with preset colors
class QuickColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final List<Color>? customColors;

  const QuickColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = customColors ?? _defaultColors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  static const List<Color> _defaultColors = [
    Color(0xFF000000), // Black
    Color(0xFF424242), // Dark Grey
    Color(0xFF757575), // Grey
    Color(0xFFFFFFFF), // White
    Color(0xFFFF5252), // Red
    Color(0xFFFF4081), // Pink
    Color(0xFFE040FB), // Purple
    Color(0xFF7C4DFF), // Deep Purple
    Color(0xFF536DFE), // Indigo
    Color(0xFF448AFF), // Blue
    Color(0xFF40C4FF), // Light Blue
    Color(0xFF18FFFF), // Cyan
    Color(0xFF64FFDA), // Teal
    Color(0xFF69F0AE), // Green
    Color(0xFFB2FF59), // Light Green
    Color(0xFFFFFF00), // Yellow
    Color(0xFFFFD740), // Amber
    Color(0xFFFFAB40), // Orange
  ];
}
