import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> members = snapshot.data!.docs;
            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return buildMemberTile(members[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditMemberDialog(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget buildMemberTile(DocumentSnapshot member) {
    Map<String, dynamic> subscriptionStatus = member['subscriptionStatus'];
    int unpaidMonths = countUnpaidMonths(subscriptionStatus);
    num totalAmount = unpaidMonths * member['subscriptionAmount'];

    Color memberColor =
        unpaidMonths > 0 ? const Color.fromARGB(255, 255, 187, 182) : const Color.fromARGB(255, 239, 252, 239);

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${member['name']}'),
          GestureDetector(
            onTap: () => _launchPhoneCall(member['phone']),
            child: Text('${member['phone']}', style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Balance : Rs. $totalAmount'),
          Text(' for $unpaidMonths months'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Align buttons horizontally
        children: [
          SizedBox(
            width: 40, // Set the width of the first button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
              ),
              onPressed: () => showPaymentDialog(member),
              child: const Icon(Icons.payment),
            ),
          ),
          const SizedBox(width: 8), // Add some space between the buttons
          SizedBox(
            width: 40, // Set the width of the second button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
              ),
              onPressed: () => showAddEditMemberDialog(member),
              child: const Icon(Icons.edit), // Replace 'second_icon' with the actual icon
            ),
          ),
        ],
      ),
      tileColor: memberColor,
    );
  }

  int countUnpaidMonths(Map<String, dynamic> subscriptionStatus) {
    int unpaidMonths = 0;
    String currentMonthKey = getCurrentMonthKey();

    for (String monthKey in subscriptionStatus.keys) {
      if (monthKey != currentMonthKey && subscriptionStatus[monthKey] == false) {
        unpaidMonths++;
      }
    }

    return unpaidMonths;
  }

  String getCurrentMonthKey() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> showPaymentDialog(DocumentSnapshot member) async {
    num totalAmount = countUnpaidMonths(member["subscriptionStatus"]) * member["subscriptionAmount"];

    TextEditingController amountController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Receive Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Amount: Rs. $totalAmount'),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Amount'),
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
                double paidAmount = double.tryParse(amountController.text) ?? 0.0;

                if (paidAmount > 0 && paidAmount <= totalAmount) {
                  processPayment(member, paidAmount);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid amount entered')),
                  );
                }
              },
              child: const Text('Receive'),
            ),
          ],
        );
      },
    );
  }

  void processPayment(DocumentSnapshot member, double paidAmount) {
    Map<String, dynamic> subscriptionStatus = member['subscriptionStatus'];

    updateCollectedBalance(paidAmount);

    for (String monthKey in subscriptionStatus.keys) {
      if (subscriptionStatus[monthKey] == false && paidAmount >= member["subscriptionAmount"]) {
        subscriptionStatus[monthKey] = true;
        paidAmount -= member["subscriptionAmount"];
      }
    }

    member.reference.update({'subscriptionStatus': subscriptionStatus});
  }

  void updateCollectedBalance(double amount) {
    FirebaseFirestore.instance.collection('balance').doc('collectedBalance').update({
      'balance': FieldValue.increment(amount),
    });
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> showAddEditMemberDialog(DocumentSnapshot? member) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController subscriptionAmountController = TextEditingController();

    if (member != null) {
      nameController.text = member['name'];
      phoneController.text = member['phone'];
      subscriptionAmountController.text = member['subscriptionAmount'].toString();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(member != null ? 'Edit Member' : 'Add Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: subscriptionAmountController,
                decoration: const InputDecoration(labelText: 'Subscription Amount'),
                keyboardType: TextInputType.number,
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
                if (member != null) {
                  updateMember(member, nameController.text, phoneController.text, subscriptionAmountController.text);
                } else {
                  addMember(nameController.text, phoneController.text, subscriptionAmountController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void addMember(String name, String phone, String subscriptionAmount) {
    double amount = double.tryParse(subscriptionAmount) ?? 0.0;

    if (name.isNotEmpty && phone.isNotEmpty && amount > 0) {
      String currentMonthKey = getCurrentMonthKey();
      Map<String, bool> initialSubscriptionStatus = {currentMonthKey: false};

      FirebaseFirestore.instance.collection('members').add({
        'name': name,
        'phone': phone,
        'subscriptionAmount': amount,
        'subscriptionStatus': initialSubscriptionStatus,
        'createdAt': DateTime.now(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name added successfully')));
      }).catchError((error) {
        // ignore: avoid_print
        print('Error adding member: $error');
      });
    } else {
      // ignore: avoid_print
      print('Please fill out all fields and provide a valid subscription amount');
    }
  }

  void updateMember(DocumentSnapshot member, String name, String phone, String subscriptionAmount) {
    if (name.isNotEmpty && phone.isNotEmpty) {
      double amount = double.tryParse(subscriptionAmount) ?? 0.0;
      member.reference.update({
        'name': name,
        'phone': phone,
        'subscriptionAmount': amount,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name updated successfully')));
      }).catchError((error) {
        // ignore: avoid_print
        print('Error updating member: $error');
      });
    } else {
      // ignore: avoid_print
      print('Please fill out all fields');
    }
  }
}
