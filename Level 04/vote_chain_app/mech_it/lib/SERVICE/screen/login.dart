
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mech_it/USER/candidate/candidate_home.dart';

import '../../USER/admin/Home_Profile_admin.dart';
import '../../USER/citizen/citizen_home.dart';
import '../../USER/party/Home_party_head.dart';
import '../utils/app_constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedState;
  String? _selectedRole;
  String? _selectedParty;
  bool _isLoading = false;
  bool _isLoginLoading = false;
  bool _isGuestLoading = false;

  List<String> _parties = [];


  // Use states from AppConstants
  List<String> get _states => AppConstants.statesAndUT;


  // Fetch parties for the selected state
  void _fetchPartiesForState() async {
    if (_selectedState != null) {
      try
      {
        // Querying the documents under the state collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Vote Chain')
            .doc('Party')  // Parent collection
            .collection(_selectedState!)  // State collection
            .get();  // Getting the documents (each document represents a party)

        print('QuerySnapshot Docs: ${querySnapshot.docs.length}');  // Log how many documents were fetched

        if (querySnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No parties found for the selected state')),
          );
          return;  // Exit early if no parties were found
        }

        // Log details about each document
        for (var doc in querySnapshot.docs) {
          print('Document ID: ${doc.id} | Data: ${doc.data()}');
          print('Party Name (ID): ${doc.id}');
          print('Party Data: ${doc.data()}');

          // Check if document has subcollections (e.g., 'Party Info') and treat it as a valid party
          bool hasSubcollection = await FirebaseFirestore.instance
              .collection('Vote Chain')
              .doc('Party')
              .collection(_selectedState!)
              .doc(doc.id)
              .collection('Party Info')
              .get()
              .then((snapshot) => snapshot.docs.isNotEmpty);

          if (hasSubcollection) {
            // This document has a subcollection, so we consider it a valid party
            print('Valid Party found: ${doc.id}');
          }
        }

        // Extract party document IDs (i.e., party names, which are doc IDs)
        setState(() {
          _parties = querySnapshot.docs.map((doc) => doc.id).toList();  // Document ID is the party name
          _selectedParty = null;  // Reset selected party
        });

        // Log the fetched parties
        print("Fetched parties: $_parties");

      }
      catch (e)
      {
        print('Error fetching parties: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching parties. Please try again.')),
        );
      }
    }
  }

  void _login() async {
    if (_selectedRole == null ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedState == null ||
        (_selectedRole == 'Party Head' && _selectedParty == null))
    {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Please fill all the required fields')),  );
      return;
    }

    setState(() {
      _isLoginLoading = true;
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot? userDoc;

        if (_selectedRole == 'Citizen')
        {
          userDoc = await FirebaseFirestore.instance
              .collection('Vote Chain')
              .doc('State')
              .collection('$_selectedState/Citizen/Citizen/')
              .doc(_emailController.text.trim())
              .get();
        }
        else if (_selectedRole == 'Candidate')
        {
          userDoc = await FirebaseFirestore.instance
              .collection('Vote Chain')
              .doc('Candidate')
              .collection(_selectedState!)
              .doc(_emailController.text.trim())
              .collection('Profile')
              .doc('Details')
              .get();
        }
        else if (_selectedRole == 'Party Head')
        {
          userDoc = await FirebaseFirestore.instance
              .collection('Vote Chain')
              .doc('Party')
              .collection(_selectedState!)
              .doc(_selectedParty!)
              .collection('Party Info')
              .doc('Details') // Add a document inside 'Party Info' collection
              .get();
          print('\n**********************\n Fetching from path: /Vote Chain/Party/$_selectedState/$_selectedParty/Party Info/Details/ \n\n');

        }
        else if (_selectedRole == 'Admin')
        {
          userDoc = await FirebaseFirestore.instance
              .collection('Vote Chain')
              .doc('Admin')
              .collection(_selectedState!)
              .doc(_emailController.text.trim())
              .collection('Profile')
              .doc('Details')
              .get();
        }

          // if (userDoc != null)  // works --> faulty ?
          // if (userDoc.exists)  //  not works
          // if (userDoc!.exists)  //  not works
          // if (!userDoc!.exists)  // works
        if (userDoc != null && userDoc.exists)  // works --> faulty ?
        {
          if (_selectedRole == 'Citizen')
          {
            // Navigator.pushReplacementNamed(context, '/CitizenHome');
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => CitizenHome(state: _selectedState ?? 'Default State', email: _emailController.text.trim(),),
                settings: RouteSettings( arguments: { 'state': _selectedState, 'email': _emailController.text.trim(),  },  ),
              ),
            );
          }
          else if (_selectedRole == 'Candidate')
          {
            // Navigator.pushReplacementNamed(context, '/CandidateHome');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateHome(state: _selectedState ?? 'Default State', email: _emailController.text.trim(),),
                settings: RouteSettings( arguments: { 'state': _selectedState, 'email': _emailController.text.trim(),  },  ),
              ),
            );
          }
          else if (_selectedRole == 'Party Head')
          {
              // Get the email field from the fetched document
              String storedEmail = userDoc['email'];  // Assuming 'email' is the field in the document
              // Pass the state name if available, otherwise handle the empty string case
              // String? stateName = _selectedState!.isNotEmpty ? _selectedState : 'Maharashtra';


              // Compare it with the entered email
              if (_emailController.text.trim() == storedEmail)
              // { Navigator.pushReplacementNamed(context, '/PartyHome', arguments: {'stateName': stateName},); }
              // { Navigator.pushReplacementNamed(context, PartyHeadHomeScreen(), arguments: {'stateName': stateName},); }
              { Navigator.pushReplacement(context,
                MaterialPageRoute( builder: (context) =>  PartyHeadHome(),
                                             settings: RouteSettings( arguments: { 'stateName': _selectedState, 'partyName': _selectedParty, }, ), ), );
              }
              else { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('User does not exist or invalid details.')),  );   }
          }
          else if (_selectedRole == 'Admin')
          {
            // Navigator.pushReplacementNamed(context, '/AdminHome');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminHome( state: _selectedState ?? 'Default State', email: _emailController.text.trim(),),
              ),
            );
          }
        }
        else { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('User does not exist or invalid details.')),  );   }
      }
    }
    catch (e) { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('User does not exist or invalid details.')),);
    }
    finally { setState(() { _isLoginLoading = false; }); }
  }

  void _guest() {
    setState(() {
      _isGuestLoading = true;
    });

    // Simulating guest login
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/GuestHome');
      setState(() {
        _isGuestLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,  // This will ensure the dropdown fills the available width
                    value: _selectedState,
                    items: _states
                        .map((state) => DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                        if (_selectedRole == 'Party Head') {
                          _fetchPartiesForState();
                        }
                      });
                      print("Selected State: $_selectedState");  // Debug print for state selection
                    },
                    decoration: InputDecoration(
                      labelText: 'Select State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['Citizen', 'Candidate', 'Party Head', 'Admin']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                      _selectedParty = null;  // Reset party selection when role changes
                      if (_selectedRole == 'Party Head') {
                        _fetchPartiesForState();
                      }
                    });
                    print("Selected Role: $_selectedRole");  // Debug print for role selection
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                if (_selectedRole == 'Party Head')
                DropdownButtonFormField<String>(
                    value: _selectedParty,
                    items: _parties
                        .map((party) => DropdownMenuItem(
                      value: party,
                      child: Text(party),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedParty = value;
                      });
                      print("Selected Party: $_selectedParty");  // Debug print for party selection
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Party',
                      border: OutlineInputBorder(),
                    ),
                  ),
                SizedBox(height: 24),
                Row(
                  children: [
                    // Login Button
                    Expanded(
                      child: _isLoginLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Space between buttons
                    // Guest Button
                    Expanded(
                      child: _isGuestLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _guest,
                        child: Text('View as Guest'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          primary: Colors.grey[300], // Light gray color for guest button
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Pass the selected role to RegisterScreen
                    Navigator.pushReplacementNamed(context, '/Register', arguments: _selectedRole);
                  },
                  child: Text(
                    'Don’t have an account? Register',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

