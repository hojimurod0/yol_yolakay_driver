import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/features/home/presentation/pages/pilot_active_ride_page.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/data/models/intercity_ride_model.dart';

void main() {
  group('Ride passenger from the server', () {
    test('reads the door-to-door pickup point', () {
      final p = RidePassengerModel.fromJson(const {
        'booking_id': 'bk_1',
        'seats_count': 2,
        'total_price': 50000,
        'status': 'PENDING',
        'passenger': {'id': 'u1', 'name': 'Rustam', 'phone': '+998901112233'},
        'pickup_point': {
          'lat': 40.7186,
          'lng': '72.6423',
          'address': "Sokinlik ko'chasi",
        },
      });

      expect(p.passengerName, 'Rustam');
      expect(p.seatsCount, 2);
      expect(p.pickupLat, 40.7186);
      expect(p.pickupLng, 72.6423);
      expect(p.pickupAddress, "Sokinlik ko'chasi");
      expect(p.isPending, isTrue);
    });

    test('works without a pickup point (older bookings)', () {
      final p = RidePassengerModel.fromJson(const {
        'booking_id': 'bk_2',
        'passenger_id': 'u2',
        'status': 'confirmed',
      });

      expect(p.pickupLat, isNull);
      expect(p.isPending, isFalse);
      expect(p.isPickedUp, isFalse);
    });

    test('picked-up and declined statuses', () {
      RidePassengerModel withStatus(String s) => RidePassengerModel.fromJson(
          {'booking_id': 'b', 'passenger_id': 'u', 'status': s});

      expect(withStatus('picked_up').isPickedUp, isTrue);
      expect(withStatus('in_progress').isPickedUp, isTrue);
      expect(withStatus('rejected').isRejectedOrCancelled, isTrue);
      expect(withStatus('cancelled').isRejectedOrCancelled, isTrue);
      expect(withStatus('expired').isRejectedOrCancelled, isTrue);
    });
  });

  group('Request answer deadline', () {
    RidePassengerModel pending(Map<String, dynamic> extra) =>
        RidePassengerModel.fromJson({
          'booking_id': 'b',
          'passenger_id': 'u',
          'status': 'pending',
          ...extra,
        });
    final seen = DateTime.utc(2026, 10, 26, 10, 0, 5);

    test('reads expires_at, else two minutes after created_at', () {
      expect(pending({'expires_at': '2026-10-26T10:01:30Z'}).answerBy,
          DateTime.utc(2026, 10, 26, 10, 1, 30));
      expect(pending({'created_at': '2026-10-26T10:00:00Z'}).answerBy,
          DateTime.utc(2026, 10, 26, 10, 2));
      expect(pending({}).answerBy, isNull);
    });

    test('follows the server deadline inside the allowed range', () {
      final p = pending({'created_at': '2026-10-26T10:00:00Z'});
      expect(PilotActiveRidePage.offerDeadline(p, seen),
          DateTime.utc(2026, 10, 26, 10, 2));
    });

    test('never shorter than the minimum, never longer than the window', () {
      final late = pending({'created_at': '2026-10-26T09:00:00Z'});
      expect(PilotActiveRidePage.offerDeadline(late, seen),
          seen.add(PilotActiveRidePage.minOfferTime));

      final noTime = pending({});
      expect(PilotActiveRidePage.offerDeadline(noTime, seen),
          DateTime.utc(2026, 10, 26, 10, 2, 5));
    });
  });
}
