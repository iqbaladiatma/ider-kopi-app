import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppBrand {
  iderKopi(
    name: 'IderKopi',
    code: 'IK',
    tagline: 'Absensi Karyawan IderKopi',
    badgeText: 'Mode: IderKopi',
    iconData: Icons.coffee_rounded,
    primaryColor: Color(0xFFE11D2E),
    lightColor: Color(0xFFFDECEE),
  ),
  iderPoint(
    name: 'IderPoint',
    code: 'IP',
    tagline: 'Absensi Karyawan IderPoint',
    badgeText: 'Mode: IderPoint',
    iconData: Icons.place_rounded,
    primaryColor: Color(0xFFD97706),
    lightColor: Color(0xFFFEF3C7),
  );

  const AppBrand({
    required this.name,
    required this.code,
    required this.tagline,
    required this.badgeText,
    required this.iconData,
    required this.primaryColor,
    required this.lightColor,
  });

  final String name;
  final String code;
  final String tagline;
  final String badgeText;
  final IconData iconData;
  final Color primaryColor;
  final Color lightColor;
}

class AppBrandNotifier extends StateNotifier<AppBrand> {
  AppBrandNotifier() : super(AppBrand.iderKopi);

  void setBrand(AppBrand brand) {
    state = brand;
  }

  void toggleBrand() {
    state = state == AppBrand.iderKopi ? AppBrand.iderPoint : AppBrand.iderKopi;
  }
}

final activeBrandProvider = StateNotifierProvider<AppBrandNotifier, AppBrand>((ref) {
  return AppBrandNotifier();
});
