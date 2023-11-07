// expenses_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> expenses = snapshot.data!.docs;
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return buildExpenseTile(expenses[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildExpenseTile(DocumentSnapshot expense) {
    return ListTile(
      title: Text(expense['description']),
      subtitle: Text('Amount: Rs. ${expense['amount']}'),
    );
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addExpense();
                Navigator.of(context).pop();
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  void _addExpense() {
    String description = _descriptionController.text.trim();
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (description.isNotEmpty && amount > 0) {

      // Update the collected balance by deducting the expense
      updateCollectedBalance(-amount);
      FirebaseFirestore.instance.collection('expenses').add({
        'description': description,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input. Please fill out all fields')),
      );
    }

    // Clear the controllers
    _descriptionController.clear();
    _amountController.clear();
  }

  void updateCollectedBalance(double amount) {
    FirebaseFirestore.instance.collection('balance').doc('collectedBalance').update({
      'balance': FieldValue.increment(amount),
    });
  }

}
