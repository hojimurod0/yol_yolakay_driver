import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../verification/domain/entities/verification_entities.dart';
import '../../../verification/presentation/bloc/verification_bloc.dart';
import '../../../verification/presentation/bloc/verification_event.dart';
import '../../../verification/presentation/bloc/verification_state.dart';
import '../bloc/intercity_rides_bloc.dart';
import '../bloc/intercity_rides_event.dart';
import '../bloc/intercity_rides_state.dart';

class CreateDriverTripPage extends StatefulWidget {
  const CreateDriverTripPage({super.key});

  @override
  State<CreateDriverTripPage> createState() => _CreateDriverTripPageState();
}

class _CreateDriverTripPageState extends State<CreateDriverTripPage> {
  final _formKey = GlobalKey<FormState>();

  String? _fromCityId;
  String? _toCityId;
  DateTime _departureDateTime = DateTime.now().add(const Duration(hours: 2));
  final _priceController = TextEditingController(text: '80000');
  int _totalSeats = 4;
  bool _hasAc = true;
  bool _allowLuggage = true;
  bool _allowSmoking = false;
  bool _allowPets = false;
  bool _womenOnly = false;
  final _pickupController = TextEditingController(text: 'Shahar markazi');
  final _dropoffController = TextEditingController(text: 'Vokzal maydoni');
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>().add(const LoadCitiesEvent());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _departureDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_departureDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _departureDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submit(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;

    if (_fromCityId == null || _toCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectCitiesPrompt)),
      );
      return;
    }

    if (_fromCityId == _toCityId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.citiesMustBeDifferentPrompt)),
      );
      return;
    }

    final price = int.tryParse(_priceController.text.trim()) ?? 80000;

    final data = {
      'from_city_id': _fromCityId,
      'to_city_id': _toCityId,
      'departure_time': _departureDateTime.toUtc().toIso8601String(),
      'price_per_seat': price,
      'total_seats': _totalSeats,
      'has_ac': _hasAc,
      'allow_luggage': _allowLuggage,
      'allow_smoking': _allowSmoking,
      'allow_pets': _allowPets,
      'women_only': _womenOnly,
      'pickup_locations': [
        {'name': _pickupController.text.trim(), 'lat': 41.311, 'lng': 69.240}
      ],
      'dropoff_locations': [
        {'name': _dropoffController.text.trim(), 'lat': 39.654, 'lng': 66.959}
      ],
      'comment': _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
    };

    context.read<IntercityRidesBloc>().add(CreateRideEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;

    return BlocListener<IntercityRidesBloc, IntercityRidesState>(
      listener: (context, state) {
        if (state is RideCreatedSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tripCreatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          context
              .read<IntercityRidesBloc>()
              .add(const LoadRidesEvent(status: 'active'));
          context.pop();
        } else if (state is IntercityRidesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 0,
          title: Text(
            l10n.createTripTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
              children: [
                // Cities selection dropdowns
                BlocBuilder<VerificationBloc, VerificationState>(
                  builder: (context, vState) {
                    final cities = vState is CitiesLoadedState
                        ? vState.cities
                        : <CityEntity>[];

                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _fromCityId,
                          decoration: InputDecoration(
                            labelText: l10n.fromCityLabel,
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF1E1E26) : Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: cities.map<DropdownMenuItem<String>>((c) {
                            return DropdownMenuItem<String>(
                                value: c.id, child: Text(c.name));
                          }).toList(),
                          onChanged: (val) => setState(() => _fromCityId = val),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _toCityId,
                          decoration: InputDecoration(
                            labelText: l10n.toCityLabel,
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF1E1E26) : Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: cities.map<DropdownMenuItem<String>>((c) {
                            return DropdownMenuItem<String>(
                                value: c.id, child: Text(c.name));
                          }).toList(),
                          onChanged: (val) => setState(() => _toCityId = val),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Departure Date & Time Picker
                ListTile(
                  tileColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: isDark
                            ? const Color(0xFF2E2E3C)
                            : const Color(0xFFE2E4E8)),
                  ),
                  leading: const Icon(Icons.calendar_today_rounded,
                      color: AppColors.taxiYellowDark),
                  title: Text(l10n.departureDateLabel,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(
                    AppDateFormatter.formatDateTime(_departureDateTime,
                        locale: currentLocale),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: _selectDateTime,
                ),
                const SizedBox(height: 16),

                // Price and Seats
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.pricePerSeatLabel,
                          filled: true,
                          fillColor:
                              isDark ? const Color(0xFF1E1E26) : Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E26) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E2E3C)
                                  : const Color(0xFFE2E4E8)),
                        ),
                        child: DropdownButton<int>(
                          value: _totalSeats,
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: [1, 2, 3, 4, 5, 6, 7, 8].map((n) {
                            return DropdownMenuItem(
                                value: n, child: Text(l10n.seatsOption(n)));
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _totalSeats = val ?? 4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pickup & Dropoff location notes
                TextFormField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: l10n.pickupAddressLabel,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dropoffController,
                  decoration: InputDecoration(
                    labelText: l10n.dropoffAddressLabel,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Amenities
                Text(
                  l10n.amenitiesSectionTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.charcoalBlack),
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: _hasAc,
                  activeColor: AppColors.taxiYellowDark,
                  title: Text(l10n.hasAcLabel,
                      style: const TextStyle(fontSize: 13.5)),
                  onChanged: (v) => setState(() => _hasAc = v),
                ),
                SwitchListTile.adaptive(
                  value: _allowLuggage,
                  activeColor: AppColors.taxiYellowDark,
                  title: Text(l10n.allowLuggageLabel,
                      style: const TextStyle(fontSize: 13.5)),
                  onChanged: (v) => setState(() => _allowLuggage = v),
                ),
                SwitchListTile.adaptive(
                  value: _womenOnly,
                  activeColor: AppColors.taxiYellowDark,
                  title: Text(l10n.womenOnlyLabel,
                      style: const TextStyle(fontSize: 13.5)),
                  onChanged: (v) => setState(() => _womenOnly = v),
                ),

                const SizedBox(height: 16),

                // Comment
                TextFormField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.additionalCommentLabel,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 28),

                // Submit Button
                BlocBuilder<IntercityRidesBloc, IntercityRidesState>(
                  builder: (context, state) {
                    final isCreating = state is CreatingRideState;
                    return SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: l10n.publishTripAction,
                        onPressed: () => _submit(l10n),
                        isLoading: isCreating,
                        variant: AppButtonVariant.taxi,
                        height: 52,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
