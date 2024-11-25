import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
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

  @override
  void initState() {
    super.initState();
    _loadGlobalUsername(); // Load username from global variable
    _updateGreeting();
    _updateDateTime();
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
              backgroundColor: Colors.grey[300],
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
      body: Padding(
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
            // Toggle Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentDateTime, // Dynamic time string
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text("Tertutup"),
                    Switch(value: false, onChanged: (val) {}),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Grid View
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildStatCard(".. W/m²", "Intensitas"),
                  buildStatCard("45°", "Sudut Servo"),
                  buildStatCard("30°C", "Suhu"),
                  buildStatCard("70%Rh", "Kelembapan"),
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
        color: Colors.lightBlueAccent,
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
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
