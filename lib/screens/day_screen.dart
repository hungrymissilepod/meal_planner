import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';

/// Models
import 'package:mealplanner/models/planner_models.dart';

/// Widgets
import 'package:mealplanner/widgets/common_widgets.dart' show MealsForDay, ChangeDateButton;

class DayScreen extends StatelessWidget {
  const DayScreen(this.state, { Key key }) : super(key: key);
  final PlannerLoaded state;

  @override
  Widget build(BuildContext context) {
    /// Load DayPlan for selectedDate
    DayPlan dayPlan = BlocProvider.of<PlannerCubit>(context).getMealsForSelectedDate(state.weekPlan);
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Center(
          child: Column(
            children: [
              ChangeDateButton(),
              MealsForDay(dayPlan),
            ],
          ),
        ),
      ),
    );
  }
}