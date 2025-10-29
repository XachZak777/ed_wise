import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/study_plan_provider.dart';
import '../widgets/study_plan_card.dart';
import '../widgets/add_study_plan_dialog.dart';
import '../models/study_plan.dart';

class StudyPlansScreen extends StatefulWidget {
  const StudyPlansScreen({super.key});

  @override
  State<StudyPlansScreen> createState() => _StudyPlansScreenState();
}

class _StudyPlansScreenState extends State<StudyPlansScreen> {
  final StudyPlanProvider _provider = StudyPlanProvider();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadStudyPlans();
  }

  Future<void> _loadStudyPlans() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _provider.loadStudyPlans(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plans'),
        actions: [
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
      body: StreamBuilder<List<StudyPlan>>(
        stream: _provider.studyPlansStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
                    snapshot.error.toString(),
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

          final studyPlans = snapshot.data ?? [];
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
                        : 'No $_selectedFilter.toLowerCase() plans',
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
            onRefresh: _loadStudyPlans,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudyPlanDialog,
        child: const Icon(Icons.add),
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
    showDialog(
      context: context,
      builder: (context) => AddStudyPlanDialog(
        onSave: (title, description) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _provider.createStudyPlan(
              user.uid,
              title,
              description,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Study plan created successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditStudyPlanDialog(StudyPlan plan) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _provider.deleteStudyPlan(plan.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Study plan deleted'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete'),
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
