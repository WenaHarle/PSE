import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import '../globals.dart'; // Import the global variable

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _accountName = 'Anonymous User'; // Default username
  String _greeting = '';
  String _currentDateTime = ''; // Holds dynamic time string
  late FirebaseFirestore _firestore;
  Map<String, dynamic> _firebaseData = {}; // Store data fetched from Firestore

  @override
  void initState() {
    super.initState();
    _initializeFirebase(); // Initialize Firebase
    _loadGlobalUsername(); // Load username from global variable
    _updateGreeting();
    _updateDateTime();
  }

  // Initialize Firebase
  void _initializeFirebase() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance; // Initialize Firestore

    // Listen to the Firestore document for changes
    _firestore.collection('data').doc('bJExEVntCHi9awEXmakn').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _firebaseData = snapshot.data()!; // Update the Firestore data
        });
      }
    });
  }

  // Load the username from the global variable
  void _loadGlobalUsername() {
    setState(() {
      _accountName = globalUsername ?? 'Anonymous User'; // Use global variable
    });
  }

  // Update greeting based on the current time
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = "Good Morning";
    } else if (hour < 18) {
      _greeting = "Good Afternoon";
    } else {
      _greeting = "Good Evening";
    }
  }

  // Update current date and time dynamically
  void _updateDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE HH:mm'); // Format: "Day Hour:Minute"
    setState(() {
      _currentDateTime = formatter.format(now); // Example: "Sunday 19:20"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[300], // Green accent for avatar
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  _accountName, // Display the fetched username
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // White background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tree Image
            Container(
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/starbucks.png'), // Replace with your asset
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Full Width Card with Date and Switch
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50), // Green color for the card
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentDateTime, // Dynamic time string
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Tertutup",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch(
                        value: _firebaseData['switch'] ?? false,
                        onChanged: (val) async {
                          await _firestore.collection('data').doc('bJExEVntCHi9awEXmakn').update({
                            'switch': val,
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Grid View
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildStatCard("${_firebaseData['intensitas'] ?? 0} W/m²", "Intensitas"),
                  buildStatCard("${_firebaseData['sudut'] ?? 0}°", "Sudut Servo"),
                  buildStatCard("${_firebaseData['suhu'] ?? 0}°C", "Suhu"),
                  buildStatCard("${_firebaseData['kelembapan'] ?? 0}%Rh", "Kelembapan"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF81C784), // Light green color for the card
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
