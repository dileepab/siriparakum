import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> donations = snapshot.data!.docs;
            return ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                return buildDonationTile(donations[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDonationDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildDonationTile(DocumentSnapshot donation) {
    return ListTile(
      title: Text(donation['description']),
      subtitle: Text('Amount: Rs. ${donation['amount']}'),
    );
  }

  Future<void> _showAddDonationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Donation'),
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
                _addDonation();
                Navigator.of(context).pop();
              },
              child: const Text('Add Donation'),
            ),
          ],
        );
      },
    );
  }

  void _addDonation() {
    String description = _descriptionController.text.trim();
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (description.isNotEmpty && amount > 0) {
      // Update the collected balance by adding donation
      updateCollectedBalance(amount);
      FirebaseFirestore.instance.collection('donations').add({
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
