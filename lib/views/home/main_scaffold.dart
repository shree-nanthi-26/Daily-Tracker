import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../tasks/tasks_screen.dart';
import '../habits/habits_screen.dart';
import '../goals/goals_screen.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/dashboard_top_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tabTitles = const [
    'Daily Work Dashboard',
    'Task Management',
    'Habit Tracker & Consistency',
    'Goals & Targets',
  ];

  void _onTabSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateTab: _onTabSelect),
      const TasksScreen(),
      const HabitsScreen(),
      const GoalsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        if (isDesktop) {
          // Desktop / Tablet Landscape Layout
          return Scaffold(
            backgroundColor: AppColors.bgMain,
            body: Row(
              children: [
                // Fixed Left Sidebar
                DashboardSidebar(
                  selectedIndex: _currentIndex,
                  onTabSelected: _onTabSelect,
                ),

                // Main Dashboard & Pages Canvas
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopBar(
                        title: _tabTitles[_currentIndex],
                        showDrawerButton: false,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: screens,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile & Tablet Portrait Layout
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.bgMain,
          drawer: Drawer(
            child: SafeArea(
              bottom: false,
              child: DashboardSidebar(
                selectedIndex: _currentIndex,
                onTabSelected: (index) {
                  _onTabSelect(index);
                  Navigator.of(context).maybePop();
                },
                onCloseDrawer: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Container(
              color: Colors.black, // #000000 Status Bar background
              child: SafeArea(
                bottom: false,
                top: true,
                child: DashboardTopBar(
                  title: _tabTitles[_currentIndex],
                  showDrawerButton: true,
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.navyPrimary,
              border: Border(
                top: BorderSide(color: AppColors.sidebarBorder, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabSelect,
                backgroundColor: AppColors.navyPrimary,
                selectedItemColor: AppColors.tealAccent,
                unselectedItemColor: AppColors.sidebarMutedText,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline_rounded),
                    activeIcon: Icon(Icons.check_circle_rounded),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.repeat_rounded),
                    activeIcon: Icon(Icons.repeat_on_rounded),
                    label: 'Habits',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.track_changes_outlined),
                    activeIcon: Icon(Icons.track_changes_rounded),
                    label: 'Goals',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
