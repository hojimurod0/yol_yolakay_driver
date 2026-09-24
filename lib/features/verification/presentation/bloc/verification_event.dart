import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadCitiesEvent extends VerificationEvent {
  const LoadCitiesEvent();
}

class SubmitDriverApplicationEvent extends VerificationEvent {
  const SubmitDriverApplicationEvent({
    required this.textFields,
    required this.photoFiles,
  });

  final Map<String, dynamic> textFields;
  final Map<String, String> photoFiles;

  @override
  List<Object?> get props => [textFields, photoFiles];
}
