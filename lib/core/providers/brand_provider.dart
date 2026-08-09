import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppBrand {
  iderKopi(
    name: 'IderKopi (Semua Outlet)',
    code: 'IK-ALL',
    tagline: 'Absensi Karyawan IderKopi',
    badgeText: 'Mode: IderKopi (Semua)',
    iconData: Icons.coffee_rounded,
    primaryColor: Color(0xFFE11D2E),
    lightColor: Color(0xFFFDECEE),
    outletFilter: null,
  ),
  iderKopiMalioboro(
    name: 'IderKopi - Malioboro',
    code: 'IK-MLB',
    tagline: 'Outlet Malioboro',
    badgeText: 'Mode: Malioboro',
    iconData: Icons.storefront_rounded,
    primaryColor: Color(0xFFE11D2E),
    lightColor: Color(0xFFFDECEE),
    outletFilter: 'Malioboro',
  ),
  iderKopiKotabaru(
    name: 'IderKopi - Kotabaru',
    code: 'IK-KTB',
    tagline: 'Outlet Kotabaru',
    badgeText: 'Mode: Kotabaru',
    iconData: Icons.storefront_rounded,
    primaryColor: Color(0xFFC01525),
    lightColor: Color(0xFFFDECEE),
    outletFilter: 'Kotabaru',
  ),
  iderKopiSudirman(
    name: 'IderKopi - Sudirman',
    code: 'IK-SDR',
    tagline: 'Outlet Sudirman',
    badgeText: 'Mode: Sudirman',
    iconData: Icons.storefront_rounded,
    primaryColor: Color(0xFF9E101D),
    lightColor: Color(0xFFFDECEE),
    outletFilter: 'Sudirman',
  ),
  iderPoint(
    name: 'IderPoint',
    code: 'IP',
    tagline: 'Absensi Karyawan IderPoint',
    badgeText: 'Mode: IderPoint',
    iconData: Icons.place_rounded,
    primaryColor: Color(0xFFD97706),
    lightColor: Color(0xFFFEF3C7),
    outletFilter: 'IderPoint',
  );

  const AppBrand({
    required this.name,
    required this.code,
    required this.tagline,
    required this.badgeText,
    required this.iconData,
    required this.primaryColor,
    required this.lightColor,
    this.outletFilter,
  });

  final String name;
  final String code;
  final String tagline;
  final String badgeText;
  final IconData iconData;
  final Color primaryColor;
  final Color lightColor;
  final String? outletFilter;
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

