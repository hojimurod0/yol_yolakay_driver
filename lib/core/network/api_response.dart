import 'package:equatable/equatable.dart';

/// Standard Pagination model used across all paginated endpoints.
class PaginationModel extends Equatable {
  const PaginationModel({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 15,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total_items': totalItems,
        'total_pages': totalPages,
      };

  @override
  List<Object?> get props => [page, limit, totalItems, totalPages];
}

/// Generic Paginated List response envelope.
class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationModel pagination;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) itemParser,
  ) {
    final rawItems = json['items'];
    final List<T> itemsList = [];
    if (rawItems is List) {
      for (final raw in rawItems) {
        itemsList.add(itemParser(raw));
      }
    }

    final rawPagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse<T>(
      items: itemsList,
      pagination: PaginationModel.fromJson(rawPagination),
    );
  }

  @override
  List<Object?> get props => [items, pagination];
}

/// Universal backend API response envelope.
class ApiResponse<T> extends Equatable {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  final bool success;
  final String message;
  final T? data;
  final ApiErrorDetails? error;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic dataJson)? fromData,
  ]) {
    final bool success = json['success'] == true;
    final String message = json['message']?.toString() ?? '';
    final dynamic rawData = json['data'];
    final dynamic rawError = json['error'];

    T? parsedData;
    if (rawData != null && fromData != null) {
      parsedData = fromData(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    }

    ApiErrorDetails? parsedError;
    if (rawError is Map<String, dynamic>) {
      parsedError = ApiErrorDetails.fromJson(rawError);
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      data: parsedData,
      error: parsedError,
    );
  }

  @override
  List<Object?> get props => [success, message, data, error];
}

/// Detailed structured backend error representation.
class ApiErrorDetails extends Equatable {
  const ApiErrorDetails({
    required this.code,
    this.details = const [],
  });

  final String code;
  final List<FieldError> details;

  factory ApiErrorDetails.fromJson(Map<String, dynamic> json) {
    final List<FieldError> fields = [];
    final rawDetails = json['details'];
    if (rawDetails is List) {
      for (final d in rawDetails) {
        if (d is Map<String, dynamic>) {
          fields.add(FieldError.fromJson(d));
        }
      }
    } else if (rawDetails is Map<String, dynamic>) {
      rawDetails.forEach((k, v) {
        if (v is List) {
          for (final msg in v) {
            fields.add(FieldError(field: k, message: msg.toString()));
          }
        } else {
          fields.add(FieldError(field: k, message: v.toString()));
        }
      });
    }

    return ApiErrorDetails(
      code: json['code']?.toString() ?? 'UNKNOWN_ERROR',
      details: fields,
    );
  }

  @override
  List<Object?> get props => [code, details];
}

class FieldError extends Equatable {
  const FieldError({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [field, message];
}
