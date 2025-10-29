import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/ai_video.dart';

class CreateVideoDialog extends StatefulWidget {
  final Function(String title, String text, VideoStyle style) onCreate;

  const CreateVideoDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateVideoDialog> createState() => _CreateVideoDialogState();
}

class _CreateVideoDialogState extends State<CreateVideoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  VideoStyle _selectedStyle = VideoStyle.educational;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onCreate(
        _titleController.text.trim(),
        _textController.text.trim(),
        _selectedStyle,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create video: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create AI Video'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Video Title',
                  hintText: 'e.g., Introduction to Calculus',
                  prefixIcon: Icon(Icons.video_call),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Content to Convert',
                  hintText: 'Enter the text you want to convert to video...',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  if (value.trim().length < 50) {
                    return 'Content must be at least 50 characters';
                  }
                  if (value.trim().length > AppConstants.maxTextLength) {
                    return 'Content is too long (max ${AppConstants.maxTextLength} characters)';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VideoStyle>(
                value: _selectedStyle,
                decoration: const InputDecoration(
                  labelText: 'Video Style',
                  prefixIcon: Icon(Icons.style),
                ),
                items: VideoStyle.values.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(_getStyleDisplayName(style)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStyle = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Video generation may take a few minutes. You\'ll be notified when it\'s ready.',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Video'),
        ),
      ],
    );
  }

  String _getStyleDisplayName(VideoStyle style) {
    switch (style) {
      case VideoStyle.educational:
        return 'Educational';
      case VideoStyle.presentation:
        return 'Presentation';
      case VideoStyle.tutorial:
        return 'Tutorial';
      case VideoStyle.summary:
        return 'Summary';
    }
  }
}
