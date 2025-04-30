
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class FilterFAB extends StatelessWidget {

  const FilterFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: () {
          // Correctly call the static `show` method
          FilterDialog.show(
            context: context,
            onFilterApplied: (filters) {
              // Handle filters applied here
              print('Filters applied: $filters');
              // Update filters using the passed function

              // setState(() {
              //   selectedElectionType = filters[0];
              //   selectedState = filters[1];
              //   selectedYear = filters[2];
              //   selectedConstituency = filters[3];
              // });
              //
              // // After updating the filters, fetch the new data
              // fetchApplications();

            },
          );
        },
        child: const Icon(Icons.filter_alt),
        backgroundColor: Colors.teal,
      ),
    );
  }
}


class FilterDialog extends StatefulWidget {
  final ValueChanged<List<String>> onFilterApplied;

  const FilterDialog({Key? key, required this.onFilterApplied}) : super(key: key);

  static void show({
    required BuildContext context,
    required ValueChanged<List<String>> onFilterApplied,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(onFilterApplied: onFilterApplied);
      },
    );
  }

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String selectedType = AppConstants.electionTypes.isNotEmpty
      ? AppConstants.electionTypes.first
      : '';
  String selectedState = AppConstants.statesAndUT.isNotEmpty
      ? AppConstants.statesAndUT.first
      : '';
  String selectedYear = AppConstants.electionYear.isNotEmpty
      ? AppConstants.electionYear.first
      : '';
  String selectedConstituency = '';

  @override
  void initState() {
    super.initState();
    _updateConstituencies(); // Load initial constituencies
  }

  Future<void> _updateConstituencies() async {
    await AppConstants.loadConstituencies(selectedState, selectedType);
    if (mounted) { // Check if the widget is still mounted before calling setState
      setState(() {
        selectedConstituency = AppConstants.constituencies.isNotEmpty
            ? AppConstants.constituencies.first
            : '';
      });
    }
  }

  // Election Type Dropdown with Validation and Fallback
  Widget buildElectionTypeDropdown() {
    List<String> validElectionTypes = AppConstants.electionTypesForPartyHead;

    // Ensure the selected value is valid or fallback to the first item if invalid
    if (!validElectionTypes.contains(selectedType)) {
      selectedType = validElectionTypes.isNotEmpty ? validElectionTypes.first : '';
    }

    return DropdownButtonFormField<String>(
      value: selectedType.isNotEmpty ? selectedType : null,
      items: validElectionTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value ?? '';
          _updateConstituencies(); // Update constituencies based on the new type
        });
      },
      decoration: const InputDecoration(labelText: 'Election Type'),
    );
  }


  // Simplified dropdown builder for the state selection
  // State Dropdown (based on election type)
  Widget buildStateDropdownField({
    required String labelText,
    required String? selectedValue,
    required void Function(String?) onChanged,
    required List<String> items,
    required InputDecoration decoration,
  }) {
    // Ensure the selected value is valid or fallback to the first item if invalid
    if (selectedValue != null && !items.contains(selectedValue)) {
      selectedValue = items.isNotEmpty ? items.first : null;
    }

    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((state) {
        return DropdownMenuItem(value: state, child: Text(state));
      }).toList(),
      onChanged: onChanged,
      decoration: decoration,
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Elections'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Election Year Dropdown
          DropdownButtonFormField<String>(
            value: selectedYear.isNotEmpty ? selectedYear : null,
            items: AppConstants.electionYear.map((year) {
              return DropdownMenuItem(value: year, child: Text(year));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedYear = value ?? '';
              });
            },
            decoration: const InputDecoration(labelText: 'Election Year'),
          ),

          // Election Type Dropdown
          buildElectionTypeDropdown(),
          // State Dropdown (based on election type)
          buildStateDropdownField(
            selectedValue: selectedState.isNotEmpty ? selectedState : null,
            items: selectedType == 'General (Lok Sabha)' ||
                selectedType == 'Council of States (Rajya Sabha)'
                ? AppConstants.statesAndUT_PAN_India
                : AppConstants.statesAndUT,
            onChanged: (value) {
              setState(() {
                selectedState = value ?? '';
                _updateConstituencies(); // Update constituencies based on the new state
              });
            },
            decoration: const InputDecoration(labelText: 'State/UT'), labelText: 'State/UT',
          ),

          // Constituency Dropdown
          DropdownButtonFormField<String>(
            value: selectedConstituency.isNotEmpty ? selectedConstituency : null,
            items: AppConstants.constituencies.isNotEmpty
                ? AppConstants.constituencies.map((constituency) {
              return DropdownMenuItem(value: constituency, child: Text(constituency));
            }).toList()
                : [DropdownMenuItem(value: '', child: Text('No constituencies available'))],
            onChanged: (value) {
              setState(() {
                selectedConstituency = value ?? '';
              });
            },
            decoration: const InputDecoration(labelText: 'Constituency'),
      ),

      ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedType.isEmpty ||  selectedYear.isEmpty ||  selectedConstituency.isEmpty)
            { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all required fields to apply filters.')),    ); }
            else {
              widget.onFilterApplied([
                selectedType,
                selectedState,
                selectedYear,
                selectedConstituency
              ]);
              Navigator.pop(context);
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}