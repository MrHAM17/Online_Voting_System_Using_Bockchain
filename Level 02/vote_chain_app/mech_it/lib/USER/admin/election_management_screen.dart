// import 'package:flutter/material.dart';
//
// class ManageElections extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Elections'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Navigate to add election screen
//                 Navigator.pushNamed(context, '/addElection');
//               },
//               icon: Icon(Icons.add),
//               label: Text('Add Election'),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 10, // Replace with actual election data count
//                 itemBuilder: (context, index) {
//                   return Card(
//                     child: ListTile(
//                       title: Text('Election $index'),
//                       subtitle: Text('Details about election $index'),
//                       trailing: IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () {
//                           // Navigate to edit election screen
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageElection extends StatefulWidget {
  @override
  _ManageElectionState createState() => _ManageElectionState();
}

class _ManageElectionState extends State<ManageElection> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? _state;
  String? _year;
  String? _electionName;

  // Function to create an election and store it in Firestore
  void _createElection() async {
    // Validate the form inputs
    if (_formKey.currentState!.validate()) {
      // Save the form state to get input values
      _formKey.currentState!.save();

      // Prepare election data to store in Firestore
      final electionData = {
        'state': _state,
        'year': _year,
        'electionName': _electionName,
        'createdAt': FieldValue.serverTimestamp(), // Timestamp of creation
      };

      try {
        // Save the election data in the Firestore collection structure
        await _firestore
            .collection('Vote Chain')
            .doc('State')
            .collection(_state!)
            .doc('Election')
            .collection(_year!)
            .doc(_electionName!)
            .set(electionData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Election created successfully!')),
        );

        // Reset the form fields after successful submission
        _formKey.currentState!.reset();
      } catch (e) {
        // Show error message if any exception occurs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating election: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Elections'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Text field for entering the state name
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) => value!.isEmpty ? 'Enter state' : null,
                onSaved: (value) => _state = value,
              ),

              // Text field for entering the election year
              TextFormField(
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter year' : null,
                onSaved: (value) => _year = value,
              ),

              // Text field for entering the election name
              TextFormField(
                decoration: InputDecoration(labelText: 'Election Name'),
                validator: (value) => value!.isEmpty ? 'Enter election name' : null,
                onSaved: (value) => _electionName = value,
              ),

              SizedBox(height: 20),

              // Button to create an election
              ElevatedButton(
                onPressed: _createElection,
                child: Text('Create Election'),
              ),

              SizedBox(height: 20),

              // Display section for existing elections
              Text(
                'Existing Elections:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // StreamBuilder to listen to Firestore updates
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Vote Chain')
                    .doc('State')
                    .collection(_state ?? 'Default State')
                    .doc('Election')
                    .collection(_year ?? '2024')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final elections = snapshot.data!.docs;

                  // Display elections in a list view
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: elections.length,
                    itemBuilder: (context, index) {
                      final election = elections[index];
                      return ListTile(
                        title: Text(election['electionName']),
                        subtitle: Text('Year: ${election['year']}'),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
