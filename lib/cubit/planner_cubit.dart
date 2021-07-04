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

  /// Keeps track of the date the users has selected. Used to show the selected date's meal plan.
  /// Defaults to device time on app launch.
  String selectedDate = '';

  /// Days to show on the week screen
  List<DayPlan> weekDays = [];

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
  
  // Load meal planner data from JSON file. In real app this would be from server or device storage.
  Future<void> loadPlanner() async {
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

  /// Returns a list of DayPlan objects for this week
  List<DayPlan> getMealsForThisWeek(WeekPlan weekPlan) {
    if (weekDays.isNotEmpty) { return weekDays; }

    print('getMealsForThisWeek');
    for (DayPlan day in weekPlan.days) {
      /// Parse this [day] object's date string to DateTime object
      DateTime dateTime = DateTime.parse(day.date);
      /// If this date is the same or after [firstDate] and if it's the same or befor [lastDate], add it to the list
      if ((dateTime.isAtSameMomentAs(firstDate) || dateTime.isAfter(firstDate)) &&
        dateTime.isAtSameMomentAs(lastDate) || dateTime.isBefore(lastDate)) {
          weekDays.add(day);
        }
    }
    return weekDays;
  }

  /// Changes the current selectedDate
  changeSelectedDate(DateTime date) {
    selectedDate = Jiffy(date).format('yyyy-MM-dd');
    emit(SelectedDateChanged());
  }
}