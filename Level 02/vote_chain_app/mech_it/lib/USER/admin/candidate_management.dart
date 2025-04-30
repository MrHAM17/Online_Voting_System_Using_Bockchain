// import 'package:flutter/material.dart';
//
// class ManageCandidates extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Candidates'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Navigate to add candidate screen
//                 Navigator.pushNamed(context, '/addCandidate');
//               },
//               icon: Icon(Icons.add),
//               label: Text('Add candidate'),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 10, // Replace with actual candidate data count
//                 itemBuilder: (context, index) {
//                   return Card(
//                     child: ListTile(
//                       title: Text('candidate $index'),
//                       subtitle: Text('Details about candidate $index'),
//                       trailing: IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () {
//                           // Navigate to edit candidate screen
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

class ManageCandidate extends StatefulWidget {
  @override
  _ManageCandidateState createState() => _ManageCandidateState();
}

class _ManageCandidateState extends State<ManageCandidate> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? _state;
  String? _year;
  String? _electionName;
  String? _candidateName;
  String? _partyName;

  // Function to add a candidate to Firestore
  void _addCandidate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // candidate data to save in Firestore
      final candidateData = {
        'candidateName': _candidateName,
        'partyName': _partyName,
        'voteCount': 0, // Initialize vote count to 0
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        // Save the candidate data in the Firestore structure
        await _firestore
            .collection('Vote Chain')
            .doc('State')
            .collection(_state!)
            .doc('Election')
            .collection(_year!)
            .doc(_electionName!)
            .collection('Candidates')
            .doc(_candidateName!)
            .set(candidateData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('candidate added successfully!')),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding candidate: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Candidates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Text fields for selecting state, year, and election name
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) => value!.isEmpty ? 'Enter state' : null,
                onSaved: (value) => _state = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter year' : null,
                onSaved: (value) => _year = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Election Name'),
                validator: (value) => value!.isEmpty ? 'Enter election name' : null,
                onSaved: (value) => _electionName = value,
              ),

              SizedBox(height: 20),

              // Text fields for candidate details
              TextFormField(
                decoration: InputDecoration(labelText: 'candidate Name'),
                validator: (value) => value!.isEmpty ? 'Enter candidate name' : null,
                onSaved: (value) => _candidateName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Party Name (optional)'),
                onSaved: (value) => _partyName = value,
              ),

              SizedBox(height: 20),

              // Button to add candidate
              ElevatedButton(
                onPressed: _addCandidate,
                child: Text('Add candidate'),
              ),

              SizedBox(height: 20),

              // Display section for existing candidates
              Text(
                'Existing Candidates:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: _state != null && _year != null && _electionName != null
                    ? _firestore
                    .collection('Vote Chain')
                    .doc('State')
                    .collection(_state!)
                    .doc('Election')
                    .collection(_year!)
                    .doc(_electionName!)
                    .collection('Candidates')
                    .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No candidates added yet.'),
                    );
                  }

                  final candidates = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      return ListTile(
                        title: Text(candidate['candidateName']),
                        subtitle: Text(
                            'Party: ${candidate['partyName'] ?? "Independent"}, Votes: ${candidate['voteCount']}'),
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
