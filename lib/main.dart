import 'package:flutter/material.dart';

/// Bloc + Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/cubit/planner_cubit.dart';
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
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

  // TODO: ensure we can add meals from list for certain days
  // TODO: clean up code and UI - get basic UI looking as it should
  // TODO: create Meals list screen
  // TODO: tapping Add meal button should go to Meals list screen. Should be able to navigate back

  PageController _pageController;
  /// Current page shown in PageView
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    BlocProvider.of<PlannerCubit>(context).loadPlanner(); // * load data from config. In real app this would be from server or device storage
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
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoaded) {
          print(state.weekPlan.days[0].date);
          print(state.weekPlan.days[0].meals.toString());
          return Scaffold(
            body: PageView(
              onPageChanged: _setCurrentPage, /// this ensures that the correct page is highlighted when scrolling to different page
              controller: _pageController,
              children: [
                DayPage(),
                WeekPage(),
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
  const DayPage({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Center(
          child: Column(
            children: [
              CustomButton(), // TODO: date picker button
              SizedBox(height: 10),
              MealsForDay(),
            ],
          ),
        ),
      ),
    );
  }
}

class WeekPage extends StatelessWidget {
  const WeekPage({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Center(
          child: Column(
            children: [
              MealsForDay(),
              MealsForDay(),
              MealsForDay(),
              MealsForDay(),
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: should show correct date
// TODO: should get data from JSON or somewhere and show meals for THAT date
// TODO: rename to something better
class MealsForDay extends StatelessWidget {
  const MealsForDay({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('1st June'),
            CustomButton(),
          ],
        ),
        // TODO: should show all meals for this day
        ColumnBuilder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return CustomListTile();
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

// TODO: this widget should take a title as arguement
class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.red,
      child: ListTile(
        title: Text('Stir Fry'),
      ),
    );
  }
}

// TODO: this widget should take label and ontap as arguements
class CustomButton extends StatelessWidget {
  const CustomButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text("ElevatedButton"),
      onPressed: () => print("it's pressed"),
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