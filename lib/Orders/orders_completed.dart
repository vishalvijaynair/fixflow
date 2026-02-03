import 'package:fixflow/Orders/RatingSubmissionPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersCompleted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('Completed Orders'),
    backgroundColor: Color.fromARGB(255, 207, 173, 210),
  ),
  body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('orders_completed')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('orders')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        print('Error retrieving orders: ${snapshot.error}');
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      final orders = snapshot.data!.docs;

      if (orders.isEmpty) {
        return Center(
          child: Text(
            'You have no Completed Orders',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      }

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final orderData = orders[index].data() as Map<String, dynamic>;

          String orderedDate = orderData['orderedDate'] ?? 'N/A';
          String orderedTime = orderData['orderedTime'] ?? 'N/A';
          String totalAmount = orderData['totalAmount']?.toString() ?? 'N/A';
          List<dynamic>? selectedServicesList = orderData['selectedServices'];
          String selectedServices = selectedServicesList?.join(', ') ?? 'N/A';
          String userEmail = orders[index].id;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Service_Centres')
                .doc(orders[index].id)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text('Service Center not found');
              }

              String serviceCenterName = snapshot.data!.get('Service Center Name');

              return Column(
  children: [
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListTile(
            title: Text(
              'Order ${index + 1}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Center Name: $serviceCenterName',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Service Centre Email: $userEmail',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Selected Services: $selectedServices',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Total Amount: $totalAmount',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Ordered Date: $orderedDate',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Ordered Time: $orderedTime',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    SizedBox(height: 10), // Adding some space between the texts and the button
    ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingSubmissionPage(userEmail: userEmail),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        backgroundColor: Color.fromARGB(255, 16, 91, 42),
      ),
      child: Text(
        'Rate Us',
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    ),
    Divider(),
  ],
);

            },
          );
        },
      );
    },
  ),
);
  }
}
