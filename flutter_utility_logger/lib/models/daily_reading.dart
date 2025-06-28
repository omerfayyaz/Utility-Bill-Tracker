import 'package:intl/intl.dart';

class DailyReading {
  final int id;
  final int userId;
  final int billingCycleId;
  final DateTime readingDate;
  final DateTime readingTime;
  final double readingValue;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReading({
    required this.id,
    required this.userId,
    required this.billingCycleId,
    required this.readingDate,
    required this.readingTime,
    required this.readingValue,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      id: json['id'],
      userId: json['user_id'],
      billingCycleId: json['billing_cycle_id'],
      readingDate: DateTime.parse(json['reading_date']),
      readingTime: DateTime.parse('2000-01-01T${json['reading_time']}:00'),
      readingValue: double.parse(json['reading_value'].toString()),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'billing_cycle_id': billingCycleId,
      'reading_date': readingDate.toIso8601String().split('T')[0],
      'reading_time': DateFormat('HH:mm').format(readingTime),
      'reading_value': readingValue,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedDate => DateFormat('MMM dd, yyyy').format(readingDate);
  String get formattedTime => DateFormat('h:mm a').format(readingTime);
  String get formattedReadingValue => NumberFormat('#,##0.00').format(readingValue);
  String get formattedFullDate => DateFormat('EEEE, MMM dd, yyyy').format(readingDate);

  // For API requests
  Map<String, dynamic> toApiJson() {
    return {
      'billing_cycle_id': billingCycleId,
      'reading_date': readingDate.toIso8601String().split('T')[0],
      'reading_time': DateFormat('HH:mm').format(readingTime),
      'reading_value': readingValue,
      'notes': notes,
    };
  }

  DailyReading copyWith({
    int? id,
    int? userId,
    int? billingCycleId,
    DateTime? readingDate,
    DateTime? readingTime,
    double? readingValue,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      billingCycleId: billingCycleId ?? this.billingCycleId,
      readingDate: readingDate ?? this.readingDate,
      readingTime: readingTime ?? this.readingTime,
      readingValue: readingValue ?? this.readingValue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyReading(id: $id, date: $formattedDate, time: $formattedTime, value: $readingValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
