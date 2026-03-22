# Grader

A Flutter mobile app that automatically detects and grades uploaded files in CSV or Excel (XLS/XLSX) format.

## Features

- Validates file type (CSV or Excel)
- Scans content for numeric scores
- Assigns letter grades based on score ranges:
  - A: 90-100 (excellent)
  - B: 80-89 (good)
  - C: 70-79 (average)
  - D: 60-69 (below average)
  - F: 0-59 (failing)
- Displays "No scores available to grade" if no numeric scores found

## Getting Started

1. Ensure Flutter is installed.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to start the app on a connected device or emulator.

## Usage

Tap "Upload File" to select a CSV or Excel file. The app will process it and display the grades.
