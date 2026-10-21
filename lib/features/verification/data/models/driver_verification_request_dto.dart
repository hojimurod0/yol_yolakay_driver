import 'dart:io';
import 'package:dio/dio.dart';
import '../../presentation/widgets/verification_formatters.dart';

/// Central whitelist of exactly the 6 files accepted by the backend OpenAPI
/// (SubmitDriverApplicationRequest) Multer file interceptor.
const List<String> allowedVerificationFileFields = [
  'driver_license_front',
  'driver_license_back',
  'tech_passport_front',
  'tech_passport_back',
  'car_front_photo',
  'car_interior_photo',
];

/// Central whitelist of the 12 text fields accepted by the backend OpenAPI
/// (SubmitDriverApplicationRequest).
const List<String> allowedVerificationTextFields = [
  'first_name',
  'last_name',
  'birth_date',
  'gender',
  'car_model',
  'car_color',
  'car_year',
  'plate_number',
  'tech_passport_number',
  'driver_license_number',
  'car_seats_count',
  'has_ac',
];

/// UI Form State holding user inputs across wizard steps.
class DriverVerificationFormData {
  const DriverVerificationFormData({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.gender = 'male',
    required this.carModel,
    required this.carColor,
    required this.carYear,
    required this.plateNumber,
    required this.carSeatsCount,
    required this.hasAc,
    required this.techPassportSeries,
    required this.techPassportNumber,
    required this.licenseSeries,
    required this.licenseNumber,
    required this.photos,
  });

  final String firstName;
  final String lastName;
  final String birthDate;
  final String gender;
  final String carModel;
  final String carColor;
  final int carYear;
  final String plateNumber;
  final int carSeatsCount;
  final bool hasAc;
  final String techPassportSeries;
  final String techPassportNumber;
  final String licenseSeries;
  final String licenseNumber;
  final Map<String, String> photos;
}

/// Production DTO complying 100% with OpenAPI `SubmitDriverApplicationRequest`.
/// Whitelists exactly 12 text fields and 6 binary file fields.
/// Disallows all UI-only flags, temporary state, and non-whitelisted documents.
class DriverVerificationRequestDto {
  const DriverVerificationRequestDto({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.carModel,
    required this.carColor,
    required this.carYear,
    required this.plateNumber,
    required this.techPassportNumber,
    required this.driverLicenseNumber,
    required this.carSeatsCount,
    required this.hasAc,
    required this.photoFiles,
  });

  final String firstName;
  final String lastName;
  final String birthDate;
  final String gender;
  final String carModel;
  final String carColor;
  final int carYear;
  final String plateNumber;
  final String techPassportNumber;
  final String driverLicenseNumber;
  final int carSeatsCount;
  final bool hasAc;
  final Map<String, String> photoFiles;

  /// Central mapper: DriverVerificationFormData -> DriverVerificationRequestDto.
  /// Normalizes all values and strictly whitelists fields.
  factory DriverVerificationRequestDto.fromFormData(
      DriverVerificationFormData form) {
    final normalizedPlate =
        VerificationNormalizers.normalizePlateNumber(form.plateNumber);
    final normalizedTechPassport =
        VerificationNormalizers.normalizeTechPassport(
      form.techPassportSeries,
      form.techPassportNumber,
    );
    final normalizedDriverLicense =
        VerificationNormalizers.normalizeDriverLicense(
      form.licenseSeries,
      form.licenseNumber,
    );

    // Whitelist only the 6 backend-approved files
    final filteredPhotos = <String, String>{};
    for (final key in allowedVerificationFileFields) {
      final path = form.photos[key];
      if (path != null && path.trim().isNotEmpty) {
        filteredPhotos[key] = path.trim();
      }
    }

    return DriverVerificationRequestDto(
      firstName: VerificationNormalizers.normalizeName(form.firstName),
      lastName: VerificationNormalizers.normalizeName(form.lastName),
      birthDate: form.birthDate.trim(),
      gender: (form.gender == 'female') ? 'female' : 'male',
      carModel: form.carModel.trim(),
      carColor: form.carColor.trim(),
      carYear: form.carYear,
      plateNumber: normalizedPlate,
      techPassportNumber: normalizedTechPassport,
      driverLicenseNumber: normalizedDriverLicense,
      carSeatsCount: form.carSeatsCount.clamp(1, 8),
      hasAc: form.hasAc,
      photoFiles: filteredPhotos,
    );
  }

  /// Converts the DTO into the text fields Map for OpenAPI multipart payload.
  Map<String, dynamic> toTextFieldsMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'gender': gender,
      'car_model': carModel,
      'car_color': carColor,
      'car_year': carYear,
      'plate_number': plateNumber,
      'tech_passport_number': techPassportNumber,
      'driver_license_number': driverLicenseNumber,
      'car_seats_count': carSeatsCount,
      'has_ac': hasAc,
    };
  }

  /// Converts the DTO into Dio `FormData` containing only whitelisted fields.
  Future<FormData> toFormData() async {
    final map = <String, dynamic>{...toTextFieldsMap()};

    for (final key in allowedVerificationFileFields) {
      final filePath = photoFiles[key];
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final ext = filePath.split('.').last.toLowerCase();
          map[key] = await MultipartFile.fromFile(
            filePath,
            filename: '$key.${ext.isEmpty ? "jpg" : ext}',
          );
        }
      }
    }

    return FormData.fromMap(map);
  }
}
