import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Grader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';

  Future<void> _pickAndGradeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String? path = file.path;
      if (path != null) {
        List<double> scores = await _processFile(path);
        if (scores.isEmpty) {
          setState(() {
            _result = 'No scores available to grade.';
          });
        } else {
          String grades = scores.map((score) => '$score -> ${_grade(score)}').join('\n');
          setState(() {
            _result = grades;
          });
        }
      }
    }
  }

  Future<List<double>> _processFile(String path) async {
    final file = File(path);
    final extension = path.split('.').last.toLowerCase();
    List<List<dynamic>> rows = [];

    if (extension == 'csv') {
      final content = await file.readAsString();
      rows = const CsvToListConverter().convert(content);
    } else if (extension == 'xls' || extension == 'xlsx') {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.values) {
        for (var row in table.rows) {
          rows.add(row.map((cell) => cell?.value).toList());
        }
      }
    }

    return _extractScores(rows);
  }

  List<double> _extractScores(List<List<dynamic>> rows) {
    final scores = <double>[];
    for (var row in rows) {
      for (var cell in row) {
        final numVal = _parseNumber(cell);
        if (numVal != null) {
          scores.add(numVal);
        }
      }
    }
    return scores;
  }

  double? _parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final str = value.toString().trim();
    return double.tryParse(str);
  }

  String _grade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Grader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickAndGradeFile,
              child: const Text('Upload File'),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
