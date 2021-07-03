import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';
import 'package:mealplanner/models/planner_repository.dart';

/// Screens
import 'package:mealplanner/screens/day_screen.dart';
import 'package:mealplanner/screens/week_screen.dart';

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
  // TODO: should be able to pick date and app should update and show selected dates meals
  // TODO: ensure all functionality is as specified in design doc
  // TODO: clean up UI and make it look nicer
  // TODO: ensure app scales correctly based on screensize. Maybe also make sure it scales in landscape mode
  // TODO: app does not need to save data. But try to ensure that state is consistent when changing dates. So if I add a meal to the 1st, then change date to the 2nd, I should still see the meal I added to the 1st in the WeekScreen

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
                DayScreen(state),
                WeekScreen(state),
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