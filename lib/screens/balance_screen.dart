import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/balance_pie_chart.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  num totalExpenses = 0;
  num totalDonations = 0;
  num totalBalance = 0;

  Future<List<QuerySnapshot<Map<String, dynamic>>>> fetchData() async {
    var members = await FirebaseFirestore.instance.collection('members').get();
    var donations = await FirebaseFirestore.instance.collection('donations').get();
    var expenses = await FirebaseFirestore.instance.collection('expenses').get();
    var balance = await FirebaseFirestore.instance.collection('balance').get();

    return [members, donations, expenses, balance];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Balance: Rs.$totalBalance',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 2, 70, 133),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
              // Fetch all data
              future: fetchData(),
              builder: (context, AsyncSnapshot<List<QuerySnapshot<Map<String, dynamic>>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<DocumentSnapshot<Map<String, dynamic>>> members =
                      snapshot.data![0].docs.cast<DocumentSnapshot<Map<String, dynamic>>>();
                  totalDonations = snapshot.data![1].docs
                      .map((donation) => donation.data()['amount'])
                      .fold(0, (sum, donationAmount) => sum + (donationAmount ?? 0));
                  totalExpenses = snapshot.data![2].docs
                      .map((expense) => expense.data()['amount'])
                      .fold(0, (sum, expenseAmount) => sum + (expenseAmount ?? 0));
                  totalBalance = snapshot.data![3].docs.first.data()['balance'] ?? 0;

                  // Calculate total subscriptions
                  num totalSubscriptions = members
                      .map((member) => calculateTotalSubscription(member))
                      .fold(0, (sum, subscriptionAmount) => sum + subscriptionAmount);

                  return Expanded(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: BalancePieChart(
                        totalExpenses: totalExpenses,
                        totalDonations: totalDonations,
                        totalSubscriptions: totalSubscriptions,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  num calculateTotalSubscription(DocumentSnapshot<Map<String, dynamic>> member) {
    Map<String, dynamic> subscriptionStatus = member['subscriptionStatus'];
    int paidMonths = countPaidMonths(subscriptionStatus);
    num totalAmount = paidMonths * member['subscriptionAmount'];
    return totalAmount;
  }

  int countPaidMonths(Map<String, dynamic> subscriptionStatus) {
    int paidMonths = 0;

    for (String monthKey in subscriptionStatus.keys) {
      if (subscriptionStatus[monthKey] == true) {
        paidMonths++;
      }
    }

    return paidMonths;
  }
}
