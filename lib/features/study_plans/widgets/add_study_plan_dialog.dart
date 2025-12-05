import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/study_plan_bloc.dart';
import '../bloc/study_plan_state.dart';

class AddStudyPlanDialog extends StatefulWidget {
  final Function(String title, String description) onSave;

  const AddStudyPlanDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddStudyPlanDialog> createState() => _AddStudyPlanDialogState();
}

class _AddStudyPlanDialogState extends State<AddStudyPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      widget.onSave(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
      
      // Dialog will be closed by BlocListener in parent
      // Keep loading state until BLoC completes
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create study plan: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudyPlanBloc, StudyPlanState>(
      listenWhen: (previous, current) {
        // Reset loading state on error after loading started
        return previous is StudyPlanLoading && current is StudyPlanError;
      },
      listener: (context, state) {
        if (state is StudyPlanError && _isLoading) {
          setState(() => _isLoading = false);
        }
      },
      child: AlertDialog(
      title: const Text('Create Study Plan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Plan Title',
                hintText: 'e.g., Math Study Plan',
                prefixIcon: Icon(Icons.school),
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Describe your study plan...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
      ),
    );
  }
}
