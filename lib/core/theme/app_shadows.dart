import 'package:flutter/material.dart';

/// Centralized subtle, modern elevation shadows for cards, bottom sheets, and floating bars.
/// Strictly minimal, low-alpha to eliminate harsh visual noise.
abstract class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000), // ~8% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> yellowGlow = [
    BoxShadow(
      color: Color(0x28FFC107),
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cyanGlow = yellowGlow;
  static const List<BoxShadow> plumGlow = yellowGlow;

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% opacity
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x33000000), // ~20% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x40000000), // ~25% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
