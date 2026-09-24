import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/verification_usecases.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc({
    required GetCitiesUseCase getCitiesUseCase,
    required SubmitApplicationUseCase submitApplicationUseCase,
  })  : _getCitiesUseCase = getCitiesUseCase,
        _submitApplicationUseCase = submitApplicationUseCase,
        super(const VerificationInitial()) {
    on<LoadCitiesEvent>(_onLoadCities);
    on<SubmitDriverApplicationEvent>(_onSubmitApplication);
  }

  final GetCitiesUseCase _getCitiesUseCase;
  final SubmitApplicationUseCase _submitApplicationUseCase;

  Future<void> _onLoadCities(
    LoadCitiesEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());
    try {
      final cities = await _getCitiesUseCase();
      emit(CitiesLoadedState(cities));
    } on ApiException catch (e) {
      emit(VerificationErrorState(
        message: e.message,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      emit(VerificationErrorState(message: e.toString()));
    }
  }

  Future<void> _onSubmitApplication(
    SubmitDriverApplicationEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const SubmittingApplicationState());
    try {
      final response = await _submitApplicationUseCase(
        textFields: event.textFields,
        photoFiles: event.photoFiles,
      );
      emit(ApplicationSubmittedSuccessState(response));
    } on ApiException catch (e) {
      emit(VerificationErrorState(
        message: e.message,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      emit(VerificationErrorState(message: e.toString()));
    }
  }
}
