import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Subject> subjects;
  final StudyPlanStatus status;
  final int totalTasks;
  final int completedTasks;
  final double progress;

  StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.subjects,
    required this.status,
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map, String id) {
    return StudyPlan(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Normalize Firestore timestamps to UTC so tests comparing against DateTime.utc pass consistently.
      createdAt: (map['createdAt'] as Timestamp).toDate().toUtc(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate().toUtc(),
      subjects: (map['subjects'] as List<dynamic>? ?? [])
          .map((subject) => Subject.fromMap(subject))
          .toList(),
      status: StudyPlanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StudyPlanStatus.active,
      ),
      totalTasks: map['totalTasks'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'subjects': subjects.map((subject) => subject.toMap()).toList(),
      'status': status.name,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'progress': progress,
    };
  }

  StudyPlan copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subject>? subjects,
    StudyPlanStatus? status,
    int? totalTasks,
    int? completedTasks,
    double? progress,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subjects: subjects ?? this.subjects,
      status: status ?? this.status,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      progress: progress ?? this.progress,
    );
  }
}

class Subject {
  final String id;
  final String name;
  final String description;
  final String color;
  final List<Task> tasks;
  final int totalTasks;
  final int completedTasks;
  final double progress;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.tasks,
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? '#2196F3',
      tasks: (map['tasks'] as List<dynamic>? ?? [])
          .map((task) => Task.fromMap(task))
          .toList(),
      totalTasks: map['totalTasks'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'progress': progress,
    };
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime? dueDate;
  final int priority;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    required this.priority,
    required this.createdAt,
    this.completedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate().toUtc()
          : null,
      priority: map['priority'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp).toDate().toUtc(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate().toUtc()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

enum StudyPlanStatus {
  active,
  paused,
  completed,
  archived,
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}
