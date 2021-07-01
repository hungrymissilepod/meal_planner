/// Bloc
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealplanner/models/planner_repository.dart';

/// Utilities
import 'package:equatable/equatable.dart';

/// Models
import 'package:mealplanner/models/planner_models.dart';

part 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit(this._plannerRepository) : super(PlannerInitial());

  final PlannerRepository _plannerRepository;

  Future<void> loadPlanner() async {
    emit(PlannerLoading());
    try {
      final days = await _plannerRepository.fetchWeeklyPlan();
      emit(PlannerLoaded(days));
    } catch (e) {
      emit(PlannerError('Failed to load planner'));
    }
  }
}