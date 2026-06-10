import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/categories/data/category_repository.dart';
import 'features/categories/logic/category_cubit.dart';
import 'features/categories/presentation/category_screen.dart';
import 'features/dashboard/data/transaction_repository.dart';
import 'features/dashboard/logic/dashboard_cubit.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient(baseUrl: AppConfig.apiBaseUrl);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CategoryCubit(CategoryRepository(api))..load(),
        ),
        BlocProvider(
          create: (_) => DashboardCubit(TransactionRepository(api))..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: true,
        theme: AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.sizeOf(context).width >= 1200,
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(
                Icons.account_balance_wallet,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: Text('Categories'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [DashboardScreen(), CategoryScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
