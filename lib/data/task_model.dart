import 'package:equatable/equatable.dart';

/// Model representing a task.
class Task extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isDone;

  const Task({
    this.id,
    required this.title,
    this.description,
    required this.deadline,
    this.isDone = false,
  });

  /// Creates a copy of the object with new values.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Converts the object to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  /// Creates an object from a map retrieved from the database.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      deadline: DateTime.parse(map['deadline'] as String),
      isDone: (map['isDone'] as int) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, description, deadline, isDone];
}
