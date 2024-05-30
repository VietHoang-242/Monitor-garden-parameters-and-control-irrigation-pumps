// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'caidat.dart';
import 'bieudo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Temperature & Humidity',
      home: TemperatureHumidityWidget(title: 'Temperature & Humidity'),
    );
  }
}

class TemperatureHumidityWidget extends StatefulWidget {
  const TemperatureHumidityWidget({super.key, required this.title});
  final String title;
  @override
// ignore: library_private_types_in_public_api
  _TemperatureHumidityWidgetState createState() =>
      _TemperatureHumidityWidgetState();
}

class _TemperatureHumidityWidgetState extends State<TemperatureHumidityWidget> {
  Color _appBarColor = const Color(0xFF4CAF50);
  final Color _textColor = const Color.fromARGB(255, 0, 0, 0);
  Widget _currentBody = const caidat();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Temperature & Humidity',
            style: TextStyle(color: _textColor),
          ),
        ),
        backgroundColor: _appBarColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              // ignore: sort_child_properties_last
              child: Text(
                'MENU',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 146, 177, 155),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.control_point), // Icon
              title: const Text(
                'Điều khiển và giám sát',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                setState(() {
                  _currentBody = const caidat();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes), // Icon
              title: const Text(
                'Biểu đồ',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                setState(() {
                  _currentBody = const BieuDo();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _currentBody,
    );
  }
}
