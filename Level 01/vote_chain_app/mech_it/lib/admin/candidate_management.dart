import 'package:flutter/material.dart';
import 'admin_service.dart';

class CandidateManagement extends StatefulWidget {
  final String electionId;

  const CandidateManagement({Key? key, required this.electionId}) : super(key: key);

  @override
  _CandidateManagementState createState() => _CandidateManagementState();
}

class _CandidateManagementState extends State<CandidateManagement> {
  final AdminService _adminService = AdminService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();

  void _addCandidate() async {
    if (_nameController.text.isNotEmpty && _partyController.text.isNotEmpty) {
      await _adminService.addCandidate(
        widget.electionId,
        _nameController.text,
        _partyController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Candidate added successfully!")));
      _nameController.clear();
      _partyController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Candidate Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Candidate Name"),
            ),
            TextField(
              controller: _partyController,
              decoration: InputDecoration(labelText: "Party Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCandidate,
              child: Text("Add Candidate"),
            ),
          ],
        ),
      ),
    );
  }
}
