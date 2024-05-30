import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

// ignore: camel_case_types
class caidat extends StatefulWidget {
  const caidat({super.key});

  @override
  State<caidat> createState() => _MainUIState();
}

class _MainUIState extends State<caidat> {
  bool _isDeviceOn = false;
  bool _buttonOn = false;
  String _nhietdo = "";
  String _doamkk = "";
  String _doamdat = "";
  int _humidityThresholdOn = 50;
  int _humidityThresholdOff = 80;
  // ignore: unused_field
  final Color _backgroundColor = const Color.fromARGB(255, 250, 250, 250);
  // ignore: unused_field
  final Color _appBarColor = const Color(0xFF4CAF50);
  final Color _textColor = const Color.fromARGB(255, 0, 0, 0);

  final ref = FirebaseDatabase.instance.ref();

  void _updateHumidityThresholdOn(double value) {
    setState(() {
      _humidityThresholdOn = value.round();
      ref.child('Doam_bat_bom').set(_humidityThresholdOn);
    });
  }

  void _updateHumidityThresholdOff(double value) {
    setState(() {
      _humidityThresholdOff = value.round();
      ref.child('Doam_tat_bom').set(_humidityThresholdOff);
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference nhietDo =
        FirebaseDatabase.instance.ref().child('Nhietdo');
    nhietDo.onValue.listen((event) {
      setState(() {
        _nhietdo = event.snapshot.value.toString();
      });
    });
    DatabaseReference doamKK = FirebaseDatabase.instance.ref().child('DoamKK');
    doamKK.onValue.listen((event) {
      setState(() {
        _doamkk = event.snapshot.value.toString();
      });
    });
    DatabaseReference doamDat =
        FirebaseDatabase.instance.ref().child('Doamdat');
    doamDat.onValue.listen((event) {
      setState(() {
        _doamdat = event.snapshot.value.toString();
      });
    });

    DatabaseReference doambatbom =
        FirebaseDatabase.instance.ref().child('Doam_bat_bom');
    doambatbom.onValue.listen((event) {
      setState(() {
        _humidityThresholdOn = int.parse(event.snapshot.value.toString());
      });
    });
    DatabaseReference doamtatbom =
        FirebaseDatabase.instance.ref().child('Doam_tat_bom');
    doamtatbom.onValue.listen((event) {
      setState(() {
        _humidityThresholdOff = int.parse(event.snapshot.value.toString());
      });
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/hot.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 15),
              Text(
                'Nhiệt độ: $_nhietdo °C',
                style: TextStyle(fontSize: 18, color: _textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/humidity.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 15),
              Text(
                'Độ ẩm môi trường: $_doamkk %',
                style: TextStyle(fontSize: 18, color: _textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/humidity.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 15),
              Text(
                'Độ ẩm đất: $_doamdat %',
                style: TextStyle(fontSize: 18, color: _textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                _isDeviceOn ? 'assets/bom.png' : 'assets/bom1.png',
                width: 91,
                height: 91,
              ),
              const SizedBox(width: 16),
              Text(_isDeviceOn ? 'Bật máy bơm' : 'Tắt máy bơm',
                  style: TextStyle(fontSize: 18, color: _textColor)),
              const Spacer(),
              Switch(
                value: _isDeviceOn,
                onChanged: (bool value) {
                  setState(() {
                    _isDeviceOn = !_isDeviceOn;
                    ref.child('bom').set(_isDeviceOn ? 1 : 0);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                _buttonOn ? 'assets/button1.png' : 'assets/button.png',
                width: 91,
                height: 91,
              ),
              const SizedBox(width: 16),
              Text(_buttonOn ? 'Tự động bật' : 'Tự động tắt',
                  style: TextStyle(fontSize: 18, color: _textColor)),
              const Spacer(),
              Switch(
                value: _buttonOn,
                onChanged: (bool value) {
                  setState(() {
                    _buttonOn = !_buttonOn;
                    ref.child('chedo').set(_buttonOn ? 1 : 0);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Độ ẩm bật bơm: $_humidityThresholdOn',
              style: TextStyle(fontSize: 18, color: _textColor)),
          Slider(
            value: _humidityThresholdOn.toDouble(),
            min: 0,
            max: 100,
            onChanged: _updateHumidityThresholdOn,
            activeColor: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          Text('Độ ẩm tắt bơm: $_humidityThresholdOff',
              style: TextStyle(fontSize: 18, color: _textColor)),
          Slider(
            value: _humidityThresholdOff.toDouble(),
            min: 0,
            max: 100,
            onChanged: _updateHumidityThresholdOff,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}
