import 'package:fixflow/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RatingSubmissionPage extends StatefulWidget {
  final String userEmail;

  const RatingSubmissionPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _RatingSubmissionPageState createState() => _RatingSubmissionPageState();
}

class _RatingSubmissionPageState extends State<RatingSubmissionPage> {
  double rating = 0;
  bool hasExistingRating = false;
  double existingRating = 0.0;

  @override
  void initState() {
    super.initState();
    // Check if the service center already has a rating
  FirebaseFirestore.instance
    .collection('Service_Centres')
    .doc(widget.userEmail)
    .get()
    .then((doc) {
  if (doc.exists && doc.data()!['rate'] != null) {
    setState(() {
      hasExistingRating = true;
      existingRating = (doc.data()!['rate'] as num).toDouble(); 
    });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Rating'),
        backgroundColor: Color.fromARGB(255, 207, 173, 210),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rate your experience:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 45.0,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                setState(() {
                  rating = newRating;
                });
              },
            ),
            SizedBox(height: 20), // Add space between rating bar and button
          ElevatedButton(
  onPressed: () {
    double newRatingValue = hasExistingRating
        ? (existingRating + rating) / 2
        : rating;
    
    FirebaseFirestore.instance
        .collection('Service_Centres')
        .doc(widget.userEmail)
        .update({'rate': newRatingValue})
        .then((value) {
          print('Rating updated successfully');
          // Navigate to OrdersCompleted page and show snackbar
          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarServiceHomePage()),
              );;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rated Successfully'),
            ),
          );
        })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => print('Failed to update rating: $error'));
  },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                backgroundColor: Colors.purple.withOpacity(0.9),
              ),
              child: Text(
                "Submit Rating",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
