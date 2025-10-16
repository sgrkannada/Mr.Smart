import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // For date formatting

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Data Model
class Certificate {
  final String id;
  String title;
  String issuer;
  DateTime issueDate;
  Color color; // Neon color for the card

  Certificate({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issueDate,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'issuer': issuer,
        'issueDate': issueDate.toIso8601String(),
        'color': color.value,
      };

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
        id: json['id'],
        title: json['title'],
        issuer: json['issuer'],
        issueDate: DateTime.parse(json['issueDate']),
        color: Color(json['color']),
      );
}

class MyCertificatesPage extends StatefulWidget {
  const MyCertificatesPage({super.key});

  @override
  State<MyCertificatesPage> createState() => _MyCertificatesPageState();
}

class _MyCertificatesPageState extends State<MyCertificatesPage> {
  List<Certificate> _certificates = [];
  final Uuid _uuid = const Uuid();
  final List<Color> _neonColors = [
    neonCyan,
    const Color(0xFF39FF14), // Neon Green
    const Color(0xFFFF073A), // Neon Red/Pink
    const Color(0xFFFEF44C), // Neon Yellow
    const Color(0xFF00FFFF), // Neon Aqua
    const Color(0xFFEE82EE), // Violet
    const Color(0xFF00FF00), // Lime
    const Color(0xFFFFD700), // Gold
  ];

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? certificatesString = prefs.getString('certificates');
    if (certificatesString != null) {
      final List<dynamic> jsonList = jsonDecode(certificatesString);
      setState(() {
        _certificates = jsonList.map((json) => Certificate.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final String certificatesString = jsonEncode(_certificates.map((cert) => cert.toJson()).toList());
    await prefs.setString('certificates', certificatesString);
  }

  Future<void> _addCertificate() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController issuerController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Certificate Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: issuerController,
              decoration: const InputDecoration(hintText: 'Issuing Organization'),
            ),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Select Issue Date'
                        : 'Issued: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    style: TextStyle(color: neonCyan),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && issuerController.text.isNotEmpty && selectedDate != null) {
                final newCertificate = Certificate(
                  id: _uuid.v4(),
                  title: titleController.text,
                  issuer: issuerController.text,
                  issueDate: selectedDate!,
                  color: _neonColors[_certificates.length % _neonColors.length],
                );
                setState(() {
                  _certificates.add(newCertificate);
                });
                _saveCertificates();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields and select a date.')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCertificate(String id) {
    setState(() {
      _certificates.removeWhere((cert) => cert.id == id);
    });
    _saveCertificates();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate deleted.')),
    );
  }

  Future<void> _editCertificate(Certificate certificate) async {
    final TextEditingController titleController = TextEditingController(text: certificate.title);
    final TextEditingController issuerController = TextEditingController(text: certificate.issuer);
    DateTime? selectedDate = certificate.issueDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Certificate Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: issuerController,
              decoration: const InputDecoration(hintText: 'Issuing Organization'),
            ),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Select Issue Date'
                        : 'Issued: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    style: TextStyle(color: neonCyan),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && issuerController.text.isNotEmpty && selectedDate != null) {
                setState(() {
                  certificate.title = titleController.text;
                  certificate.issuer = issuerController.text;
                  certificate.issueDate = selectedDate!;
                });
                _saveCertificates();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields and select a date.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: _certificates.isEmpty
          ? const Center(
              child: Text(
                'No certificates yet. Add one!',
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final certificate = _certificates[index];
                return _buildCertificateCard(certificate);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCertificate,
        label: const Text('Add Certificate'),
        icon: const Icon(Icons.add),
        backgroundColor: neonCyan,
        foregroundColor: darkBackground,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: certificate.color.withOpacity(0.6), width: 1.5),
      ),
      elevation: 5,
      shadowColor: certificate.color.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              certificate.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: certificate.color, blurRadius: 5)],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Issued by: ${certificate.issuer}',
              style: TextStyle(color: Colors.white70.withOpacity(0.8), fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(certificate.issueDate)}',
              style: TextStyle(color: Colors.white70.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: certificate.color),
                  onPressed: () => _editCertificate(certificate),
                  tooltip: 'Edit Certificate',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteCertificate(certificate.id),
                  tooltip: 'Delete Certificate',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}