/// A lightweight domain model representing a task in TickTasker.
class Task {
  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.commitment = 0,
    this.isHighlight = false,
    this.estimateMinutes,
    this.scheduledFor,
    this.completedAt,
  });

  /// Unique identifier assigned by the repository.
  final int id;

  /// User-facing title of the task.
  final String title;

  /// How strongly the user has committed to completing this task today.
  final int commitment;

  /// Whether the task is marked as the daily highlight.
  final bool isHighlight;

  /// Estimated duration in minutes.
  final int? estimateMinutes;

  /// Optional scheduled start time.
  final DateTime? scheduledFor;

  /// When the task was created.
  final DateTime createdAt;

  /// When the task was completed, if ever.
  final DateTime? completedAt;

  /// Whether this task should appear in the "two minute" view.
  bool get isTwoMinute => estimateMinutes != null && estimateMinutes! <= 2;

  /// Creates a copy with modified fields.
  Task copyWith({
    int? id,
    String? title,
    int? commitment,
    bool? isHighlight,
    int? estimateMinutes,
    DateTime? scheduledFor,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      commitment: commitment ?? this.commitment,
      isHighlight: isHighlight ?? this.isHighlight,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
