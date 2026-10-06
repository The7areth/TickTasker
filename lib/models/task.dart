/// Immutable task. Commitment: 0 = idea, 1 = maybe, 2 = today, 3 = now.
class Task {
  Task({
    required this.id,
    required String title,
    required this.commitment,
    this.estimateMinutes,
    this.isCompleted = false,
    this.highlightDay,
  }) : title = title.trim() {
    if (id.isEmpty || this.title.isEmpty || this.title.length > 200) {
      throw ArgumentError('Task title must contain 1–200 characters.');
    }
    if (commitment < 0 || commitment > 3) {
      throw ArgumentError('Commitment must be between 0 and 3.');
    }
    if (estimateMinutes != null &&
        (estimateMinutes! < 1 || estimateMinutes! > 1440)) {
      throw ArgumentError('Estimate must be between 1 and 1440 minutes.');
    }
  }

  final String id;
  final String title;
  final int commitment;
  final int? estimateMinutes;
  final bool isCompleted;
  final String? highlightDay;

  bool get isTwoMinute => estimateMinutes != null && estimateMinutes! <= 2;
  bool isHighlightOn(DateTime day) => highlightDay == dayKey(day);

  static String dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  Task copyWith({
    bool? isCompleted,
    String? highlightDay,
    bool clearHighlight = false,
  }) => Task(
    id: id,
    title: title,
    commitment: commitment,
    estimateMinutes: estimateMinutes,
    isCompleted: isCompleted ?? this.isCompleted,
    highlightDay: clearHighlight ? null : highlightDay ?? this.highlightDay,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'commitment': commitment,
    'estimateMinutes': estimateMinutes,
    'isCompleted': isCompleted,
    'highlightDay': highlightDay,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    commitment: json['commitment'] as int,
    estimateMinutes: json['estimateMinutes'] as int?,
    isCompleted: json['isCompleted'] as bool,
    highlightDay: json['highlightDay'] as String?,
  );
}
