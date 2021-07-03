part of 'planner_cubit.dart';

@immutable
abstract class PlannerState extends Equatable {
  const PlannerState();
}

class PlannerInitial extends PlannerState {
  const PlannerInitial();
  
  @override
  List<Object> get props => [];
}

class PlannerLoading extends PlannerState {
  const PlannerLoading();

  @override
  List<Object> get props => [];
}

class PlannerLoaded extends PlannerState {
  final WeekPlan weekPlan;
  const PlannerLoaded(this.weekPlan);

  @override
  List<Object> get props => [weekPlan];
}

class PlannerError extends PlannerState {
  final String message;
  const PlannerError(this.message);

  @override
  List<Object> get props => [message];
}

class MealAdded extends PlannerState {
  final String meal;
  const MealAdded(this.meal);

  @override
  List<Object> get props => [meal];
}