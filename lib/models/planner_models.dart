/// Model for day of the week.
/// Contains the date for this day and a list of meals
class DayPlan {

  DayPlan({ this.date, this.meals });
  
  final String date;
  final List<String> meals;

  factory DayPlan.fromJson(Map data) {
    return DayPlan(
      date: data['date'] as String ?? '',
      meals: (data['meals'] as List)?.map((e) => e as String)?.toList(),
    );
  }
}

/// Model for the week
/// Contains a list of DayPlan objects for this week
class WeekPlan {

  WeekPlan({ this.days });

  final List<DayPlan> days;

  factory WeekPlan.fromJson(Map data) {
    return WeekPlan(
      days: (data['dates'] as List)?.map((e) => e == null ? null : DayPlan.fromJson(e as Map<String, dynamic>))?.toList(),
    );
  }
}