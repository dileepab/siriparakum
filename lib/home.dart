import 'package:flutter/material.dart';
import 'package:siriparakum/screens/donation_screen.dart';
import 'package:siriparakum/screens/member_screen.dart';
import 'package:siriparakum/services/auth_service.dart';
import 'screens/balance_screen.dart';
import 'screens/expenses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  List<String> titles = <String>[
    'Home',
    'Members',
    'Expenses',
    'Donation'
  ];

  @override
  Widget build(BuildContext context) {
    const int tabsCount = 4; // Updated to match the number of tabs

    return DefaultTabController(
      initialIndex: 0,
      length: tabsCount,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Siriparakum'),
          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 1;
          },
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () async {
                // Replace with your own implementation or remove if not needed
                await _authService.signOut();
              },
            )
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: const Icon(Icons.monitor),
                text: titles[0],
              ),
              Tab(
                icon: const Icon(Icons.person),
                text: titles[1],
              ),
              Tab(
                icon: const Icon(Icons.payment_sharp),
                text: titles[2],
              ),
              Tab(
                icon: const Icon(Icons.volunteer_activism),
                text: titles[3],
              ),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            BalanceScreen(),
            MembersScreen(),
            ExpensesScreen(),
            DonationsScreen()
          ],
        ),
      ),
    );
  }
}
