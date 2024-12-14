import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double temperatureLimit = 25.0;
  double lightIntensity = 50.0;
  TimeOfDay nightTime = TimeOfDay(hour: 20, minute: 0);
  TimeOfDay morningTime = TimeOfDay(hour: 6, minute: 0);
  String connectedWiFi = "Loading...";
  final String _sensorDataUrl = "https://agrishade-428de-default-rtdb.asia-southeast1.firebasedatabase.app/sensor_limit.json";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final response = await http.get(Uri.parse(_sensorDataUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperatureLimit = data['temperatureLimit']?.toDouble() ?? 25.0;
          lightIntensity = data['lightIntensity']?.toDouble() ?? 50.0;
          nightTime = TimeOfDay(
            hour: data['nightTime']?['hour'] ?? 20,
            minute: data['nightTime']?['minute'] ?? 0,
          );
          morningTime = TimeOfDay(
            hour: data['morningTime']?['hour'] ?? 6,
            minute: data['morningTime']?['minute'] ?? 0,
          );
          connectedWiFi = data['wifiName'] ?? "Unknown Wi-Fi";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch settings.')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching settings: $e')));
    }
  }

  Future<void> _saveSettings() async {
    try {
      final Map<String, dynamic> data = {
        'temperatureLimit': temperatureLimit,
        'lightIntensity': lightIntensity,
        'nightTime': {'hour': nightTime.hour, 'minute': nightTime.minute},
        'morningTime': {'hour': morningTime.hour, 'minute': morningTime.minute},
        'wifiName': connectedWiFi,
      };

      final response = await http.put(
        Uri.parse(_sensorDataUrl),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save settings.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
    }
  }

  Future<void> _selectTime(BuildContext context, bool isNightTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isNightTime ? nightTime : morningTime,
    );
    if (picked != null) {
      setState(() {
        if (isNightTime) {
          nightTime = picked;
        } else {
          morningTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Temperature Limit
            Card(
              child: ListTile(
                title: Text(
                  "Temperature Limit: ${temperatureLimit.toStringAsFixed(1)}°C",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                subtitle: Slider(
                  value: temperatureLimit,
                  min: 0,
                  max: 50,
                  divisions: 50,
                  label: temperatureLimit.toStringAsFixed(1),
                  activeColor: Color(0xFF4CAF50),
                  onChanged: (value) {
                    setState(() {
                      temperatureLimit = value;
                    });
                  },
                ),
              ),
            ),

            // Light Intensity
            Card(
              child: ListTile(
                title: Text(
                  "Light Intensity: ${lightIntensity.toStringAsFixed(0)}%",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                subtitle: Slider(
                  value: lightIntensity,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: lightIntensity.toStringAsFixed(0),
                  activeColor: Color(0xFF4CAF50),
                  onChanged: (value) {
                    setState(() {
                      lightIntensity = value;
                    });
                  },
                ),
              ),
            ),

            // Night and Morning Time
            Card(
              child: ListTile(
                title: Text(
                  "Night Time: ${nightTime.format(context)}",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                trailing: Icon(Icons.access_time, color: Color(0xFF4CAF50)),
                onTap: () => _selectTime(context, true),
              ),
            ),

            Card(
              child: ListTile(
                title: Text(
                  "Morning Time: ${morningTime.format(context)}",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                trailing: Icon(Icons.access_time, color: Color(0xFF4CAF50)),
                onTap: () => _selectTime(context, false),
              ),
            ),

            // Connected Wi-Fi
            Card(
              child: ListTile(
                title: Text(
                  "Connected Wi-Fi",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                subtitle: Text(connectedWiFi, style: TextStyle(color: Colors.black)),
                leading: Icon(Icons.wifi, color: Color(0xFF4CAF50)),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50), // Button color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: _saveSettings,
                child: Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  theme: ThemeData(primarySwatch: Colors.green),
  home: SettingsPage(),
));
