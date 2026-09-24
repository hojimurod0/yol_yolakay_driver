import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsBloc>().add(const LoadMoreNotificationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Bildirishnomalar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final hasUnread = state.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  context
                      .read<NotificationsBloc>()
                      .add(const MarkAllNotificationsReadEvent());
                },
                child: const Text(
                  'Barchasi o\'qildi',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading &&
              state.notifications.isEmpty) {
            return const NotificationShimmer();
          }

          if (state.status == NotificationsStatus.error &&
              state.notifications.isEmpty) {
            if (state.errorMessage?.contains('internet') == true ||
                state.errorMessage?.contains('aloqa') == true) {
              return NoInternetWidget(
                onRetry: () => context
                    .read<NotificationsBloc>()
                    .add(const LoadNotificationsEvent(refresh: true)),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 54, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Xatolik yuz berdi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<NotificationsBloc>()
                          .add(const LoadNotificationsEvent(refresh: true)),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<NotificationsBloc>()
                    .add(const LoadNotificationsEvent(refresh: true));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  EmptyStateWidget(
                    icon: Icons.notifications_none_rounded,
                    title: 'Hozircha yangi xabarlar yo\'q',
                    description:
                        'Yangi buyurtmalar va yangiliklar haqidagi xabarlar shu yerda saqlanadi.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NotificationsBloc>()
                  .add(const LoadNotificationsEvent(refresh: true));
            },
            color: AppColors.primary,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  state.notifications.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == state.notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final notif = state.notifications[index];
                return _buildNotificationCard(context, notif, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    DriverNotificationEntity notif,
    bool isDark,
  ) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (notif.type) {
      case 'new_booking_request':
        icon = Icons.event_seat_rounded;
        iconColor = AppColors.primary;
        iconBg = AppColors.primary.withOpacity(0.15);
        break;
      case 'order_status':
        icon = Icons.local_taxi_rounded;
        iconColor = AppColors.info;
        iconBg = AppColors.info.withOpacity(0.15);
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.warning;
        iconBg = AppColors.warning.withOpacity(0.15);
        break;
      default:
        icon = Icons.notifications_active_outlined;
        iconColor = Colors.purple;
        iconBg = Colors.purple.withOpacity(0.15);
    }

    final dateStr =
        '${notif.createdAt.day.toString().padLeft(2, '0')}.${notif.createdAt.month.toString().padLeft(2, '0')} ${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          context
              .read<NotificationsBloc>()
              .add(MarkNotificationReadEvent(notif.id));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : AppColors.primary.withOpacity(0.5),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            if (!notif.isRead)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notif.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
