import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Safely handles direct driver interactions (Calls, Telegram, SMS, Share).
class DirectContactLauncher {
  DirectContactLauncher._();

  /// Launch system phone dialer
  static Future<bool> makePhoneCall(
      BuildContext context, String phoneNumber) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Qo\'ng\'iroq qilib bo\'lmadi: $phoneNumber'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Launch Telegram chat with driver handle or phone
  static Future<bool> openTelegram(
      BuildContext context, String usernameOrPhone) async {
    HapticFeedback.lightImpact();
    final cleanHandle = usernameOrPhone.replaceAll('@', '').trim();
    final isNumber = RegExp(r'^[0-9+]+$').hasMatch(cleanHandle);

    final url = isNumber
        ? 'https://t.me/+${cleanHandle.replaceAll('+', '')}'
        : 'https://t.me/$cleanHandle';
    final uri = Uri.parse(url);

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Telegram ochilmadi: $url'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Launch SMS compose with pre-filled details
  static Future<bool> sendSms(
    BuildContext context,
    String phoneNumber, {
    String? body,
  }) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: body != null ? {'body': body} : null,
    );

    try {
      return await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS dasturi ochilmadi: $phoneNumber'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }
}
