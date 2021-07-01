import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show json;

/// Models
import 'package:mealplanner/models/planner_models.dart';

class PlannerRepository {

  /// Load user's weekly plan.
  /// In this example the weekly plan is loaded from a json file. In a real world app this might be downloaded from a database
  Future<WeekPlan> fetchWeeklyPlan() async {
    String path = 'configs/meals.json';
    String content = await rootBundle.loadString(path);
    dynamic jsonStr = json.decode(content);
    WeekPlan week = WeekPlan.fromJson(jsonStr);
    return week;
  }
}