import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String title;

  String? notes;

  /// Commitment: 0=idea, 1=maybe, 2=today, 3=now
  @Index()
  int commitment = 0;

  /// Marked as the single Daily Highlight
  @Index()
  bool isHighlight = false;

  /// Estimated minutes; used by Two‑Minute filter
  int? estimateMinutes;

  /// Optional schedule (date granularity is fine for v1)
  DateTime? scheduledFor;

  /// Completion timestamp
  DateTime? completedAt;

  /// Energy hint for future features: 0=low,1=med,2=high
  int energy = 1;

  DateTime createdAt = DateTime.now();

  bool get isCompleted => completedAt != null;
  bool get isTwoMinute => (estimateMinutes ?? 0) <= 2;
}
