import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../features/admin/presentation/admin_attendance_page.dart';
import '../../features/admin/presentation/admin_dashboard_page.dart';
import '../../features/admin/presentation/admin_profile_page.dart';
import '../../features/admin/presentation/admin_users_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late PageController _pageController;

  int _getPageIndex(String path) {
    if (path == '/admin/attendance') return 1;
    if (path == '/admin/users') return 2;
    if (path == '/admin/profile') return 3;
    return 0; // /admin
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(int targetPage) {
    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final pageIndex = _getPageIndex(location);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPage(pageIndex);
    });

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          AdminDashboardPage(),
          AdminAttendancePage(),
          AdminUsersPage(),
          AdminProfilePage(),
        ],
      ),
      bottomNavigationBar: _AdminBottomNav(currentPath: location),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_rounded, label: 'Beranda', path: '/admin'),
      (
        icon: Icons.check_circle_outline_rounded,
        label: 'Absensi',
        path: '/admin/attendance'
      ),
      (icon: Icons.storefront_rounded, label: 'Outlet', path: '/admin/users'),
      (icon: Icons.person_rounded, label: 'Profil', path: '/admin/profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isActive = currentPath == item.path;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    HapticFeedback.selectionClick();
                    context.go(item.path);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.redLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isActive ? AppColors.red : AppColors.muted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.red : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
