import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';

/// Models
import 'package:mealplanner/models/planner_models.dart';

/// Widgets
import 'package:mealplanner/widgets/common_widgets.dart' show MealsForDay, ColumnBuilder;

/// Shows all day plans for this week
class WeekScreen extends StatelessWidget {
  const WeekScreen(this.state, { Key key }) : super(key: key);

  final PlannerLoaded state;

  @override
  Widget build(BuildContext context) {
    /// Get all DayPlan objects for this week
    List<DayPlan> days = BlocProvider.of<PlannerCubit>(context, listen: false).getMealsForThisWeek();
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Center(
          child: ColumnBuilder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              return MealsForDay(days[index]);
            },
          ),
        ),
      ),
    );
  }
}