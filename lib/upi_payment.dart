import 'package:fixflow/card_payment.dart';
import 'package:fixflow/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: UpiPaymentPage(),
  ));
}

class UpiPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UPI Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Make UPI Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter UPI ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 14.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 1.2, horizontal: 15.0),
                        backgroundColor: Colors.purple, // Violet color
                        foregroundColor: Colors.white, // White text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded edges
                        ),
                      ),
              onPressed: () {
                       
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ordered successfully')),
        );
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CarServiceHomePage()),
        );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CardPaymentPage()),
                );
              },
              child: Text(
                'Pay with Card',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}