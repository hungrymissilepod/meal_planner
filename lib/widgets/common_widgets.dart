import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Bloc + Cubit
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
              // TODO: if no meals for this day, show some text instead 'No meals for this day'
              ColumnBuilder(
                itemCount: dayPlan.meals.length,
                itemBuilder: (context, index) {
                  return MealTile(dayPlan.meals[index]);
                },
              ),
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

// TODO: should open date picker and allow user to change selectedDate
class ChangeDateButton extends StatelessWidget {
  const ChangeDateButton({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Change Date',
      onTap: () {
        print('change date');
      },
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