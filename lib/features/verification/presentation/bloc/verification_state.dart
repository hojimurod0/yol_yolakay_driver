import 'package:equatable/equatable.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/verification_entities.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();
  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

class CitiesLoadedState extends VerificationState {
  const CitiesLoadedState(this.cities);
  final List<CityEntity> cities;

  @override
  List<Object?> get props => [cities];
}

class SubmittingApplicationState extends VerificationState {
  const SubmittingApplicationState();
}

class ApplicationSubmittedSuccessState extends VerificationState {
  const ApplicationSubmittedSuccessState(this.response);
  final DriverApplicationResponseEntity response;

  @override
  List<Object?> get props => [response];
}

class VerificationErrorState extends VerificationState {
  const VerificationErrorState({
    required this.message,
    this.fieldErrors = const [],
  });

  final String message;
  final List<FieldError> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}
