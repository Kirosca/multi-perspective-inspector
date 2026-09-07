import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import 'history_view.dart';
import 'settings_view.dart';
import 'upload_and_inspect_view.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final pages = [
      const UploadAndInspectView(),
      HistoryView(onNavigateToInspect: () => setState(() => _currentIndex = 0)),
      const SettingsView(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Desktop Sidebar Navigation
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.remove_red_eye_rounded,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '视角解读器',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  const SizedBox(height: 12),
                  _buildNavMenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    title: '解读工作台',
                    index: 0,
                  ),
                  _buildNavMenuItem(
                    icon: Icons.history_rounded,
                    activeIcon: Icons.history_edu_rounded,
                    title: '解读历史库',
                    index: 1,
                  ),
                  _buildNavMenuItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    title: '设置与接入',
                    index: 2,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_outlined,
                              size: 16, color: AppColors.accentEmerald),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '15 大预置工种已就绪',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(child: pages[_currentIndex]),
          ],
        ),
      );
    }

    // Mobile Layout with Bottom Navigation Bar
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        backgroundColor: Colors.white,
        elevation: 2,
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: '解读台',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon:
                Icon(Icons.history_edu_rounded, color: AppColors.primary),
            label: '历史库',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings_rounded, color: AppColors.primary),
            label: '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildNavMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: isSelected,
        selectedTileColor: AppColors.primaryLight,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.secondary,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        onTap: () => _onTabSelected(index),
      ),
    );
  }
}
