// styled_button.dart

import 'package:flutter/material.dart';

import '../utils/app_constants.dart';


class SnackbarUtils {
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }
  static void showNeutralMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
    ));
  }
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
    ));
  }
}


class StateDropdownField extends StatelessWidget {
  final String label;
  final String? selectedState;
  final void Function(String?) onChanged;
  final String? selectedElectionType;

  const StateDropdownField({
    Key? key,
    required this.label,
    required this.selectedState,
    required this.onChanged,
    required this.selectedElectionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
  // Determine the list of states based on the selected election type
  List<String> items;
    if
    ( selectedElectionType == "Presidential" || selectedElectionType == "Vice-Presidential")
    { items = AppConstants.statesAndUT_PAN_India; }
    else if
    (
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||
      selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)" ||
      selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)"
    )
    {  items = AppConstants.statesAndUT;  }
    // { items = [...AppConstants.statesAndUT_PAN_India, ...AppConstants.statesAndUT]; }       // Combine _PAN India and statesAndUT lists
    else
    { items = [];  }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedState,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget partyDropdownField({
  required String label,
  required List<String> items,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
  bool enabled = true, // Parameter to enable/disable the dropdown
}) {
  final bool hasParties = items.isNotEmpty; // Check if there are any parties available

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true, // Ensure the dropdown fills the available width
          value: hasParties ? selectedValue : null, // Set value only if parties exist
          items: hasParties
              ? items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList()
              : [
            const DropdownMenuItem<String>(
              value: null,
              child: Text("No Party Found"), // Show this when no parties exist
            )
          ],
          onChanged: hasParties && enabled ? onChanged : null, // Enable only if parties exist and enabled is true
          decoration: InputDecoration(
            labelText: enabled ? label : null, // Show label only when enabled
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            floatingLabelBehavior: selectedValue != null
                ? FloatingLabelBehavior.auto // Float label if a value is selected
                : FloatingLabelBehavior.never, // Otherwise, don't float
          ),
          hint: hasParties ? null : const Text("No Party Found"), // Conditional hint when no parties
          disabledHint: const Text("Party"), // When disabled
        ),
      ],
    ),
  );
}

Widget buildDropdownField({
  required String label,
  required List<String> items,
  required String? selectedValue,
  required void Function(String?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          child:
          DropdownButtonFormField<String>(
            isExpanded: true,  // This will ensure the dropdown fills the available width
            value: selectedValue,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,  // This will show the label inside the border
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              floatingLabelBehavior: FloatingLabelBehavior.auto,  // This ensures the label floats
            ),
          ),
        ),
      ],
    ),
  );
}


Widget buildStyledButton({
  required String text,
  required VoidCallback onPressed,
  required Color color,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}


class LogoutButton extends StatelessWidget {
  final Color? iconColor;
  final VoidCallback onPressed;

  const LogoutButton({
    Key? key,
    required this.onPressed,
    this.iconColor, // Optional color parameter, defaults to red
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout),
      color: Colors.white, // Default to red if no color is provided
      onPressed: () async {
        // Show confirmation dialog before logout
        bool? confirmLogout = await showLogoutConfirmationDialog(context);
        if (confirmLogout ?? false) {
          // If confirmed, execute the passed onPressed function
          onPressed();
        }
      },
    );
  }

  Future<bool?> showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User has to confirm or cancel
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}