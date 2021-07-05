/// Bloc
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/models/planner_repository.dart';

/// Utilities
import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';

/// Models
import 'package:mealplanner/models/planner_models.dart';

part 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit(this._plannerRepository) : super(PlannerInitial());

  final PlannerRepository _plannerRepository;

  /// User's week meal plan
  WeekPlan weekPlan;

  /// Keeps track of the date the users has selected. Used to show the selected date's meal plan.
  /// Defaults to device time on app launch.
  String selectedDate = '';

  DateTime firstDate, lastDate, selectedDateTime;

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Initialises the [selectedDate] variable on app launch.
  void initialiseSelectedDate() {
    /// Set selectedDate to today's date and format it to same style as in JSON file
    var now = DateTime.now();
    selectedDate = Jiffy(now).format('yyyy-MM-dd');

    /// Get the first and last days of the current week (Monday - Sunday).
    /// Code to get the first and last days of the week was found on Stackoverflow:
    /// https://stackoverflow.com/questions/58287278/how-to-get-start-of-or-end-of-week-in-dart/58287666
    /// This is used for DatePicker and for getting the DayPlan objects to show in WeekScreen
    selectedDateTime = DateTime.parse(selectedDate);
    firstDate = getDate(selectedDateTime.subtract(Duration(days: selectedDateTime.weekday-1)));
    lastDate = getDate(selectedDateTime.add(Duration(days: DateTime.daysPerWeek - selectedDateTime.weekday)));
  }
  
  // Load meal planner data from JSON file. In real app this would be from a database or device storage.
  Future<void> loadPlanner() async {
    /// If weekPlan is not null there is no need to load it again
    if (weekPlan != null) { emit(PlannerLoaded(weekPlan)); return; }

    emit(PlannerLoading());
    try {
      weekPlan = await _plannerRepository.fetchWeeklyPlan();
      emit(PlannerLoaded(weekPlan));
    } catch (e) {
      emit(PlannerError('Failed to load meal planner'));
    }
  }

  /// Adds [meal] to [date] given
  void addMealToDate(String date, String meal) async {
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

  /// Gets DayPlan object for [selectedDate]
  DayPlan getMealsForSelectedDate() {
    /// Find a DayPlan for today's date
    int index = weekPlan.days.indexWhere((element) => element.date == selectedDate);
    if (index != -1) { return weekPlan.days[index]; }
    return null;
  }

  /// Returns a list of DayPlan objects for this week
  List<DayPlan> getMealsForThisWeek() {
    List<DayPlan> weekDays = [];
    
    for (DayPlan day in weekPlan.days) {
      /// Parse this [day] object's date string to DateTime object
      DateTime dateTime = DateTime.parse(day.date);
      /// If this date is the same or after [firstDate] and if it's the same or befor [lastDate], add it to the list
      if ((dateTime.isAtSameMomentAs(firstDate) || dateTime.isAfter(firstDate)) &&
        (dateTime.isAtSameMomentAs(lastDate) || dateTime.isBefore(lastDate))) {
          weekDays.add(day);
        }
    }
    return weekDays;
  }

  /// Changes the current [selectedDate]
  changeSelectedDate(DateTime date) {
    selectedDate = Jiffy(date).format('yyyy-MM-dd');
    selectedDateTime = DateTime.parse(selectedDate);
    emit(SelectedDateChanged());
  }
}