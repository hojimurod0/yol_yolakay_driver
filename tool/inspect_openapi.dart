// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('openapi.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final schemas = json['components']['schemas'] as Map<String, dynamic>;

  print('All schema names:');
  for (final k in schemas.keys) {
    if (k.toLowerCase().contains('driver') || k.toLowerCase().contains('profile') || k.toLowerCase().contains('status')) {
      print('  $k');
    }
  }
}
