
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();

  String? _selectedState;
  String? _selectedRole;
  String? _partyType;
  bool _isLoading = false;
  String? _selectedElectionType; // To store the selected election type/level

  List<String> get _states => AppConstants.statesAndUT;


  final Map<String, bool> _roleSelection = {
    'Citizen': false,
    'Admin': false,
    'Party Head': false,
    'Candidate': false,
  };

  void _register() async {
    // if (_selectedRole == null ||  _nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty ||  _passwordController.text.isEmpty || _selectedState.toString().isEmpty
    // || _partyNameController.text.isEmpty || _partyType!.isEmpty || _selectedElectionType!.isEmpty    )
    // {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Please fill all the required fields'),));
    //   return;
    // }

    if
    (   _selectedRole == null || _nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty || _selectedState == null
       ||  (_selectedRole == 'Candidate' || _selectedRole == 'Party Head')
            &&         (_partyNameController.text.isEmpty || _partyType == null)   ||
        (_selectedRole == 'Admin' && _selectedElectionType == null)
    )
    {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Please fill all the required fields')), );
      return;
    }


    setState(() { _isLoading = true;  });

    try
    {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim(),  );

      User? user = userCredential.user;

      if (user != null)
      {
        Map<String, dynamic> userData_1 = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        };

        Map<String, dynamic> userData_2 = {
          'state': _selectedState,
        };

        Map<String, dynamic> userData_3 = {
          'partyName': _partyNameController.text.trim(),
          'partyType': _partyType,
        };

        // // Storing Requests Dynamically
        // if(_selectedRole == 'Citizen')
        // {
        //   // For regular users, store data in a user-specific collection
        //   await FirebaseFirestore.instance.collection('Vote Chain/State/$_selectedState/Citizen/').doc(user.uid).set(userData_1);
        // }
        // else if (_selectedRole == 'Candidate')
        // {
        //   if (_partyType == 'Local')
        //   {  await FirebaseFirestore.instance.collection('Vote Chain/State/$_selectedState/Requests/Candidate/').doc(user.uid).set(userData_1 + userData_3);  }
        //   else
        //   {  await FirebaseFirestore.instance.collection('Vote Chain/Requests/Candidate/').doc(user.uid).set(userData_1 + userData_2 + userData_3);  }
        // }
        // else if (_selectedRole == 'Party Head')
        // {
        //   if (_partyType == 'Local')
        //   {  await FirebaseFirestore.instance.collection('Vote Chain/State/$_selectedState/Requests/Party/').doc(user.uid).set(userData_1 + userData_3);  }
        //   else
        //   {  await FirebaseFirestore.instance.collection('Vote Chain/Requests/Party/').doc(user.uid).set(userData_1 + userData_2 + userData_3);  }
        // }
        // else if (_selectedRole == 'Admin')
        // {
        //   if (_selectedRole == 'Local-State')
        //   {  await FirebaseFirestore.instance.collection('Vote Chain/State/$_selectedState/Requests/Admin/').doc(user.uid).set(userData_1);  }
        //   else
        //   {  await FirebaseFirestore.instance.collection('Vote Chain/Requests/Admin/').doc(user.uid).set(userData_1 + userData_2);  }
        //
        // }


        // Storing Requests Dynamically
        if (_selectedRole == 'Citizen')
        {
          final citizenData =
          {  ...userData_1 };
          // //  For regular users, store data in a user-specific collection
          await FirebaseFirestore.instance
              .collection('Vote Chain/State/$_selectedState/Citizen/Citizen/')
              // .doc(user.uid)
              .doc(_emailController.text.trim())
              .set(citizenData);
        }
        else if (_selectedRole == 'Candidate')
        {
          final candidateData =
          {
            ...userData_1,
            ...userData_3,
          };
          await FirebaseFirestore.instance
              .collection('Vote Chain/Candidate/$_selectedState/')
              // .doc(user.uid)
              .doc(_emailController.text.trim())
              .collection('Profile')
              .doc('Details')
              .set(candidateData);
        }
        else if (_selectedRole == 'Party Head')
        {
          final partyHeadData =
          {
            ...userData_1,
            ...userData_3,
          };
            await FirebaseFirestore.instance
                .collection('Vote Chain/Party/$_selectedState/')
                // .doc(user.uid)
                .doc(_partyNameController.text.trim())
                .collection('Party Info')
                .doc('Details') // Add a document inside 'Party Info' collection
                .set(partyHeadData);
          // Add a temporary field to mark the document as initialized
          await FirebaseFirestore.instance
              .collection('Vote Chain/Party/$_selectedState/')
              .doc(_partyNameController.text.trim())
              .set({
            'initialized': true,  // Temporary field
          }, SetOptions(merge: true));  // Merge to avoid overwriting existing data

        }
        else if (_selectedRole == 'Admin')
        {
          final adminData =
          {  ...userData_1,  };
          await FirebaseFirestore.instance
              .collection('Vote Chain/Admin/$_selectedState/')
              // .doc(user.uid)
              .doc(_emailController.text.trim())
              .collection('Profile')
              .doc('Details')
              .set(adminData);
        }


        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful !'),));
        if (_selectedRole == 'Citizen')
        { Navigator.pushReplacementNamed(context, '/CitizenHome'); }
        else if (_selectedRole == 'Candidate')
        { Navigator.pushReplacementNamed(context, '/CandidateHome'); }
        else if (_selectedRole == 'Party Head')
        { Navigator.pushReplacementNamed(context, '/PartyHome'); }
        else if (_selectedRole == 'Admin')
        { Navigator.pushReplacementNamed(context, '/AdminHome'); }
      }
    }
    catch (e)
    {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Registration Failed: $e'), ));
    }
    finally
    { setState(() {  _isLoading = false; }); }
  }


  void _guest() {
    // Implement guest login functionality (for example, navigating to a guest home screen)
    Navigator.pushReplacementNamed(context, '/GuestHome');
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
      _roleSelection.updateAll((key, value) => key == role);
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
                Image.asset('assets/images/logo.jpg', height: 150),
                SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
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
                        .map((state) => DropdownMenuItem(value: state, child: Text(state)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Column(
                  children: _roleSelection.keys.map((role) {
                    return CheckboxListTile(
                      title: Text(role),
                      value: _roleSelection[role],
                      onChanged: (bool? value) {
                        if (value != null && value) {
                          _onRoleSelected(role);
                        } else {
                          setState(() {
                            _roleSelection.updateAll((key, value) => false);
                            _selectedRole = null;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 2),
                if (_selectedRole == 'Admin') ...[
                  SizedBox(height: 2),
                  DropdownButtonFormField<String>(
                    value: _selectedElectionType,
                    items: ['Local-State', 'National'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedElectionType = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Election Type/Level',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

                SizedBox(height: 2),
                if (_selectedRole == 'Party Head' || _selectedRole == 'Candidate') ...[
                  TextField(
                    controller: _partyNameController,
                    decoration: InputDecoration(
                      labelText: 'Party Name',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _partyType ?? 'Local-State Election',
                    // value: _partyType,
                    items: ['Local-State Election', 'National Election'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _partyType = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Party Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                SizedBox(height: 14),
                Row(
                  children: [
                    // Login Button
                    Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _register,
                        child: Text('Register'),
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
                      child: _isLoading
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
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Pass the selected role to RegisterScreen
                    Navigator.pushReplacementNamed(context, '/Login', arguments: _selectedRole);
                  },
                  child: Text(
                    'Already have an account? Login',
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
