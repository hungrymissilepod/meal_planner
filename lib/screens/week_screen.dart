import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:mealplanner/cubit/planner_cubit.dart';

/// Widgets
import 'package:mealplanner/widgets/common_widgets.dart' show MealsForDay, ColumnBuilder;

class WeekScreen extends StatelessWidget {
  const WeekScreen(this.state, { Key key }) : super(key: key);
  final PlannerLoaded state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Center(
          child: ColumnBuilder(
            itemCount: state.weekPlan.days.length,
            itemBuilder: (context, index) {
              return MealsForDay(state.weekPlan.days[index]);
            },
          ),
        ),
      ),
    );
  }
}