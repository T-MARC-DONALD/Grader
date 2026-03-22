import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Grade Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class Student {
  final String name;
  final int? score;

  Student({required this.name, this.score});

  factory Student.fromList(List<dynamic> list) {
    return Student(
      name: list[0].toString(),
      score: list.length > 1 && list[1] != null && list[1] != ''
          ? int.tryParse(list[1].toString())
          : null,
    );
  }

  List<String> toCSV() {
    final score = this.score?.toString() ?? '';
    final grade = this.score != null ? getGrade(this.score!) : 'No Score';
    return [name, score, grade];
  }
}

String formatStudentInfo(Student student) {
  if (student.score != null) {
    return '${student.name} - ${student.score} : Grade ${getGrade(student.score!)}';
  }
  return '${student.name} - No Score';
}

bool isPassing(Student student) {
  final score = student.score;
  if (score == null) return false;
  return score >= 60;
}

char getGrade(int score) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

typedef char = String;

String getGradeAsString(int score) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

Color getGradeColor(String? grade) {
  switch (grade) {
    case 'A':
      return const Color(0xFF2E7D32);
    case 'B':
      return const Color(0xFF388E3C);
    case 'C':
      return const Color(0xFFF9A825);
    case 'D':
      return const Color(0xFFF57C00);
    case 'F':
      return const Color(0xFFD32F2F);
    default:
      return Colors.grey;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Student> students = [];

  Future<void> importCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final csv = await file.readAsString();
        final rows = const CsvToListConverter().convert(csv);

        List<Student> importedStudents = [];
        for (int i = 1; i < rows.length; i++) {
          if (rows[i].isNotEmpty) {
            importedStudents.add(Student.fromList(rows[i]));
          }
        }

        setState(() {
          students = importedStudents;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${students.length} students'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error importing CSV'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> exportCSV() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final List<List<dynamic>> rows = [
          ['Name', 'Score', 'Grade'],
          ...students.map((s) => s.toCSV()),
        ];

        final csv = const ListToCsvConverter().convert(rows);
        final file = File('$selectedDirectory/students.csv');
        await file.writeAsString(csv);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CSV exported successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error exporting CSV'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Manager'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Text(
              'Student Performance Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Import/Export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: importCSV,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import CSV'),
                ),
                ElevatedButton.icon(
                  onPressed: exportCSV,
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Average score section
            if (students.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Score: ${calculateAverage().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Student list
            if (students.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Students (${students.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final grade = student.score != null
                          ? getGradeAsString(student.score!)
                          : 'N/A';
                      final gradeColor = getGradeColor(grade);

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      student.score != null
                                          ? 'Score: ${student.score}'
                                          : 'No Score',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: gradeColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  grade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No students imported yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Import CSV" to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double calculateAverage() {
    if (students.isEmpty) return 0.0;
    final scores = students
        .where((s) => s.score != null)
        .map((s) => s.score!)
        .toList();
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}
