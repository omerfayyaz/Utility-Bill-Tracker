import 'package:intl/intl.dart';
import 'daily_reading.dart';

class BillingCycle {
  final int id;
  final int userId;
  final String name;
  final DateTime startDate;
  final double startReading;
  final DateTime? endDate;
  final double? endReading;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DailyReading> dailyReadings;

  BillingCycle({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.startReading,
    this.endDate,
    this.endReading,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.dailyReadings = const [],
  });

  factory BillingCycle.fromJson(Map<String, dynamic> json) {
    return BillingCycle(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      startDate: DateTime.parse(json['start_date']),
      startReading: double.parse(json['start_reading'].toString()),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      endReading: json['end_reading'] != null
          ? double.parse(json['end_reading'].toString())
          : null,
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      dailyReadings: json['daily_readings'] != null
          ? (json['daily_readings'] as List)
              .map((reading) => DailyReading.fromJson(reading))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'start_date': startDate.toIso8601String().split('T')[0],
      'start_reading': startReading,
      'end_date': endDate?.toIso8601String().split('T')[0],
      'end_reading': endReading,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Computed properties (mirroring Laravel model)
  double get totalConsumedUnits {
    final latestReading = dailyReadings.isNotEmpty
        ? dailyReadings.reduce((a, b) => a.readingDate.isAfter(b.readingDate) ||
                (a.readingDate.isAtSameMomentAs(b.readingDate) &&
                    a.readingTime.isAfter(b.readingTime))
            ? a
            : b)
        : null;

    if (latestReading == null) return 0;
    return latestReading.readingValue - startReading;
  }

  double get currentReading {
    if (dailyReadings.isEmpty) return startReading;

    final latestReading = dailyReadings.reduce((a, b) =>
        a.readingDate.isAfter(b.readingDate) ||
                (a.readingDate.isAtSameMomentAs(b.readingDate) &&
                    a.readingTime.isAfter(b.readingTime))
            ? a
            : b);

    return latestReading.readingValue;
  }

  int get daysElapsed {
    return DateTime.now().difference(startDate).inDays;
  }

  bool isActiveCycle() {
    return isActive;
  }

  // Helper methods
  String get formattedStartDate => DateFormat('MMM dd, yyyy').format(startDate);
  String get formattedEndDate =>
      endDate != null ? DateFormat('MMM dd, yyyy').format(endDate!) : 'Ongoing';
  String get formattedStartReading =>
      NumberFormat('#,##0.00').format(startReading);
  String get formattedEndReading =>
      endReading != null ? NumberFormat('#,##0.00').format(endReading!) : '';
  String get formattedCurrentReading =>
      NumberFormat('#,##0.00').format(currentReading);
  String get formattedTotalConsumed =>
      NumberFormat('#,##0.00').format(totalConsumedUnits);

  BillingCycle copyWith({
    int? id,
    int? userId,
    String? name,
    DateTime? startDate,
    double? startReading,
    DateTime? endDate,
    double? endReading,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DailyReading>? dailyReadings,
  }) {
    return BillingCycle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      startReading: startReading ?? this.startReading,
      endDate: endDate ?? this.endDate,
      endReading: endReading ?? this.endReading,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dailyReadings: dailyReadings ?? this.dailyReadings,
    );
  }

  @override
  String toString() {
    return 'BillingCycle(id: $id, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingCycle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
