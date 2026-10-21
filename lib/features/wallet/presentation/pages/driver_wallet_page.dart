import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/earnings_stats_entity.dart';
import '../../domain/entities/wallet_history_entity.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class DriverWalletPage extends StatefulWidget {
  const DriverWalletPage({super.key});

  @override
  State<DriverWalletPage> createState() => _DriverWalletPageState();
}

class _DriverWalletPageState extends State<DriverWalletPage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  String? _pendingPaymentInvoiceId;
  DateTime? _lastResumeCheckTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<WalletBloc>().add(const LoadWalletDataEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _pendingPaymentInvoiceId != null) {
      // Deduplicate rapid resume triggers within 3 seconds
      final now = DateTime.now();
      if (_lastResumeCheckTime == null ||
          now.difference(_lastResumeCheckTime!).inSeconds >= 3) {
        _lastResumeCheckTime = now;
        // Verify payment strictly through backend
        context.read<WalletBloc>().add(
              VerifyPaymentEvent(invoiceId: _pendingPaymentInvoiceId),
            );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WalletBloc>().add(const LoadMoreTransactionsEvent());
    }
  }

  String _formatAmount(int amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toString();
    final chars = absAmount.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '${isNegative ? '-' : ''}$formatted';
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
          'Hamyon va Daromadlar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state.depositInvoice != null) {
            _handlePaymentInitiation(context, state.depositInvoice!);
          } else if (state.paymentVerificationStatus ==
              PaymentVerificationStatus.verified) {
            _pendingPaymentInvoiceId = null;
            AppSnackBar.showSuccess(
              context,
              'To\'lov muvaffaqiyatli qabul qilindi va balans yangilandi!',
            );
          } else if (state.paymentVerificationStatus ==
              PaymentVerificationStatus.failed) {
            AppSnackBar.showInfo(
              context,
              'To\'lov hali tasdiqlanmadi. Qayta urinib ko\'ring yoki biroz kuting.',
            );
          } else if (state.depositError != null) {
            AppSnackBar.showError(context, state.depositError!);
          }
        },
        builder: (context, state) {
          if (state.status == WalletStatus.loading && state.wallet == null) {
            return const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TransactionShimmer(),
                  SizedBox(height: 16),
                  TransactionShimmer(),
                ],
              ),
            );
          }

          if (state.status == WalletStatus.error && state.wallet == null) {
            if (state.errorMessage?.contains('internet') == true ||
                state.errorMessage?.contains('aloqa') == true) {
              return NoInternetWidget(
                onRetry: () => context
                    .read<WalletBloc>()
                    .add(const LoadWalletDataEvent(refresh: true)),
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
                          .read<WalletBloc>()
                          .add(const LoadWalletDataEvent(refresh: true)),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<WalletBloc>()
                  .add(const LoadWalletDataEvent(refresh: true));
            },
            color: AppColors.primary,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppResponsive.maxContentWidth,
                ),
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.horizontalPadding(context),
                    vertical: 16,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildBalanceCard(context, state, isDark),
                    const SizedBox(height: 16),
                    _buildEarningsSection(context, state, isDark),
                    const SizedBox(height: 24),
                    _buildTransactionsSection(context, state, isDark),
                    if (state.isLoadingMore) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, WalletState state, bool isDark) {
    final balance = state.wallet?.balance ?? 0;
    final isLow = state.wallet?.isBalanceLow ?? false;
    final minThreshold = state.wallet?.minBalanceThreshold ?? 20000;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLow
              ? AppColors.warning
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isLow ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Joriy balans',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 14, color: AppColors.primaryDark),
                    SizedBox(width: 4),
                    Text(
                      'Asosiy hamyon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${_formatAmount(balance)} so\'m',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isLow
                    ? AppColors.warning
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ),
          if (isLow) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Balansingiz minimal (${_formatAmount(minThreshold)} so\'m) dan kam. Buyurtmalarni qabul qilish uchun to\'ldiring.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDepositModal(context),
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.charcoalBlack),
              label: const Text(
                'Hisobni to\'ldirish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalBlack,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(
      BuildContext context, WalletState state, bool isDark) {
    final earnings = state.earnings;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daromadlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSubtleDark
                      : AppColors.surfaceSubtleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildPeriodTab(context, 'today', 'Bugun',
                        state.selectedPeriod, isDark),
                    _buildPeriodTab(context, 'weekly', 'Hafta',
                        state.selectedPeriod, isDark),
                    _buildPeriodTab(
                        context, 'monthly', 'Oy', state.selectedPeriod, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (earnings != null) ...[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        title: 'Jami daromad',
                        value: '${_formatAmount(earnings.totalEarnings)} so\'m',
                        icon: Icons.monetization_on_outlined,
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        title: 'Safarlar soni',
                        value: '${earnings.totalTrips} ta',
                        icon: Icons.local_taxi_outlined,
                        color: AppColors.info,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        title: 'Masofa',
                        value:
                            '${earnings.totalDistanceKm.toStringAsFixed(1)} km',
                        icon: Icons.route_outlined,
                        color: AppColors.warning,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        title: 'Onlayn vaqt',
                        value:
                            '${earnings.totalOnlineHours.toStringAsFixed(1)} soat',
                        icon: Icons.timer_outlined,
                        color: Colors.purple,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (earnings.chartData.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Kunlik grafik',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildMiniBarChart(earnings.chartData, isDark),
            ],
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodTab(
    BuildContext context,
    String period,
    String label,
    String currentPeriod,
    bool isDark,
  ) {
    final isSelected = currentPeriod == period;
    return GestureDetector(
      onTap: () {
        context
            .read<WalletBloc>()
            .add(ChangeEarningsPeriodEvent(period: period));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.charcoalBlack
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBarChart(
      List<EarningsChartPointEntity> chartData, bool isDark) {
    final maxEarnings = chartData.fold<int>(
      1,
      (max, e) => e.earnings > max ? e.earnings : max,
    );

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((item) {
          final double ratio = maxEarnings > 0
              ? (item.earnings / maxEarnings).clamp(0.05, 1.0)
              : 0.05;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.earnings > 0
                        ? '${(item.earnings / 1000).toInt()}k'
                        : '0',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 70 * ratio,
                    decoration: BoxDecoration(
                      color: item.earnings > 0
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsSection(
      BuildContext context, WalletState state, bool isDark) {
    final transactions = state.transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tranzaksiyalar tarixi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            if (state.wallet != null)
              Text(
                'Jami: ${state.wallet!.pagination.totalItems}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty) ...[
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'Hozircha tranzaksiyalar yo\'q',
            description:
                'Bajarilgan safarlar va hisob to\'ldirishlar shu yerda aks etadi.',
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionTile(tx, isDark);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionTile(TransactionEntity tx, bool isDark) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (tx.type) {
      case TransactionType.deposit:
        icon = Icons.arrow_downward_rounded;
        iconColor = AppColors.success;
        iconBg = AppColors.success.withValues(alpha: 0.15);
        break;
      case TransactionType.commission:
        icon = Icons.arrow_upward_rounded;
        iconColor = AppColors.error;
        iconBg = AppColors.error.withValues(alpha: 0.15);
        break;
      case TransactionType.bonus:
        icon = Icons.stars_rounded;
        iconColor = Colors.purple;
        iconBg = Colors.purple.withValues(alpha: 0.15);
        break;
      case TransactionType.cashback:
        icon = Icons.redeem_rounded;
        iconColor = AppColors.info;
        iconBg = AppColors.info.withValues(alpha: 0.15);
        break;
      default:
        icon = Icons.sync_alt_rounded;
        iconColor = Colors.grey;
        iconBg = Colors.grey.withValues(alpha: 0.15);
    }

    final dateStr =
        '${tx.createdAt.day.toString().padLeft(2, '0')}.${tx.createdAt.month.toString().padLeft(2, '0')}.${tx.createdAt.year} ${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tx.isIncome ? '+' : ''}${_formatAmount(tx.amount)} so\'m',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: tx.isIncome ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositModal(BuildContext context) {
    int selectedAmount = 50000;
    String selectedSystem = 'payme';
    final amountController = TextEditingController(text: '50000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final isDark = Theme.of(modalContext).brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hisobni to\'ldirish',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'To\'lov tizimini tanlang:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPaymentOption('Payme', 'payme', selectedSystem,
                          (val) {
                        setModalState(() => selectedSystem = val);
                      }, isDark),
                      const SizedBox(width: 8),
                      _buildPaymentOption('Click', 'click', selectedSystem,
                          (val) {
                        setModalState(() => selectedSystem = val);
                      }, isDark),
                      const SizedBox(width: 8),
                      _buildPaymentOption('Uzum', 'uzum', selectedSystem,
                          (val) {
                        setModalState(() => selectedSystem = val);
                      }, isDark),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Miqdor (so\'mda):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '50 000',
                      suffixText: 'so\'m',
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceSubtleDark
                          : AppColors.surfaceSubtleLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setModalState(() => selectedAmount = parsed);
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [20000, 50000, 100000, 200000].map((amt) {
                      final isSelected = selectedAmount == amt;
                      return ChoiceChip(
                        label: Text('+${_formatAmount(amt)}'),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            selectedAmount = amt;
                            amountController.text = amt.toString();
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.surfaceSubtleDark
                            : AppColors.surfaceSubtleLight,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAmount < 5000
                          ? null
                          : () {
                              Navigator.pop(sheetContext);
                              context.read<WalletBloc>().add(
                                    DepositRequestedEvent(
                                      amount: selectedAmount,
                                      paymentSystem: selectedSystem,
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Davom etish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoalBlack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    String label,
    String key,
    String selectedKey,
    ValueChanged<String> onSelect,
    bool isDark,
  ) {
    final isSelected = key == selectedKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : (isDark
                    ? AppColors.surfaceSubtleDark
                    : AppColors.surfaceSubtleLight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primaryDark
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePaymentInitiation(
      BuildContext context, DepositInvoiceEntity invoice) async {
    _pendingPaymentInvoiceId = invoice.invoiceId;

    final uri = Uri.parse(invoice.paymentUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            'To\'lov havolasini ochishda xatolik: $e',
          );
        }
      }
    }

    if (context.mounted) {
      _showPaymentStatusSheet(context, invoice);
    }
  }

  void _showPaymentStatusSheet(
      BuildContext context, DepositInvoiceEntity invoice) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isVerifying = state.isVerifyingPayment;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'To\'lov jarayoni',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To\'lov tizimi ochildi. To\'lovni amalga oshirgach yoki ilovaga qaytgach, hisobingiz server orqali avtomatik tekshiriladi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isVerifying) ...[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Server orqali tekshirilmoqda...',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<WalletBloc>().add(
                                VerifyPaymentEvent(
                                    invoiceId: invoice.invoiceId),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'To\'lovni tekshirish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final uri = Uri.parse(invoice.paymentUrl);
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Qayta ochish'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            context
                                .read<WalletBloc>()
                                .add(const ClearDepositInvoiceEvent());
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Yopish'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
