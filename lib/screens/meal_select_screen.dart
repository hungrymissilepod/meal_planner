import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';

/// Utilities
import 'package:mealplanner/utilities/size_config.dart';

class MealSelectScreen extends StatelessWidget {
  MealSelectScreen(this.date, { Key key }) : super(key: key);
  final String date;

  /// List of available meals.
  /// In a real app this might be saved in a config file or in a database
  final List<String> meals = ['Stir fry', 'Pasta & salad', 'Beans on toast', 'Blueberry Smoothie', 'Veggi chilli', 'Chicken curry', 'Fish tacos', 'Stuffed bell peppers', 'Halloumi burger', 'Corn chowder', 'Cheesecake', 'Strawberries & cream', 'Beef ragu', 'Pizza', 'Apple pie'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoaded) {
          return Scaffold(
            backgroundColor: Colors.grey[350],
            appBar: AppBar(
              title: Text('Add Meal', style: TextStyle(color: Colors.black)),
              iconTheme: IconThemeData(color: Colors.blue),
              backgroundColor: Colors.white,
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                child: ListView.separated(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return AddMealTile(meals[index], () {
                      /// This callback will add this meal to this date
                      BlocProvider.of<PlannerCubit>(context).addMealToDate(date, meals[index]);
                      Navigator.of(context).pop();
                    });
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: SizeConfig.blockSizeVertical * 0.8);
                  },
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class AddMealTile extends StatelessWidget {
  const AddMealTile(this.meal, this.callback, { Key key }) : super(key: key);

  final String meal;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(meal),
        trailing: ElevatedButton(
          onPressed: callback,
          child: Text('Add'),
        ),
      ),
    );
  }
}
