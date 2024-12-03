import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kelas untuk menyimpan konfigurasi Firebase
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
  final DateTime timestamp; // Menggunakan DateTime untuk timestamp
  final int peopleCount;

  ChartData({required this.timestamp, required this.peopleCount});

  factory ChartData.fromMap(Map<String, dynamic> map) {
    final timestampStr = map['timestamp'] as String?;
    if (timestampStr == null) {
      throw Exception("Field 'timestamp' is missing or null.");
    }

    final peopleCount = map['people_count'] as int? ?? 0; // Menggunakan default value 0 jika null

    return ChartData(
      timestamp: DateTime.parse(timestampStr),
      peopleCount: peopleCount,
    );
  }
}

class LineChartScreen extends StatelessWidget {
  const LineChartScreen({super.key});

  // Fungsi untuk menambahkan data baru ke Firestore dengan interval 10 menit
  Future<void> addChartData(int newPeopleCount) async {
    try {
      // Membuat dokumen baru dengan ID unik
      DocumentReference<Map<String, dynamic>> docRef =
          FirebaseFirestore.instance.collection('data_dummy').doc();

      DateTime now = DateTime.now().toUtc();
      String newTimeStr = now.toIso8601String();

      // Menambahkan data ke Firestore
      await docRef.set({
        'jumlah_orang': newPeopleCount * 2, // Contoh logika untuk 'jumlah_orang'
        'jam_rame': ['12:57', '17:28', '15:35'], // Contoh data jam_rame
        'chart_data': [
          {
            'time': '06:00',
            'people_count': newPeopleCount,
            'timestamp': '2024-12-03T06:00:00Z'
          },
          {
            'time': '07:00',
            'people_count': newPeopleCount - 5,
            'timestamp': '2024-12-03T07:00:00Z'
          },
          // Tambahkan lebih banyak data sesuai kebutuhan
        ],
        'timestamp': newTimeStr,
      });

      print("Data baru berhasil ditambahkan!");
    } catch (e) {
      print("Error menambahkan data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aktivitas'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('data_dummy')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200, // Memberikan ruang untuk loading indicator
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Data tidak tersedia"));
            } else {
              final data = snapshot.data!.docs.map((doc) => doc.data()).toList();

              List<ChartData> chartDataList = [];
              try {
                // Mengumpulkan semua entri chart_data dari semua dokumen
                for (var docData in data) {
                  final chartDataEntries = List<Map<String, dynamic>>.from(
                      docData['chart_data'] ?? []);
                  for (var entry in chartDataEntries) {
                    try {
                      final chartData = ChartData.fromMap(entry);
                      // Memfilter data untuk hari yang sama
                      final now = DateTime.now().toUtc();
                      if (chartData.timestamp.year == now.year &&
                          chartData.timestamp.month == now.month &&
                          chartData.timestamp.day == now.day) {
                        chartDataList.add(chartData);
                      }
                    } catch (e) {
                      print("Error parsing chart_data entry: $e");
                    }
                  }
                }

                // Sortir data berdasarkan timestamp
                chartDataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              } catch (e) {
                print("Error processing data: $e");
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Informasi
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              Text(
                                '${chartDataList.isNotEmpty ? chartDataList.last.peopleCount : 0}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Jam Paling Rame Minggu Sebelumnya:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Anda dapat menyesuaikan 'jam_rame' sesuai kebutuhan
                          const Text(
                            '08:00 AM, 12:00 PM, 05:00 PM',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bagian Grafik
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
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
                            height: 298, // Menyesuaikan tinggi grafik untuk menghindari overflow
                            child: LineChartWidget(chartDataList: chartDataList),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addChartData(25); // Contoh menambahkan 25 orang
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget untuk menggambar grafik garis
class LineChartWidget extends StatelessWidget {
  final List<ChartData> chartDataList;

  const LineChartWidget({super.key, required this.chartDataList});

  @override
  Widget build(BuildContext context) {
    // Membuat FlSpots berdasarkan waktu (jam) relatif terhadap 6 AM
    final spots = chartDataList.map((data) {
      final hoursSinceSix =
          data.timestamp.hour + data.timestamp.minute / 60.0 - 6.0;
      // Clamp the value between 0 and 12 to fit the X-axis range
      final clampedX = hoursSinceSix.clamp(0.0, 12.0);
      return FlSpot(clampedX, data.peopleCount.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 60,
        minX: 0, // 6 AM
        maxX: 12, // 6 PM
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
                if (value % 1 == 0 && value >= 0 && value <= 12) {
                  final hour = value.toInt() + 6; // Mengembalikan ke jam asli
                  final amPm = hour >= 12 ? 'PM' : 'AM';
                  final displayHour = hour > 12 ? hour - 12 : hour;
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
