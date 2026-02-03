import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixflow/Orders/my_orders_page2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPendingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Orders'),
        backgroundColor: Color.fromARGB(255, 207, 173, 210),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders_placed2')
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
                'You have no orders',
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
                    // If still waiting for data, display a loading indicator or placeholder
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    // If an error occurs while fetching data, handle it here
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    // If document doesn't exist or no data found, display appropriate message
                    return Text('Service Center not found');
                  }

                  // Extract the service center name from the snapshot data
                  String serviceCenterName = snapshot.data!.get('Service Center Name');

                  // Now you can return the ListTile with the correct service center name
                  return ListTile(
                    title: Text(
                      'Order ${index + 1}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Center Name: $serviceCenterName', // Display service center name
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyOrdersPage1(userEmail: userEmail)),
                      );
                    },
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
