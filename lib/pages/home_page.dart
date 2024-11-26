import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http; // For HTTP requests

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
  Map<String, dynamic> _firebaseData = {}; // Store data fetched from Firebase Realtime Database
  double _servoAngle = 0; // Store the current servo angle

  final String _sensorDataUrl = "https://agrishade-428de-default-rtdb.asia-southeast1.firebasedatabase.app/sensor_data.json";

  @override
  void initState() {
    super.initState();
    _loadGlobalUsername(); // Load username from global variable
    _updateGreeting();
    _updateDateTime();
    _fetchData(); // Fetch data initially
    _startPeriodicUpdates(); // Start periodic updates every 5 seconds
  }

  // Fetch data using HTTP from Firebase Realtime Database
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(_sensorDataUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response and update state
        Map<String, dynamic> dataMap = json.decode(response.body);
        setState(() {
          _firebaseData = dataMap; // Update the fetched data
          _servoAngle = _firebaseData['sudut']?.toDouble() ?? 0; // Update servo angle from Firebase
        });
      } else {
        setState(() {
          _firebaseData = {}; // Clear data if fetch fails
        });
      }
    } catch (e) {
      setState(() {
        _firebaseData = {}; // Clear data on error
      });
    }
  }

  // Start periodic data fetching every 5 seconds
  void _startPeriodicUpdates() {
    Future.delayed(const Duration(seconds: 5), () {
      _fetchData();
      _startPeriodicUpdates(); // Continue fetching periodically
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

  // Update the servo angle in Firebase
  Future<void> _updateServoAngle(double newAngle) async {
    try {
      final response = await http.patch(
        Uri.parse(_sensorDataUrl),
        body: json.encode({
          'sudut': newAngle, // Update the servo angle value
        }),
      );

      if (response.statusCode == 200) {
        print("Servo angle updated successfully!");
      } else {
        print("Failed to update servo angle.");
      }
    } catch (e) {
      print("Error updating servo angle: $e");
    }
  }

  // Function to build the stat cards for the values like suhu, intensitas, kelembapan
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
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'), // Replace with your asset
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
                      // Update text based on the switch state
                      Text(
                        _firebaseData['switch'] ?? false ? "Tertutup" : "Terbuka",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch(
                        value: _firebaseData['switch'] ?? false,
                        onChanged: (val) async {
                          // Update the local state
                          setState(() {
                            _firebaseData['switch'] = val;
                          });

                          // Send the updated value to Firebase
                          try {
                            final response = await http.patch(
                              Uri.parse(_sensorDataUrl),
                              body: json.encode({
                                'switch': val, // Update the switch value
                              }),
                            );

                            if (response.statusCode == 200) {
                              print("Switch value updated successfully!");
                            } else {
                              print("Failed to update switch value.");
                            }
                          } catch (e) {
                            print("Error updating switch value: $e");
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Grid View for displaying stats like suhu, intensitas, kelembapan
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sudut Servo: ${_servoAngle.toStringAsFixed(0)}°",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _servoAngle,
                    min: 0,
                    max: 180,
                    divisions: 180,
                    label: _servoAngle.toStringAsFixed(0),
                    onChanged: (double newValue) {
                      setState(() {
                        _servoAngle = newValue; // Update local state
                      });
                      // Update the servo angle in Firebase
                      _updateServoAngle(newValue);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildStatCard("${_firebaseData['intensitas'] ?? 0} W/m²", "Intensitas"),
                  buildStatCard("${_firebaseData['suhu'] ?? 0}°C", "Suhu"),
                  buildStatCard("${_firebaseData['kelembapan'] ?? 0}%Rh", "Kelembapan"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Slider for Servo Angle

          ],
        ),
      ),
    );
  }
}
