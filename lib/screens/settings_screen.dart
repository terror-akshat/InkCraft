import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Settings screen for app preferences
class SettingsScreen extends StatefulWidget {
  final Function(int) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService();
  int _themeMode = 0;
  double _fontSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final themeMode = await _prefs.getThemeMode();
    final fontSize = await _prefs.getFontSize();
    setState(() {
      _themeMode = themeMode;
      _fontSize = fontSize;
    });
  }

  Future<void> _updateThemeMode(int mode) async {
    await _prefs.setThemeMode(mode);
    setState(() => _themeMode = mode);
    widget.onThemeChanged(mode);
  }

  Future<void> _updateFontSize(double size) async {
    await _prefs.setFontSize(size);
    setState(() => _fontSize = size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_getThemeText()),
            onTap: () => _showThemeDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: Slider(
              value: _fontSize,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: '${(_fontSize * 100).toInt()}%',
              onChanged: (value) => _updateFontSize(value),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0+1'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('About App'),
            subtitle: const Text('Flutter Notes - Enhanced Edition'),
            onTap: () => _showAboutDialog(),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Rich Text Formatting'),
            subtitle: Text('Bold, Italic, Colors, Headings'),
          ),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Colorful PDF Export'),
            subtitle: Text('Export with all formatting preserved'),
          ),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Multiple Export Formats'),
            subtitle: Text('PDF, TXT, Markdown, HTML'),
          ),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Share & Print'),
            subtitle: Text('Native sharing and printing support'),
          ),
        ],
      ),
    );
  }

  String _getThemeText() {
    switch (_themeMode) {
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System Default';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: const Text('System Default'),
                value: 0,
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _updateThemeMode(value!);
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('Light'),
                value: 1,
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _updateThemeMode(value!);
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<int>(
                title: const Text('Dark'),
                value: 2,
                groupValue: _themeMode,
                onChanged: (value) {
                  setState(() {
                    _updateThemeMode(value!);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Flutter Notes'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Flutter Notes - Enhanced Edition',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Version: 1.0.0+1'),
              SizedBox(height: 16),
              Text(
                'A beautiful, feature-rich notes application with:',
              ),
              SizedBox(height: 8),
              Text('• Rich text formatting'),
              Text('• Colorful text and highlights'),
              Text('• PDF export with colors'),
              Text('• Multiple export formats'),
              Text('• Dark mode support'),
              Text('• Search and organization'),
              SizedBox(height: 16),
              Text(
                'Made with ❤️ using Flutter',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
