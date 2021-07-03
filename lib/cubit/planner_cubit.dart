/// Bloc
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/models/planner_repository.dart';

/// Utilities
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Models
import 'package:mealplanner/models/planner_models.dart';

part 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit(this._plannerRepository) : super(PlannerInitial());

  final PlannerRepository _plannerRepository;

  /// Keeps track of the date the users has selected. Used to show the selected date's meal plan.
  /// Defaults to device time on app launch.
  String selectedDate = '';

  final formatter = new DateFormat('yyyy-MM-dd');

  // TODO: add selectedDate var to keep track of which date user wants to look at. Should start as device date on app launch

  /// Initialises the [selectedDate] variable on app launch.
  void initialiseSelectedDate() {
    /// Get date today and format to same style as in JSON file
    var now = DateTime.now();
    selectedDate = formatter.format(now);
  }
  
  // Load meal planner data from JSON file. In real app this would be from server or device storage.
  Future<void> loadPlanner() async {
    print('loadPlanner');
    emit(PlannerLoading());
    try {
      final days = await _plannerRepository.fetchWeeklyPlan();
      emit(PlannerLoaded(days));
    } catch (e) {
      emit(PlannerError('Failed to load planner'));
    }
  }

  /// Adds [meal] to [date] given
  void addMealToDate(WeekPlan weekPlan, String date, String meal) async {
    emit(PlannerLoading());

    /// Find DayPlan element with this [date] and add the [meal] to this day
    int index = weekPlan.days.indexWhere((d) => d.date == date);
    if (index != -1) {
      if (!weekPlan.days[index].meals.contains(meal)) {
        weekPlan.days[index].meals.add(meal);
        emit(MealAdded(meal));
      }
    }
    /// Update WeekPlan state
    emit(PlannerLoaded(weekPlan));
  }

  /// Gets DayPlan object for this [selectedDate]
  DayPlan getMealsForSelectedDate(WeekPlan weekPlan) {
    /// Find a DayPlan for today's date
    int index = weekPlan.days.indexWhere((element) => element.date == selectedDate);
    if (index != -1) { return weekPlan.days[index]; }
    return null;
  }

  // TODO: delete after testing
  testChangeDate() {
    print('testChangeDate');
    emit(MealAdded('changeDate'));
    selectedDate = '2021-07-01';
    /// Set state to initial so the MealPlanner is reloaded
    emit(PlannerInitial());
  }
}