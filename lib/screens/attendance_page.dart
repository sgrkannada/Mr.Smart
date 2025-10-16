import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart'; // For calendar view

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Data Model for Attendance Record
class AttendanceRecord {
  final DateTime date;
  bool isPresent;

  AttendanceRecord({required this.date, this.isPresent = true});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'isPresent': isPresent,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        date: DateTime.parse(json['date']),
        isPresent: json['isPresent'],
      );
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, AttendanceRecord> _attendanceRecords = {};
  List<DateTime> _plannedHolidays = [];
  final TextEditingController _targetAttendanceController = TextEditingController(text: '75');

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _targetAttendanceController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? attendanceString = prefs.getString('attendance_records');
    if (attendanceString != null) {
      final List<dynamic> jsonList = json.decode(attendanceString);
      setState(() {
        _attendanceRecords = { for (var record in jsonList.map((json) => AttendanceRecord.fromJson(json))) DateTime(record.date.year, record.date.month, record.date.day) : record };
      });
    }
    final String? holidaysString = prefs.getString('planned_holidays');
    if (holidaysString != null) {
      final List<dynamic> jsonList = json.decode(holidaysString);
      setState(() {
        _plannedHolidays = jsonList.map((dateString) => DateTime.parse(dateString)).toList();
      });
    }
  }

  Future<void> _saveAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final String attendanceString = json.encode(_attendanceRecords.values.map((record) => record.toJson()).toList());
    await prefs.setString('attendance_records', attendanceString);
    final String holidaysString = json.encode(_plannedHolidays.map((date) => date.toIso8601String()).toList());
    await prefs.setString('planned_holidays', holidaysString);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showAttendanceDialog(selectedDay);
  }

  void _showAttendanceDialog(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    bool? currentIsPresent = _attendanceRecords[normalizedDate]?.isPresent;
    bool? selectedOption = currentIsPresent; // Use a local variable for dialog state

    showDialog<bool?>( // Specify return type of showDialog
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Mark Attendance for ${date.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder( // Use StatefulBuilder to manage dialog's internal state
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: const Text('Present', style: TextStyle(color: Colors.white)),
                    value: true,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                    activeColor: neonCyan,
                  ),
                  RadioListTile<bool>(
                    title: const Text('Absent', style: TextStyle(color: Colors.white)),
                    value: false,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                    activeColor: neonCyan,
                  ),
                 RadioListTile<bool>(
                    title: const Text('Present', style: TextStyle(color: Colors.white)),
                    value: true,
                    groupValue: selectedOption ?? false, // Use the null-aware operator to provide a default value
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                    activeColor: neonCyan,
                  ),
                  const Divider(color: Colors.white10),
                  CheckboxListTile(
                    title: const Text('Mark as Holiday', style: TextStyle(color: Colors.white)),
                    value: _plannedHolidays.contains(normalizedDate) == true,
                    onChanged: (bool? value) {
                      // Directly call the stateful widget's method to update main state
                      _togglePlannedHoliday(normalizedDate);
                      // Update dialog's internal state for checkbox visual
                      setState(() {});
                    },
                    activeColor: neonCyan,
                    checkColor: darkBackground,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedOption), // Pass selected option back
              child: const Text('Save', style: TextStyle(color: neonCyan)),
            ),
          ],
        );
      },
    ).then((result) {
      if (!mounted) return; // Add mounted check here
      setState(() {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        if (result != null) {
          if (result == true || result == false) {
            _attendanceRecords[normalizedDate] = AttendanceRecord(date: normalizedDate, isPresent: result);
          } else {
            // Handle the case when result is not true or false
            // For example, you can remove the entry from _attendanceRecords
            _attendanceRecords.remove(normalizedDate);
          }
        }
      });
      _saveAttendanceData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance updated for ${date.toLocal().toString().split(' ')[0]}')),
      );
    });
  }

  void _togglePlannedHoliday(DateTime date) {
    setState(() {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (_plannedHolidays.contains(normalizedDate)) {
        _plannedHolidays.remove(normalizedDate);
      } else {
        _plannedHolidays.add(normalizedDate);
      }
    });
    _saveAttendanceData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Holiday status updated for ${date.toLocal().toString().split(' ')[0]}')),
    );
  }

  int get _totalClasses {
    // Count all days from the first recorded attendance to today, excluding weekends
    if (_attendanceRecords.isEmpty) return 0;
    DateTime firstDay = _attendanceRecords.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    int count = 0;
    for (DateTime d = firstDay; d.isBefore(DateTime.now().add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  int get _attendedClasses {
    return _attendanceRecords.values.where((record) => record.isPresent).length;
  }

  double get _attendancePercentage {
    if (_totalClasses == 0) return 100.0;
    return (_attendedClasses / _totalClasses) * 100;
  }

  int _calculateDaysOffRemaining(double targetPercentage) {
    if (targetPercentage > 100 || targetPercentage < 0) return 0;
    if (_totalClasses == 0) return 999; // Effectively unlimited if no classes yet

    int currentAttended = _attendedClasses;
    int currentTotal = _totalClasses;

    // Consider future planned holidays as absent days for calculation
    int futureHolidays = _plannedHolidays.where((date) => date.isAfter(DateTime.now()) && date.weekday != DateTime.saturday && date.weekday != DateTime.sunday).length;
    currentTotal += futureHolidays;

    // Calculate how many more days can be absent
    // (currentAttended - x) / currentTotal >= targetPercentage / 100
    // currentAttended - x >= (targetPercentage / 100) * currentTotal
    // x <= currentAttended - (targetPercentage / 100) * currentTotal
    double maxAbsentDays = currentAttended - (targetPercentage / 100) * currentTotal;

    return maxAbsentDays.floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Manager'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance Summary
            Text(
              'Your Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: neonCyan.withAlpha((255 * 0.3).round()),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow('Total Classes:', _totalClasses.toString()),
                  _buildSummaryRow('Classes Attended:', _attendedClasses.toString()),
                  _buildSummaryRow('Attendance Percentage:', '${_attendancePercentage.toStringAsFixed(2)}%'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Holiday Planning
            Text(
              'Holiday Planning',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: neonCyan.withAlpha((255 * 0.3).round()),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow('Planned Holidays:', _plannedHolidays.length.toString()),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _targetAttendanceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Target % (e.g., 75)',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final double? target = double.tryParse(_targetAttendanceController.text);
                          if (target != null) {
                            final int daysOff = _calculateDaysOffRemaining(target);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('You can take $daysOff more days off to maintain ${target.toStringAsFixed(0)}% attendance.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid target percentage.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonCyan,
                          foregroundColor: darkBackground,
                        ),
                        child: const Text('Calculate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Calendar View
            Text(
              'Mark Attendance & Plan Holidays',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: Colors.grey),
                defaultTextStyle: const TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: neonCyan.withAlpha((255 * 0.3).round()),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: neonCyan,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: neonCyan),
                rightChevronIcon: const Icon(Icons.chevron_right, color: neonCyan),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white.withAlpha((255 * 0.8).round())),
                weekendStyle: const TextStyle(color: Colors.grey),
              ),
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                List<String> events = [];
                if (_attendanceRecords.containsKey(normalizedDay)) {
                  events.add(_attendanceRecords[normalizedDay]!.isPresent ? 'P' : 'A');
                }
                if (_plannedHolidays.contains(normalizedDay)) {
                  events.add('H');
                }
                return events;
              },
              // Custom builder for day cells to show attendance/holiday markers
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Row(
                        children: events.map((event) {
                          Color markerColor = Colors.transparent;
                          if (event == 'P') markerColor = Colors.greenAccent;
                          if (event == 'A') markerColor = Colors.redAccent;
                          if (event == 'H') markerColor = Colors.orangeAccent;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            width: 7.0,
                            height: 7.0,
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}