import 'package:flutter/material.dart';
import '../../SERVICE/utils/app_constants.dart';

class EligibleElections extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Eligible elections for the user will be displayed here.',
        style: TextStyle(fontSize: 16, color: AppConstants.secondaryColor),  // Use secondaryColor from AppConstants
        textAlign: TextAlign.center,
      ),
    );
  }
}
