import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'Profile_admin_.dart';
import 'election_details.dart';


class AdminHome extends StatefulWidget {
  final String state;
  final String email;

  AdminHome({required this.state, required this.email});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}


class _AdminHomeState extends State<AdminHome> {
  final _codeController = TextEditingController();
  final _privateKeyMetaMaskController = TextEditingController();

  String _selectedElectionType = AppConstants.electionTypes.first;
  String _selectedYear = AppConstants.electionYear.first;
  String _selectedState = AppConstants.statesAndUT.first;
  bool _isLoading = false;

  int _currentIndex = 0;



  Future<void> validateCode() async {
    setState(() => _isLoading = true);
    try {
      final code = _codeController.text.trim();
      final privateKey = _privateKeyMetaMaskController.text.trim(); //  Get private key from input

      if (code.isEmpty || privateKey.isEmpty) {
        SnackbarUtils.showErrorMessage(context, "Please fill all required fields.");
        return;
      }

      String path = '';

      if (_selectedElectionType == "General (Lok Sabha)" || _selectedElectionType == "Council of States (Rajya Sabha)")
      { path = 'Vote Chain/Election/$_selectedYear/$_selectedElectionType/State/$_selectedState/Admin'; }
      else
      { path = 'Vote Chain/State/$_selectedState/Election/$_selectedYear/$_selectedElectionType/Admin'; }

      final docRef = FirebaseFirestore.instance.collection(path).doc('Details');
      final doc = await docRef.get();

      if (doc.exists && doc.data()?['ElectionCode'] == code) {
        // Store election details in the election_details.dart singleton
        ElectionDetails.instance.electionType = _selectedElectionType;
        ElectionDetails.instance.year = _selectedYear;
        ElectionDetails.instance.state = _selectedState;
        ElectionDetails.instance.privateKeyMetaMask = privateKey;

        // Navigate to AdminDashboard with selected arguments
        Navigator.pushNamed(context, '/AdminDashboard', arguments: {
          'electionType': _selectedElectionType,
          'year': _selectedYear,
          'state': _selectedState,
        });

        // Clear all fields after navigation
        clearFields();
      }
      else
      { SnackbarUtils.showErrorMessage(context,"Invalid code or election details."); }
    }
    catch (e)
    { SnackbarUtils.showErrorMessage(context,"Error validating code: $e"); }
    finally
    { setState(() => _isLoading = false); }
  }

  void clearFields() {
    setState(() {
      _codeController.clear();
      _privateKeyMetaMaskController.clear(); // Fixed
      _selectedElectionType = AppConstants.electionTypes.first;
      _selectedYear = AppConstants.electionYear.first;
      _selectedState = AppConstants.statesAndUT.first;
    });
  }

  Widget _buildAdminHomeBody() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedElectionType,
                decoration: InputDecoration(
                  labelText: 'Election Type',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.electionTypes
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedElectionType = value!);
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.electionYear
                    .map((year) => DropdownMenuItem(
                  value: year,
                  child: Text(year),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedYear = value!);
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedState,
                decoration: InputDecoration(
                  labelText: 'State/UT',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.statesAndUT
                    .map((state) => DropdownMenuItem(
                  value: state,
                  child: Text(state),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedState = value!);
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _codeController,
                obscureText: true, // Hide private key for security
                decoration: InputDecoration(
                  labelText: 'Election Code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _privateKeyMetaMaskController, // New input field
                obscureText: true, // Hide private key for security
                decoration: InputDecoration(labelText: 'MetaMask Private Key', border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: validateCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildAdminHomeBody();
      case 1:
        return AdminProfile(
          state: widget.state,
          email: widget.email,
        );
      default:
        return _buildAdminHomeBody();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Admin Panel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.logout),
          //   onPressed: () {
          //     Navigator.pushReplacementNamed(context, '/Login');
          //   },
          // ),
          LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppConstants.secondaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
