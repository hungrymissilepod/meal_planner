import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';
import 'package:mealplanner/models/planner_models.dart';
import 'package:mealplanner/models/planner_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlannerCubit(PlannerRepository()),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({ Key key }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // TODO: clean up code and UI - get basic UI looking as it should

  PageController _pageController;
  /// Current page shown in PageView
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    /// Load user's meal plan on app start
    BlocProvider.of<PlannerCubit>(context).initialiseSelectedDate();
    BlocProvider.of<PlannerCubit>(context).loadPlanner();
    
    _pageController = PageController(initialPage: _currentPage);
  }
  
  /// When navbar item is tapped, change page in PageView
  void _onNavBarItemTapped(int index) {
    _pageController.jumpToPage(index);
    _setCurrentPage(index);
  }

  /// Update [_currentPage] so the correct page is highlighted in BottomNavigationBar
  void _setCurrentPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerCubit, PlannerState>(
      listener: (context, state) {
        // TODO: double check this. Do we want this behaviour??
        if (state is MealAdded) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal added: ${state.meal}')));
        }
        if (state is PlannerInitial) {
          BlocProvider.of<PlannerCubit>(context).loadPlanner();
        }
      },
      builder: (context, state) {
        if (state is PlannerLoaded) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                BlocProvider.of<PlannerCubit>(context).testChangeDate();
              },
            ),
            body: PageView(
              onPageChanged: _setCurrentPage, /// this ensures that the correct page is highlighted when scrolling to different page
              controller: _pageController,
              children: [
                DayPage(state),
                WeekPage(state),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: _onNavBarItemTapped,
              currentIndex: _currentPage,
              items: [
                BottomNavigationBarItem(
                  label: 'Day',
                  icon: Icon(Icons.view_day),
                ),
                BottomNavigationBarItem(
                  label: 'Week',
                  icon: Icon(Icons.view_week),
                ),
              ],
            ),
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class DayPage extends StatelessWidget {
  const DayPage(this.state, { Key key }) : super(key: key);
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

class WeekPage extends StatelessWidget {
  const WeekPage(this.state, { Key key }) : super(key: key);
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

// TODO: should get data from JSON or somewhere and show meals for THAT date
// TODO: rename to something better
class MealsForDay extends StatelessWidget {
  const MealsForDay(this.dayPlan, { Key key }) : super(key: key);
  final DayPlan dayPlan;

  @override
  Widget build(BuildContext context) {
    // print(dayPlan.date);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(dayPlan.date), // TODO: show in correct format
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
    );
  }
}

// TODO: comment this and explain that it is not mine
// https://gist.github.com/slightfoot/a75d6c368f1b823b594d9f04bf667231
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
      color: Colors.red,
      child: ListTile(
        title: Text(label),
      ),
    );
  }
}

// TODO: this widget should take label and ontap as arguements
// class CustomButton extends StatelessWidget {
//   const CustomButton(this.date, { Key key }) : super(key: key);

//   final String date;

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       child: Text("Add Meal"),
//       onPressed: () {
//         if(Platform.isIOS) { Navigator.of(context).push(MaterialPageRoute(builder: (context) => MealSelectScreen(date), settings: RouteSettings(name: 'MealSelectScreen'))); }
//         else { Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => MealSelectScreen(date), settings: RouteSettings(name: 'MealSelectScreen'))); }
//       },
//       style: ElevatedButton.styleFrom(
//         primary: Colors.red,
//         onPrimary: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(32.0),
//         ),
//       ),
//     );
//   }
// }

class ChangeDateButton extends StatelessWidget {
  const ChangeDateButton({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Change Date',
      // TODO: should open date picker and allow user to change selectedDate
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
        primary: Colors.red,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }
}

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