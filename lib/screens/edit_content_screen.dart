import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/custom_button.dart';

class EditContentScreen extends StatefulWidget {
  final String initialContent;
  final String title;
  final Function(String) onSave;
  
  const EditContentScreen({
    super.key,
    required this.initialContent,
    required this.title,
    required this.onSave,
  });

  @override
  State<EditContentScreen> createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  late TextEditingController _controller;
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _controller.addListener(() {
      setState(() {
        _hasChanges = _controller.text != widget.initialContent;
      });
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _saveChanges() {
    widget.onSave(_controller.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: l10n.saveChanges,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.editContent,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                label: l10n.saveChanges,
                icon: Icons.save,
                onPressed: _saveChanges,
              ),
            ),
        ],
      ),
    );
  }
}
