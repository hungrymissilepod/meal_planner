import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';

/// Models
import 'package:mealplanner/models/planner_models.dart';

/// Utilities
import 'package:jiffy/jiffy.dart';

/// Widgets
import 'package:mealplanner/screens/meal_select_screen.dart';

/// Shows date and all meals for that day in a column
class MealsForDay extends StatelessWidget {
  const MealsForDay(this.dayPlan, { Key key }) : super(key: key);

  final DayPlan dayPlan;

  @override
  Widget build(BuildContext context) {
    String dateFormatted = Jiffy(dayPlan.date).format("do MMMM");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.grey[400],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(dateFormatted),
                  AddMealButton(dayPlan.date),
                ],
              ),
              dayPlan.meals.length > 0 ?
              ColumnBuilder(
                itemCount: dayPlan.meals.length,
                itemBuilder: (context, index) {
                  return MealTile(dayPlan.meals[index]);
                },
              ) : Text('No meals added...'),
              // TODO: add padding to this text widget
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget similar to ListView.builder but creates a Column with children.
/// This is not my code, found online here: https://gist.github.com/slightfoot/a75d6c368f1b823b594d9f04bf667231
class ColumnBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: this.crossAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      mainAxisAlignment: this.mainAxisAlignment,
      verticalDirection: this.verticalDirection,
      children:
        new List.generate(this.itemCount, (index) => this.itemBuilder(context, index)).toList(),
    );
  }
}

class MealTile extends StatelessWidget {
  const MealTile(this.label, { Key key }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(label),
      ),
    );
  }
}

class ChangeDateButton extends StatelessWidget {
  ChangeDateButton({ Key key }) : super(key: key);

  _showDatePicker(BuildContext context) async {

    /// Get current selectedDate from PlannerCubit
    final DateTime selectedDate = DateTime.parse(BlocProvider.of<PlannerCubit>(context).selectedDate);

    /// Get the first and last days of the current week (Monday - Sunday).
    /// Code to get the first and last days of the week was found on Stackoverflow:
    /// https://stackoverflow.com/questions/58287278/how-to-get-start-of-or-end-of-week-in-dart/58287666
    
    /// Get the first day of this week
    final DateTime firstDate = getDate(selectedDate.subtract(Duration(days: selectedDate.weekday-1)));
    
    /// Get the last day of this week
    final DateTime lastDate = getDate(selectedDate.add(Duration(days: DateTime.daysPerWeek - selectedDate.weekday)));

    /// Show date picker and only allow user to select a day from today to the end of the week
    final DateTime newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate);

    /// Ensure the new selected date is not null and does not match the current selected date
    if (newSelectedDate != null && newSelectedDate != selectedDate) {
      BlocProvider.of<PlannerCubit>(context).changeSelectedDate(newSelectedDate);
    }
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Change Date',
      onTap: () { _showDatePicker(context); },
    );
  }
}

class AddMealButton extends StatelessWidget {
  const AddMealButton(this.date, { Key key }) : super(key: key);

  final String date;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Add Meal',
      onTap: () {
        if(Platform.isIOS) { Navigator.of(context).push(MaterialPageRoute(builder: (context) => MealSelectScreen(date), settings: RouteSettings(name: 'MealSelectScreen'))); }
        else { Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => MealSelectScreen(date), settings: RouteSettings(name: 'MealSelectScreen'))); }
      }
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({ this.label, this.onTap, Key key }) : super(key: key);

  final String label;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(label),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}