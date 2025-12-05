import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/study_plan_bloc.dart';
import '../bloc/study_plan_event.dart';
import '../bloc/study_plan_state.dart';
import '../widgets/study_plan_card.dart';
import '../widgets/add_study_plan_dialog.dart';
import '../widgets/edit_study_plan_dialog.dart';
import '../models/study_plan.dart';

class StudyPlansScreen extends StatefulWidget {
  const StudyPlansScreen({super.key});

  @override
  State<StudyPlansScreen> createState() => _StudyPlansScreenState();
}

class _StudyPlansScreenState extends State<StudyPlansScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadStudyPlans();
  }

  void _loadStudyPlans() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<StudyPlanBloc>().add(StudyPlanLoadRequested(userId: user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Study Plan',
            onPressed: _showAddStudyPlanDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Plans')),
              const PopupMenuItem(value: 'Active', child: Text('Active')),
              const PopupMenuItem(value: 'Completed', child: Text('Completed')),
              const PopupMenuItem(value: 'Paused', child: Text('Paused')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedFilter),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<StudyPlanBloc, StudyPlanState>(
        builder: (context, state) {
          if (state is StudyPlanLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudyPlanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading study plans',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStudyPlans,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<StudyPlan> studyPlans = [];
          if (state is StudyPlanLoaded) {
            studyPlans = state.studyPlans;
          }

          final filteredPlans = _filterStudyPlans(studyPlans);

          if (filteredPlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'All'
                        ? 'No study plans yet'
                        : 'No ${_selectedFilter.toLowerCase()} plans',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'All'
                        ? 'Create your first study plan to get started'
                        : 'Try a different filter',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddStudyPlanDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Study Plan'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadStudyPlans(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: filteredPlans.length,
              itemBuilder: (context, index) {
                final plan = filteredPlans[index];
                return StudyPlanCard(
                  studyPlan: plan,
                  onTap: () => _navigateToStudyPlanDetails(plan),
                  onEdit: () => _showEditStudyPlanDialog(plan),
                  onDelete: () => _showDeleteConfirmation(plan),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<StudyPlan> _filterStudyPlans(List<StudyPlan> plans) {
    switch (_selectedFilter) {
      case 'Active':
        return plans.where((plan) => plan.status == StudyPlanStatus.active).toList();
      case 'Completed':
        return plans.where((plan) => plan.status == StudyPlanStatus.completed).toList();
      case 'Paused':
        return plans.where((plan) => plan.status == StudyPlanStatus.paused).toList();
      default:
        return plans;
    }
  }

  void _showAddStudyPlanDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to create a study plan'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<StudyPlanBloc, StudyPlanState>(
        listenWhen: (previous, current) {
          // Only react if we transitioned from Loading to Loaded (creation completed)
          // or if there's an error after loading started
          return (previous is StudyPlanLoading && current is StudyPlanLoaded) ||
              (previous is StudyPlanLoading && current is StudyPlanError) ||
              (previous is StudyPlanCreated && current is StudyPlanLoaded);
        },
        listener: (context, state) {
          if (state is StudyPlanLoaded) {
            // Study plan created and loaded successfully
            if (mounted) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Study plan created successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } else if (state is StudyPlanError) {
            // Error occurred
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create study plan: ${state.message}'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
        child: AddStudyPlanDialog(
          onSave: (title, description) {
            context.read<StudyPlanBloc>().add(
                  StudyPlanCreateRequested(
                    userId: user.uid,
                    title: title,
                    description: description,
                  ),
                );
          },
        ),
      ),
    );
  }

  void _showEditStudyPlanDialog(StudyPlan plan) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<StudyPlanBloc, StudyPlanState>(
        listener: (context, state) {
          if (state is StudyPlanLoaded) {
            // Update completed, close dialog and show success message
            if (mounted) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Study plan updated successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } else if (state is StudyPlanError) {
            // Error occurred
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update study plan: ${state.message}'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
        child: EditStudyPlanDialog(
          studyPlan: plan,
          onSave: (updates) {
            context.read<StudyPlanBloc>().add(
                  StudyPlanUpdateRequested(
                    planId: plan.id,
                    updates: updates,
                  ),
                );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(StudyPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Plan'),
        content: Text('Are you sure you want to delete "${plan.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<StudyPlanBloc>().add(
                    StudyPlanDeleteRequested(planId: plan.id),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Study plan deleted'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStudyPlanDetails(StudyPlan plan) {
    // TODO: Navigate to study plan details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Study plan details coming soon')),
    );
  }
}
