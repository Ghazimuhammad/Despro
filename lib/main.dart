import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Replace with your actual Firebase configuration
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

// Model data untuk chart_data
class ChartData {
  final DateTime timestamp;
  final int peopleCount;

  ChartData({required this.timestamp, required this.peopleCount});

  factory ChartData.fromMap(Map<String, dynamic> map) {
    final timestampUnix = map['timestamp'] as int?;
    if (timestampUnix == null) {
      throw Exception("Field 'timestamp' is missing or null.");
    }

    final peopleCount = map['jumlah orang'] as int? ?? 0;

    return ChartData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampUnix * 1000, isUtc: true).toLocal(),
      peopleCount: peopleCount,
    );
  }
}

class LineChartScreen extends StatelessWidget {
  const LineChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reference to the specific document in 'data_dummy' collection
    final dataDocRef = FirebaseFirestore.instance.collection('data_dummy').doc('data'); // Replace 'data' with your actual document ID if different

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aktivitas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informational Section
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
                      // Jumlah Orang Saat Ini
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
                      // Jam Terakhir Bikun Terlihat
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
                              final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000, isUtc: true).toLocal();
                              jamTerakhirBikun = DateFormat('HH:mm:ss').format(dateTime);
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
              // Graph Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  // Listen to 'count_people' subcollection
                  stream: FirebaseFirestore.instance
                      .collection('data_dummy')
                      .doc('data') // Replace 'data' with your document ID
                      .collection('count_people')
                      .orderBy('timestamp')
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
                      final graphData = graphSnapshot.data!.docs.map((doc) {
                        final data = doc.data();
                        final unixTimestamp = data['timestamp'] as int?;
                        final peopleCount = data['jumlah orang'] as int? ?? 0;
                        if (unixTimestamp != null) {
                          final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000, isUtc: true).toLocal();
                          return ChartData(timestamp: dateTime, peopleCount: peopleCount);
                        } else {
                          return ChartData(timestamp: DateTime.now(), peopleCount: 0);
                        }
                      }).toList();

                      // Sort the data by timestamp
                      graphData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

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
                              'Grafik Hari Ini',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 298, // Adjust the height as needed
                              child: LineChartWidget(chartDataList: graphData),
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
      // Removed FloatingActionButton
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     addChartData(25); // Example to add 25 people
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

// Widget to draw the line chart
class LineChartWidget extends StatelessWidget {
  final List<ChartData> chartDataList;

  const LineChartWidget({super.key, required this.chartDataList});

  @override
  Widget build(BuildContext context) {
    // Create FlSpots based on time (hours)
    final spots = chartDataList.map((data) {
      final hours = data.timestamp.hour + data.timestamp.minute / 60.0 + data.timestamp.second / 3600.0;
      return FlSpot(hours.toDouble(), data.peopleCount.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 60, // Adjust as needed
        minX: 0, // 00:00
        maxX: 24, // 24:00
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0 && value >= 0 && value <= 24) {
                  final hour = value.toInt();
                  final amPm = hour >= 12 ? 'PM' : 'AM';
                  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
                  return Text(
                    '$displayHour $amPm',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
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
              color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
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
    );
  }
}
