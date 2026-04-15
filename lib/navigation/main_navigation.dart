import 'package:flutter/material.dart';

import '../app/strings.dart';
import '../screens/challenges_screen.dart';
import '../screens/hub_home_screen.dart';
import '../screens/learn_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quiz_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Widget currentScreen = switch (_currentIndex) {
      0 => HubHomeScreen(
        onNavigateToTab: (index) => setState(() => _currentIndex = index),
      ),
      1 => const LearnScreen(),
      2 => const QuizScreen(),
      3 => const ChallengesScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: currentScreen,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 64,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorShape: const CircleBorder(),
                  indicatorColor: colorScheme.primary.withAlpha(28),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return IconThemeData(
                      size: 24,
                      color:
                          selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected:
                      (index) => setState(() => _currentIndex = index),
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: AppStrings.get('home', context),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.menu_book_outlined),
                      selectedIcon: const Icon(Icons.menu_book),
                      label: AppStrings.get('learn', context),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.quiz_outlined),
                      selectedIcon: const Icon(Icons.quiz),
                      label: AppStrings.get('quiz', context),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.flag_outlined),
                      selectedIcon: const Icon(Icons.flag),
                      label: AppStrings.get('challenges', context),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: const Icon(Icons.person),
                      label: AppStrings.get('profile', context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
