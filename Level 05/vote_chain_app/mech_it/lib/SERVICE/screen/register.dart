
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../USER/admin/Home_Profile_admin.dart';
import '../../USER/candidate/candidate_home.dart';
import '../../USER/citizen/citizen_home.dart';
import '../../USER/party/Home_party_head.dart';
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
  final TextEditingController _birthDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  String? _selectedState;
  String? _partyType;
  String? _selectedGender;  // Store the selected gender here
  String? _selectedEducation;
  String? _selectedEmployment;
  String? _selectedResidence;
  String? _selectedLocSabhaConstituency;
  String? _selectedVidhanSabhaConstituency;
  String? _selectedDisability;
  String? _selectedVoterCategory;

  List<String> get _gender => AppConstants.genders;
  List<String> get _education => AppConstants.educationLevels;
  List<String> get _employmentStatus => AppConstants.employmentStatuses;
  List<String> get _residenceType => AppConstants.residenceTypes;
  List<String> get _disabilityType => AppConstants.disabilityStatuses;
  List<String> get _locSabhaConstituency => AppConstants.constituencies;
  List<String> get _vidhanSabhaConstituency => AppConstants.constituencies;

  List<String> get _voterCategory => AppConstants.voterCategories;
  // List<String> get _incomeLevels => AppConstants.incomeLevels;
  // String? _selectedProfession;
  // String? _selectedCategory;
  // String? _selectedMaritalStatus;
  // String? _selectedReligion;
  // bool _isLoading = false;
  bool _isRegisterLoading = false;
  bool _isGuestLoading = false;
  String? _selectedElectionType; // To store the selected election type/level

  List<String> get _states => AppConstants.statesAndUT;
  List<String> _lokSabhaConstituencies = [];
  List<String> _vidhanSabhaConstituencies = [];


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
        _passwordController.text.isEmpty || _selectedState == null || _birthDateController.text.isEmpty  ||
        (_selectedRole == 'Party Head'  && _partyNameController.text.isEmpty && _partyType == null  )


        // _gender == null || _education == null || _employmentStatus == null ||_residenceType == null || _selectedDisability == null  ||
        // _selectedSpecialCategory == null ||
        // // _selectedIncome == null ||_selectedReligion == null  ||_selectedCategory == null  || _selectedProfession == null

        // (_selectedRole == 'Citizen'  && _selectedConstituency == null
        //     // && _selectedMaritalStatus == null
        // ) ||

        // (
         //    // _selectedRole == 'Candidate' ||
         //    (_selectedRole == 'Party Head' ) && _partyNameController.text.isEmpty || _partyType == null
         // )
        // ||  (
        //     _selectedRole == 'Admin'
        //     && _selectedElectionType == null
        //     )
    )
    {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Please fill all the required fields')), );
      return;
    }


    setState(() { _isRegisterLoading = true;  });

    try
    {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim(),  );

      User? user = userCredential.user;

      if (user != null)
      {
        Map<String, dynamic> userData_1 = {
          'name': _nameController.text.trim(),
          'birthDate': _birthDateController.text.trim(),
          'gender': _selectedGender,

          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'registerAt': Timestamp.now(), // Adding timestamp
        };

        Map<String, dynamic> userData_2 = {
          'state': _selectedState,
        };

        Map<String, dynamic> userData_3 = {
          'partyName': _partyNameController.text.trim(),
          'partyType': _partyType,
        };

        Map<String, dynamic> userData_4 = {
          'education': _selectedEducation,
          'employmentStatus': _selectedEmployment,
          // 'profession': _selectedProfession,
          // 'maritalStatus': _selectedMaritalStatus,
          // 'incomeLevel': _selectedIncome,

          'residence': _selectedResidence,
          'locSabhaConstituency': _selectedLocSabhaConstituency,
          'vidhanSabhaConstituency': _selectedVidhanSabhaConstituency,
          // 'caste': _selectedCategory,
          // 'religion': _selectedReligion,
          'voterCategory': _selectedVoterCategory,
          'disabilityStatus': _selectedDisability,

          'totalVotes': 0, // Overall vote counter
          'totalLocSabhaVotes': 0,
          'totalVidhanSabhaVotes': 0,
          'totalMunicipalVotes': 0,
          'totalPanchayatVotes': 0,
          // Initialize election data as a sub-map for each election type
          'electionData': {
            'locSabha': {},       // e.g., will hold keys like "2024": { ...vote details... }
            'vidhanSabha': {},
            'municipal': {},
            'Panchayat': {},
          },
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
          {
            ...userData_1,
            ...userData_2,
            ...userData_4
          };
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
            // ...userData_3,
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
            ...userData_2,
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
        if
        (_selectedRole == 'Citizen')
        {
          // Navigator.pushReplacementNamed(context, '/CitizenHome');
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => CitizenHome(state: _selectedState ?? 'Default State', email: _emailController.text.trim(),),
            settings: RouteSettings( arguments: { 'state': _selectedState, 'email': _emailController.text.trim(),  },  ),
          ), );
        }
        else if
        (_selectedRole == 'Candidate')
        {
          // Navigator.pushReplacementNamed(context, '/CandidateHome');
          Navigator.pushReplacement( context,MaterialPageRoute(
              builder: (context) => CandidateHome(state: _selectedState ?? 'Default State', email: _emailController.text.trim(),),
              settings: RouteSettings( arguments: { 'state': _selectedState, 'email': _emailController.text.trim(),  },  ),
            ),
          );
        }
        else if
        (_selectedRole == 'Party Head')
        {
           // Navigator.pushReplacementNamed(context, '/PartyHome');
           Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) =>  PartyHeadHome(),
           settings: RouteSettings( arguments: { 'stateName': _selectedState, 'partyName': _partyNameController.text.trim(), }, ), ), );
        }
        else if (_selectedRole == 'Admin')
        {
          // Navigator.pushReplacementNamed(context, '/AdminHome');
          Navigator.pushReplacement( context,MaterialPageRoute( builder: (context) => AdminHome( state: _selectedState ?? 'Default State', email: _emailController.text.trim(),), ), );
        }
      }
    }
    catch (e)
    {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Registration Failed: $e'), ));
    }
    finally
    { setState(() {  _isRegisterLoading = false; }); }
  }

  void _guest() {
    setState(() {
      _isGuestLoading = true;
    });

    // Implement guest login functionality (for example, navigating to a guest home screen)
    // Navigator.pushReplacementNamed(context, '/GuestHome');
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/GuestHome');
      setState(() {
        _isGuestLoading = false;
      });
    });
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
      _roleSelection.updateAll((key, value) => key == role);
    });
  }

  // Function to show DatePicker and update the controller
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      // Format the date to YYYY-MM-DD
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> getConstituencies() async {
    if (_selectedState == null ) return;

    await AppConstants.loadConstituencies(_selectedState!, "General (Lok Sabha)", "Citizen");
    setState(() {
      _lokSabhaConstituencies = List.from(AppConstants.constituencies);
    });

    await AppConstants.loadConstituencies(_selectedState!, "State Assembly (Vidhan Sabha)", "Citizen");
    setState(() {
      _vidhanSabhaConstituencies = List.from(AppConstants.constituencies);
    });
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,  // This will ensure the dropdown fills the available width
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: selectedValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
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
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: _gender.map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender))
                  ).toList(),
                  onChanged: (val) => setState(() => _selectedGender  = val),
                  decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                  validator: (value) => value == null ? 'Please select a gender' : null,
                ),
                SizedBox(height: 16),
                // TextField(controller: _birthDateController, decoration: InputDecoration(labelText: 'Birth Date (YYYY-MM-DD)')),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Birth Date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    prefixIcon: IconButton(
                      // icon: Icon(Icons.date_range),
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectBirthDate(context),  // Open date picker
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  onTap: () {
                    // Open date picker when tapping the field
                    _selectBirthDate(context);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a birth date';
                    }
                    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!dateRegex.hasMatch(value)) {
                      return 'Enter a valid date (YYYY-MM-DD)';
                    }
                    return null;
                  },
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
                        getConstituencies();
                        _selectedLocSabhaConstituency = null;
                        _selectedVidhanSabhaConstituency = null;
                        _lokSabhaConstituencies.clear();
                        _vidhanSabhaConstituencies.clear();
                      });
                      // getConstituencies();
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
                if (_selectedRole == 'Citizen') ...[
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDropdown('Education Level', AppConstants.educationLevels, _selectedEducation, (value) {
                          setState(() => _selectedEducation = value);
                        }),
                        SizedBox(height: 16),
                        _buildDropdown('Employment Status', AppConstants.employmentStatuses, _selectedEmployment, (value) {
                          setState(() => _selectedEmployment = value);
                        }),
                        SizedBox(height: 16),
                        _buildDropdown('Residence Type', AppConstants.residenceTypes, _selectedResidence, (value) {
                          setState(() => _selectedResidence = value);
                        }),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedLocSabhaConstituency,
                          items: _lokSabhaConstituencies
                              .map((constituency) => DropdownMenuItem(value: constituency, child: Text(constituency)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocSabhaConstituency = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Lok Sabha Constituency', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedVidhanSabhaConstituency,
                          items: _vidhanSabhaConstituencies
                              .map((constituency) => DropdownMenuItem(value: constituency, child: Text(constituency)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVidhanSabhaConstituency = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Vidhan Sabha Constituency', border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 16),
                        _buildDropdown('Voter Category', AppConstants.voterCategories, _selectedVoterCategory, (value) {
                          setState(() => _selectedVoterCategory = value);
                        }),
                        SizedBox(height: 16),
                        _buildDropdown('Disability Status', AppConstants.disabilityStatuses, _selectedDisability, (value) {
                          setState(() => _selectedDisability = value);
                        }),
                      ],
                    ),
                  ),
                ],

                // SizedBox(height: 2),
                // if (_selectedRole == 'Admin') ...[
                //   SizedBox(height: 2),
                //   DropdownButtonFormField<String>(
                //     value: _selectedElectionType,
                //     items: ['Local-State', 'National'].map((type) {
                //       return DropdownMenuItem(
                //         value: type,
                //         child: Text(type),
                //       );
                //     }).toList(),
                //     onChanged: (value) {
                //       setState(() {
                //         _selectedElectionType = value;
                //       });
                //     },
                //     decoration: InputDecoration(
                //       labelText: 'Election Type/Level',
                //       border: OutlineInputBorder(),
                //     ),
                //   ),
                // ],

                SizedBox(height: 2),
                if
                (  _selectedRole == 'Party Head'
                    // || _selectedRole == 'Candidate'
                ) ...[
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
                      child: _isRegisterLoading
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
