import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';

class MealSelectScreen extends StatelessWidget {
  MealSelectScreen(this.date, { Key key }) : super(key: key);
  final String date;

  final List<String> meals = ['pasta', 'burger', 'pizza', 'stir fry', 'pumpkin', 'butternut squash', 'tomato and egg', 'curry'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoaded) {
          return Scaffold(
            appBar: AppBar(
              // TODO: set to correct colour
              iconTheme: IconThemeData(color: Colors.purple),
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.red,
            body: SafeArea(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(meals[index]),
                      trailing: ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<PlannerCubit>(context).addMealToDate(state.weekPlan, date, meals[index]);
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      ),
                    ),
                  );
                }
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}