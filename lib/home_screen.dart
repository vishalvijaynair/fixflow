import 'package:fixflow/loc_calc.dart';
import 'package:fixflow/order_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import other necessary files
import 'service_center_card.dart';
import 'search_page.dart';
import 'carousel.dart';
import 'user_details.dart';

class CarServiceHomePage extends StatefulWidget {
  @override
  State<CarServiceHomePage> createState() => _CarServiceHomePageState();
}

class _CarServiceHomePageState extends State<CarServiceHomePage> {
  late Future<List<DocumentSnapshot>> _serviceCentres;
  List<Map<String, dynamic>>? _weightedScores;

  List<String> imagePaths = [
    'assets/img1.png',
    'assets/img2.png',
    'assets/img3.png',
    'assets/img4.png',
    'assets/img5.png',
    'assets/img6.png',
    'assets/img7.png',
  ];
  int imageIndex = 0;

  double? userLat;
  double? userLong;

  @override
  void initState() {
    super.initState();
    _serviceCentres = _fetchServiceCentres();
    _getLocationAndStore();
  }

  Future<List<DocumentSnapshot>> _fetchServiceCentres() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Service_Centres')
          .orderBy('score', descending: true) // Sort by score in descending order
          .get();
      List<DocumentSnapshot> serviceCentres = querySnapshot.docs;
      return serviceCentres;
    } catch (e) {
      print('Error fetching service centers: $e');
      return [];
    }
  }

  _getLocationAndStore() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          userLat = position.latitude;
          userLong = position.longitude;
        });

        String? email = FirebaseAuth.instance.currentUser?.email;
        if (email != null) {
          await FirebaseFirestore.instance.collection('Users').doc(email).update({
            'latitude': userLat,
            'longitude': userLong,
          });
        } else {
          print('Error getting user email: User is not logged in');
        }

        await LocationCalculation().calculateAndStoreDistance();
        
        // Calculate and store scores after distances are calculated
        await LocationCalculation().calculateAndStoreScores();
      } else {
        print('Location permission denied.');
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fix Flow',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 207, 173, 210),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 80,
              child: DrawerHeader(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 116, 47, 129),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'FixFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('My Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
            
            
          ],
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 250, 223, 255),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _serviceCentres,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<DocumentSnapshot> serviceCentres = snapshot.data!;

            return ListView(
              children: <Widget>[
                CustomCarousel(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Service Centers Recommended For You',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                for (var serviceCenter in serviceCentres)
                  ServiceCenterCard(
                    name: serviceCenter['Service Center Name'],
                    location: serviceCenter['Location'],
                    phoneNumber: serviceCenter['Phone Number'],
                    imagePath: imagePaths[imageIndex++ % imagePaths.length],
                    services: List<String>.from(serviceCenter['Services_offered']),
                    distance: (serviceCenter['distance'] ?? 0.0).toDouble(),
                    email: serviceCenter['Email'],
                    serviceAmounts: Map<String, int>.from(serviceCenter['Service_Amounts']),
                    rating: double.parse(((serviceCenter['rate'] ?? 0.0).toDouble()).toStringAsFixed(1)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
