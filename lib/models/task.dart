class Task {
  const Task({
    required this.id,
    required this.title,
    required this.commitment,
    this.estimateMinutes,
    this.isHighlight = false,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final int commitment;
  final int? estimateMinutes;
  final bool isHighlight;
  final bool isCompleted;

  bool get isTwoMinute => estimateMinutes != null && estimateMinutes! <= 2;

  Task copyWith({
    String? id,
    String? title,
    int? commitment,
    int? estimateMinutes,
    bool? isHighlight,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      commitment: commitment ?? this.commitment,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      isHighlight: isHighlight ?? this.isHighlight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
