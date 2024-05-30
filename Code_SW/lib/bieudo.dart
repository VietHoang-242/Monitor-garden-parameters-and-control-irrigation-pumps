import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biểu đồ dữ liệu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BieuDo(),
    );
  }
}

class BieuDo extends StatefulWidget {
  const BieuDo({Key? key}) : super(key: key);

  @override
  _BieuDoState createState() => _BieuDoState();
}

class _BieuDoState extends State<BieuDo> {
  String _nhietdo = "";
  String _doamkk = "";
  String _doamdat = "";

  List<DataPoint> _nhietdoData = [];
  List<DataPoint> _doamkkData = [];
  List<DataPoint> _doamdatData = [];

  final ref = FirebaseDatabase.instance.reference();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const interval = Duration(seconds: 1);
    _timer = Timer.periodic(interval, (timer) {
      _updateData();
    });
  }

  void _updateData() {
    DatabaseReference nhietDo = ref.child('Nhietdo');
    nhietDo.onValue.listen((event) {
      setState(() {
        _nhietdo = event.snapshot.value.toString();
        _nhietdoData
            .add(DataPoint(_nhietdoData.length, double.parse(_nhietdo)));
      });
    });
    DatabaseReference doamKK = ref.child('DoamKK');
    doamKK.onValue.listen((event) {
      setState(() {
        _doamkk = event.snapshot.value.toString();
        _doamkkData.add(DataPoint(_doamkkData.length, double.parse(_doamkk)));
      });
    });

    DatabaseReference doamDat = ref.child('Doamdat');
    doamDat.onValue.listen((event) {
      setState(() {
        _doamdat = event.snapshot.value.toString();
        _doamdatData
            .add(DataPoint(_doamdatData.length, double.parse(_doamdat)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Biểu đồ nhiệt độ môi trường',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    LineSeries<DataPoint, int>(
                      dataSource: _nhietdoData,
                      xValueMapper: (DataPoint data, _) => data.index,
                      yValueMapper: (DataPoint data, _) => data.value,
                    ),
                  ],
                ),
              ),
              Text(
                'Biểu đồ độ ẩm môi trường',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    LineSeries<DataPoint, int>(
                      dataSource: _doamkkData,
                      xValueMapper: (DataPoint data, _) => data.index,
                      yValueMapper: (DataPoint data, _) => data.value,
                    ),
                  ],
                ),
              ),
              Text(
                'Biểu đồ độ ẩm đất',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    LineSeries<DataPoint, int>(
                      dataSource: _doamdatData,
                      xValueMapper: (DataPoint data, _) => data.index,
                      yValueMapper: (DataPoint data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataPoint {
  final int index;
  final double value;

  DataPoint(this.index, this.value);
}
