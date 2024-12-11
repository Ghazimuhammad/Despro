import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCl_iYijcOigoHG5syMOKQlLCgvZhwNli4',
    appId: '1:498616526713:web:3ab6a791e1fdd09e5e31a8',
    messagingSenderId: '498616526713',
    projectId: 'despro-8d0d4',
    authDomain: 'despro-8d0d4.firebaseapp.com',
    storageBucket: 'despro-8d0d4.firebasestorage.app',
    measurementId: 'G-CWFXQRCY49',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statistik Aktivitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      home: const LineChartScreen(),
    );
  }
}

class ChartData {
  final DateTime timestamp;
  final int peopleCount;

  ChartData({required this.timestamp, required this.peopleCount});
}

class LineChartScreen extends StatefulWidget {
  const LineChartScreen({super.key});

  @override
  State<LineChartScreen> createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  @override
  Widget build(BuildContext context) {
    final dataDocRef = FirebaseFirestore.instance.collection('data_dummy').doc('data');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aktivitas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Halte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grafik Keramaian Halte FT UI',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Jumlah Orang Saat Ini:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: dataDocRef.collection('count_people')
                                .orderBy('timestamp', descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, countSnapshot) {
                              if (countSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (countSnapshot.hasError) {
                                return Text("Error: ${countSnapshot.error}");
                              } else if (!countSnapshot.hasData || countSnapshot.data!.docs.isEmpty) {
                                return const Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                );
                              } else {
                                final countData = countSnapshot.data!.docs.first.data();
                                final jumlahOrang = countData['jumlah orang'] as int? ?? 0;
                                return Text(
                                  '$jumlahOrang',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Jam Terakhir Bikun Terlihat:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: dataDocRef.collection('last_detected_bikun')
                            .orderBy('jam bikun', descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, bikunSnapshot) {
                          if (bikunSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (bikunSnapshot.hasError) {
                            return Text("Error: ${bikunSnapshot.error}");
                          } else if (!bikunSnapshot.hasData || bikunSnapshot.data!.docs.isEmpty) {
                            return const Text(
                              'Tidak ada data',
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            );
                          } else {
                            final bikunData = bikunSnapshot.data!.docs.first.data();
                            final unixTimestamp = bikunData['jam bikun'] as int?;
                            String jamTerakhirBikun = 'Tidak ada data';
                            if (unixTimestamp != null) {
                              final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000, isUtc: true);
                              jamTerakhirBikun = DateFormat('HH:mm:ss').format(dateTime.toLocal());
                            }
                            return Text(
                              jamTerakhirBikun,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Grafik 24 jam terakhir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: dataDocRef.collection('count_people')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, graphSnapshot) {
                    if (graphSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (graphSnapshot.hasError) {
                      return Center(child: Text("Error: ${graphSnapshot.error}"));
                    } else if (!graphSnapshot.hasData || graphSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Data grafik tidak tersedia"));
                    } else {
                      final allData = graphSnapshot.data!.docs.map((doc) {
                        final data = doc.data();
                        final unixTimestamp = data['timestamp'] as int?;
                        int peopleCount = data['jumlah orang'] as int? ?? 0;
                        if (unixTimestamp != null) {
                          final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000, isUtc: true).toLocal();

                          // Jika jam antara 21:00 hingga 6:00, set peopleCount = 0
                          if (dateTime.hour >= 21 || dateTime.hour < 6) {
                            peopleCount = 0;
                          }
                          return ChartData(timestamp: dateTime, peopleCount: peopleCount);
                        } else {
                          return ChartData(timestamp: DateTime.now(), peopleCount: 0);
                        }
                      }).toList();

                      if (allData.isEmpty) {
                        return const Center(child: Text("Tidak ada data untuk grafik"));
                      }

                      allData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                      // Always show the last 24 hours from now
                      final now = DateTime.now();
                      final start = now.subtract(const Duration(hours: 24));
                      final end = now;

                      final graphData = allData.where((d) {
                        return d.timestamp.isAfter(start) && d.timestamp.isBefore(end);
                      }).toList();

                      if (graphData.isEmpty) {
                        return const Center(child: Text("Tidak ada data dalam 24 jam terakhir"));
                      }

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grafik 24 Jam Terakhir',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: LineChartWidget(
                                chartDataList: graphData,
                                startTime: start,
                                endTime: end,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<ChartData> chartDataList;
  final DateTime startTime;
  final DateTime endTime;

  const LineChartWidget({
    Key? key,
    required this.chartDataList,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chartDataList.isEmpty) {
      return const Center(child: Text("Tidak ada data untuk grafik"));
    }

    final spots = chartDataList.map((data) {
      final diff = data.timestamp.difference(startTime).inSeconds;
      final hoursFromStart = diff / 3600.0;
      return FlSpot(hoursFromStart, data.peopleCount.toDouble());
    }).toList();

    // Y-axis max selalu 30
    final maxY = 30.0;
    final minX = 0.0;
    final maxX = 24.0;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 30),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          minX: minX,
          maxX: maxX,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Jumlah Orang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              axisNameSize: 30,
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final time = startTime.add(Duration(hours: value.toInt()));
                  final displayHour = DateFormat('HH:mm').format(time);
                  return Text(
                    displayHour,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Waktu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              axisNameSize: 30,
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            verticalInterval: 2,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
