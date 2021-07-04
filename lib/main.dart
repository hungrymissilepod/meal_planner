import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';
import 'package:mealplanner/models/planner_repository.dart';

/// Utilities
import 'package:mealplanner/utilities/size_config.dart';

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
  
  // TODO: app does not need to save data. But try to ensure that state is consistent when changing dates. So if I add a meal to the 1st, then change date to the 2nd, I should still see the meal I added to the 1st in the WeekScreen
  // TODO: comment all code

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
    SizeConfig().init(context);
    return BlocConsumer<PlannerCubit, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoaded) {
          return Scaffold(
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
      listener: (context, state) {
        /// When selectedDate is changed the state is reset to PlannerInitial. Here we will reload the meal planner.
        if (state is SelectedDateChanged) {
          BlocProvider.of<PlannerCubit>(context).loadPlanner();
        } else if (state is MealAdded) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal added: ${state.meal}')));
        }
      },
    );
  }
}