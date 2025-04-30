// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'admin_service.dart';
//
// class ElectionManagementScreen extends StatefulWidget {
//   @override
//   _ElectionManagementScreenState createState() => _ElectionManagementScreenState();
// }
//
// class _ElectionManagementScreenState extends State<ElectionManagementScreen> {
//   final AdminService _adminService = AdminService();
//   final _electionFormKey = GlobalKey<FormState>();
//   final TextEditingController _electionNameController = TextEditingController();
//
//   Future<void> _createElection() async {
//     if (_electionFormKey.currentState!.validate()) {
//       Map<String, dynamic> electionData = {
//         'name': _electionNameController.text,
//         'createdAt': DateTime.now().toIso8601String(),
//         'status': 'Pending',
//       };
//
//       String result = await _adminService.createElection(electionData);
//       // Show result to the admin
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Election Creation'),
//           content: Text(result),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Election'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _electionFormKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _electionNameController,
//                 decoration: InputDecoration(labelText: 'Election Name', border: OutlineInputBorder(),),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an election name';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _createElection,
//                 child: Text('Create Election'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'admin_service.dart';

class ElectionManagement extends StatefulWidget {
  @override
  _ElectionManagementState createState() => _ElectionManagementState();
}

class _ElectionManagementState extends State<ElectionManagement> {
  final AdminService _adminService = AdminService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  void _createElection() async {
    if (_nameController.text.isNotEmpty &&
        _typeController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _startDate != null &&
        _endDate != null) {
      await _adminService.createElection(
        _nameController.text,
        _typeController.text,
        _stateController.text,
        _startDate!,
        _endDate!,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Election created successfully!")));
      _nameController.clear();
      _typeController.clear();
      _stateController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Election Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Election Name"),
            ),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: "Election Type"),
            ),
            TextField(
              controller: _stateController,
              decoration: InputDecoration(labelText: "State/Region"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    child: Text(_startDate == null ? "Pick Start Date" : _startDate!.toLocal().toString()),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                    child: Text(_endDate == null ? "Pick End Date" : _endDate!.toLocal().toString()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createElection,
              child: Text("Create Election"),
            ),
          ],
        ),
      ),
    );
  }
}
