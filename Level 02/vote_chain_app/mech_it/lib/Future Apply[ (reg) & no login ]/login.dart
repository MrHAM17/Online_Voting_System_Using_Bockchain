// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String? _selectedState;
//   String? _selectedRole;
//   bool _isLoading = false;
//
//   final List<String> _states = [
//     'Maharashtra', 'Karnataka', 'Delhi', 'Gujarat', 'Tamil Nadu',
//   ];
//
//   void _login() async {
//     if (_selectedState == null || _selectedRole == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please select both state and role'),
//       ));
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Sign in with email and password
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       User? user = userCredential.user;
//
//       if (user != null) {
//         // Check if citizen exists in the correct state and role
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('Vote Chain')
//             .doc('State')
//             .collection(_selectedState!)
//             .doc(_selectedRole!)
//             .collection('Accounts')
//             .doc(user.uid)
//             .get();
//
//         if (userDoc.exists) {
//           // If the document exists, proceed to navigate based on role
//           if (_selectedRole == 'admin') {
//             Navigator.pushReplacementNamed(context, '/AdminDashboard');
//           } else if (_selectedRole == 'citizen') {
//             Navigator.pushReplacementNamed(context, '/UserHome');
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('User not found under the selected state and role'),
//           ));
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Login failed. Please try again'),
//       ));
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/logo.jpg', // Replace with your app logo
//                   height: 150,
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'Welcome Back!',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email),
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: Icon(Icons.lock),
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _selectedState,
//                   items: _states
//                       .map((state) => DropdownMenuItem(
//                     value: state,
//                     child: Text(state),
//                   ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedState = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select State',
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _selectedRole,
//                   items: ['citizen', 'admin']
//                       .map((role) => DropdownMenuItem(
//                     value: role,
//                     child: Text(role.capitalize()),
//                   ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select Role',
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//                   ),
//                 ),
//                 SizedBox(height: 24),
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                   onPressed: _login,
//                   child: Text('Login'),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 TextButton(
//                   onPressed: () {
//                     // Pass the selected role to RegisterScreen
//                     Navigator.pushReplacementNamed(context, '/Register', arguments: _selectedRole);
//                   },
//                   child: Text(
//                     'Don’t have an account? Register',
//                     style: TextStyle(fontSize: 16, color: Colors.blue),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// extension StringCasingExtension on String {
//   String capitalize() {
//     return this[0].toUpperCase() + this.substring(1);
//   }
// }







import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();

  String? _selectedState;
  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _states = [
    'Maharashtra', 'Karnataka', 'Delhi', 'Gujarat', 'Tamil Nadu',
  ];


  final Map<String, bool> _roleSelection = {
    'User': false,
    'Admin': false,
    'Party Head': false,
    'Candidate': false,
  };

  void _login() async {
    if (_selectedRole == null ||  _emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedState == null )
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all the required fields'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try
    {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      // User? user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   print("User UID: ${user.uid}");
      // } else {
      //   print("No user authenticated.");
      // }


      if (user != null)
      {
        // Check if citizen exists in the correct state and role
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Vote Chain')
            .doc('State')
            .collection(_selectedState!)
            .doc(_selectedRole!)
            .collection('Accounts')
            .doc(user.uid)
            .get();

        // if (userDoc.exists) {
        //   print('User found in Firestore: ${userDoc.data()}');
        // } else {
        //   print('User not found in Firestore.');
        // }

        if (userDoc.exists)
        {
            // If the document exists, proceed to navigate based on role
            if (_selectedRole == 'Citizen')
            { Navigator.pushReplacementNamed(context, '/CitizenHome');}
            else if (_selectedRole == 'Candidate')
            { Navigator.pushReplacementNamed(context, '/CandidateHome'); }
            else if (_selectedRole == 'Admin')
            { Navigator.pushReplacementNamed(context, '/AdminDashboard'); }
        }
        else
        {
          // print('User not in Firestore');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Invalid User..'), ));
        }
      }
    }
    catch (e)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Login failed. Please try again'), ));
    }
    finally
    {  setState(() { _isLoading = false;   }); }
}
  void _guest() {
    // Implement guest login functionality (for example, navigating to a guest home screen)
    Navigator.pushReplacementNamed(context, '/GuestHome');
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
                  'assets/images/logo.jpg', // Replace with your app logo
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
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
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select State',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['Citizen', 'Candidate', 'Admin']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    // Login Button
                    Expanded(
                      child: _isLoading
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

