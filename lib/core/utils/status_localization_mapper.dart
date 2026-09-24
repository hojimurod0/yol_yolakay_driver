import '../widgets/app_status_chip.dart';

/// Presentation-layer status mapper that translates backend string/enum values
/// into localized user-facing strings and semantic UI badge variants.
/// Strictly maps presentation text without modifying domain/data layers.
abstract class StatusLocalizationMapper {
  /// Returns localized status string for backend status values
  static String mapStatus(String? status, {String locale = 'uz'}) {
    final normalized = status?.trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'pending':
      case 'kutilmoqda':
        return switch (locale) {
          'ru' => 'Ожидается',
          'en' => 'Pending',
          _ => 'Kutilmoqda',
        };

      case 'approved':
      case 'tasdiqlangan':
        return switch (locale) {
          'ru' => 'Одобрено',
          'en' => 'Approved',
          _ => 'Tasdiqlangan',
        };

      case 'confirmed':
        return switch (locale) {
          'ru' => 'Подтверждено',
          'en' => 'Confirmed',
          _ => 'Tasdiqlangan',
        };

      case 'rejected':
      case 'rad_etilgan':
        return switch (locale) {
          'ru' => 'Отклонено',
          'en' => 'Rejected',
          _ => 'Rad etilgan',
        };

      case 'completed':
      case 'yakunlangan':
      case 'tugallangan':
        return switch (locale) {
          'ru' => 'Завершено',
          'en' => 'Completed',
          _ => 'Yakunlangan',
        };

      case 'cancelled':
      case 'bekor_qilingan':
      case 'canceled':
        return switch (locale) {
          'ru' => 'Отменено',
          'en' => 'Cancelled',
          _ => 'Bekor qilingan',
        };

      case 'active':
      case 'faol':
        return switch (locale) {
          'ru' => 'Активный',
          'en' => 'Active',
          _ => 'Faol',
        };

      case 'in_progress':
      case 'jarayonda':
        return switch (locale) {
          'ru' => 'В пути',
          'en' => 'In Progress',
          _ => 'Jarayonda',
        };

      case 'arrived':
      case 'yetib_keldi':
        return switch (locale) {
          'ru' => 'Прибыл',
          'en' => 'Arrived',
          _ => 'Yetib keldi',
        };

      case 'accepted':
      case 'qabul_qilingan':
        return switch (locale) {
          'ru' => 'Принят',
          'en' => 'Accepted',
          _ => 'Qabul qilindi',
        };

      case 'online':
        return switch (locale) {
          'ru' => 'На линии',
          'en' => 'Online',
          _ => 'Onlayn',
        };

      case 'offline':
        return switch (locale) {
          'ru' => 'Не на линии',
          'en' => 'Offline',
          _ => 'Oflayn',
        };

      case 'on_trip':
        return switch (locale) {
          'ru' => 'В рейсе',
          'en' => 'On Trip',
          _ => 'Safarda',
        };

      default:
        return status ?? '';
    }
  }

  /// Maps backend status string to [StatusVariant] for [AppStatusChip]
  static StatusVariant mapVariant(String? status) {
    final normalized = status?.trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'pending':
      case 'kutilmoqda':
        return StatusVariant.pending;

      case 'approved':
      case 'confirmed':
      case 'tasdiqlangan':
        return StatusVariant.approved;

      case 'rejected':
      case 'rad_etilgan':
        return StatusVariant.rejected;

      case 'completed':
      case 'yakunlangan':
      case 'tugallangan':
        return StatusVariant.completed;

      case 'cancelled':
      case 'bekor_qilingan':
      case 'canceled':
        return StatusVariant.cancelled;

      case 'active':
      case 'faol':
        return StatusVariant.active;

      case 'in_progress':
      case 'jarayonda':
        return StatusVariant.inProgress;

      case 'arrived':
      case 'yetib_keldi':
        return StatusVariant.arrived;

      case 'online':
        return StatusVariant.online;

      case 'offline':
      default:
        return StatusVariant.offline;
    }
  }
}
