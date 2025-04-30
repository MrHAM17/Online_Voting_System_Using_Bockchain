
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mech_it/SERVICE/screen/styled_widget.dart';
import '../utils/app_constants.dart';

class FilterFAB extends StatelessWidget {

  final String role; // Add a role parameter
  final ValueChanged<Map<String, String?>> onFilterApplied;

  const FilterFAB({Key? key, required this.role, required this.onFilterApplied}) : super(key: key);

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
            role: role, // Pass the role here
            onFilterApplied: onFilterApplied,
            // onFilterApplied: (filters) {
            //   // Handle filters applied here
            //   print('Filters applied: $filters');
            //   // Update filters using the passed function
            //
            //   // setState(() {
            //   //   selectedElectionType = filters[0];
            //   //   selectedState = filters[1];
            //   //   selectedYear = filters[2];
            //   //   selectedConstituency = filters[3];
            //   // });
            //   //
            //   // // After updating the filters, fetch the new data
            //   // fetchApplications();
            //
            // },
          );
        },
        child: const Icon(Icons.filter_alt),
        backgroundColor: Colors.teal,
      ),
    );
  }
}


class FilterDialog extends StatefulWidget {
  final ValueChanged<Map<String, String?>> onFilterApplied; // Change the type
  final String role; // Declare the role field

  const FilterDialog({Key? key, required this.onFilterApplied, required this.role}) : super(key: key);

  static void show({
    required BuildContext context,
    required String role, // Accept the role
    required ValueChanged<Map<String, String?>> onFilterApplied, // Adjust type here
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(onFilterApplied: onFilterApplied, role: role);
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
  String selectedParty = '';
  List<String> parties = []; // Declare the list of parties here



  @override
  void initState() {
    super.initState();
    updateConstituencies(); // Load initial constituencies
  }

  // Election Type Dropdown with Validation and Fallback
  Widget buildElectionTypeDropdown() {
    // List<String> validElectionTypes = AppConstants.electionTypes;

    List<String> validElectionTypes;
    if (widget.role == 'Citizen_Previous_Ellection') { validElectionTypes = AppConstants.electionTypes; }
    else if (widget.role == 'Party Head'  || widget.role == "Party_Head_View" || widget.role == 'Candidate')
    { validElectionTypes = AppConstants.electionTypesForPartyHead; }
    else { validElectionTypes = []; }


    //
    // // Ensure the selected value is valid or fallback to the first item if invalid
    // if (!validElectionTypes.contains(selectedType)) {
    //   selectedType = validElectionTypes.isNotEmpty ? validElectionTypes.first : '';
    // }
    return DropdownButtonFormField<String>(
      value: selectedType.isNotEmpty ? selectedType : null,
      items: validElectionTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) {
        setState(()
        {
          selectedType = value ?? '';
          selectedState = ''; // Reset state when election type changes
          selectedConstituency = ''; // Reset constituency when election type changes
          parties = []; // Clear the current party list
          fetchParties(); // Fetch parties based on the new filter
          updateConstituencies(); // Update constituencies based on the new type
        });
      },
      isExpanded: true, // Add this line
      decoration: const InputDecoration(labelText: 'Election Type',
          // contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    ),
    );
  }


  // Simplified dropdown builder for the state selection
  // State Dropdown (based on election type)
  Widget buildStateDropdownField({
    required String labelText,
    required String? selectedState,
    required void Function(String?) onChanged,
    required InputDecoration decoration,
  })
  {
    // Determine the list of states based on the selected election type
    List<String> items = []; // Default to an empty list

    if
    ( selectedType == "Presidential" || selectedType == "Vice-Presidential")
    { items = AppConstants.statesAndUT_PAN_India; }
    else if
    (
        selectedType == "Municipal" || selectedType == "Panchayat" ||
        selectedType == "State Assembly (Vidhan Sabha)" || selectedType == "Legislary Council (Vidhan Parishad)" ||
        selectedType == "General (Lok Sabha)" || selectedType == "Council of States (Rajya Sabha)"
    )
    {
      if (widget.role == 'Citizen_Previous_Ellection')
      { items = [...AppConstants.statesAndUT_PAN_India, ...AppConstants.statesAndUT];   }
      else if (widget.role == 'Party Head' || widget.role == "Party_Head_View" || widget.role == 'Candidate')
      { items = AppConstants.statesAndUT;   }
    }

    // Remove duplicates by converting to a Set and back to a List
    items = items.toSet().toList();


    // Validate selectedState and set a fallback
    String? dropdownValue = (selectedState != null && items.contains(selectedState))
        ? selectedState
        : (items.isNotEmpty ? items.first : null);

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      items: items.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
      onChanged: onChanged,
      isExpanded: true, // Add this line
      decoration: decoration,
    );
  }

  // Widget buildConstituencyDropdown() {
  //   if (AppConstants.constituencies.isEmpty) {
  //     return DropdownButtonFormField<String>(
  //       value: null,
  //       items: [
  //         DropdownMenuItem(value: '', child: Text('No constituencies available')),
  //       ],
  //       onChanged: null, // Disable the dropdown
  //       decoration: const InputDecoration(labelText: '^^^^Constituency'),
  //     );
  //   }
  //
  //   return DropdownButtonFormField<String>(
  //     value: selectedConstituency.isNotEmpty ? selectedConstituency : null,
  //     items: AppConstants.constituencies.map((constituency) {
  //       return DropdownMenuItem(value: constituency, child: Text(constituency));
  //     }).toList(),
  //     onChanged: (value) {
  //       setState(() {
  //         selectedConstituency = value ?? '';
  //       });
  //     },
  //     decoration: const InputDecoration(labelText: '***********Constituency'),
  //   );
  // }


  // // ******************************************************************************************************    IMP  will c ...        ********************************************
  // // ******************************************************************************************************    IMP  will c ...        ********************************************
  Future<void> fetchParties() async {
    if (selectedType.isEmpty || selectedState.isEmpty || selectedYear.isEmpty)
    { return; }

    try {
      // Determine the path based on election type
      String basePath = '';
      if (selectedType == 'General (Lok Sabha)' || selectedType == 'Council of States (Rajya Sabha)')
      { basePath = 'Vote Chain/Election/$selectedYear/$selectedType/State/$selectedState/Result'; }
      else if
      (
        selectedType == "State Assembly (Vidhan Sabha)" || selectedType == "Legislary Council (Vidhan Parishad)"  ||
        selectedType == "Municipal" || selectedType == "Panchayat"
      )
      { basePath = 'Vote Chain/State/$selectedState/Election/$selectedYear/$selectedType/Result'; }

      // Fetch parties and their vote count from the results path
      final snapshot = await FirebaseFirestore.instance
          .collection(basePath)
          .get();

      // Map the results to extract party names
      setState(() {
        parties = snapshot.docs.map((doc) {
          // Each document ID will be the candidate email, retrieve party details if needed
          return doc.id; // Replace this with `doc['partyName']` if you store it explicitly
        }).toList();
      });
    } catch (e)
    {
      print("Error fetching parties: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to fetch parties. Try again."),
      ));
    }
  }



  Future<void> updateConstituencies() async
  {
    // If the election type is unsupported, show a snackbar
    if
    ( selectedType == "By-elections" || selectedType == "Referendum" || selectedType == "Confidence Motion (Floor Test)"  || selectedType == "No Confidence Motion" )
    {
      SnackbarUtils.showErrorMessage(context, "The $selectedType is under implementation...\nPlease change to other Election Type.");
      selectedType = "" ;
      selectedState = "" ;
      selectedConstituency = "" ;
      return;
    }


    if
    ( widget.role == "Party_Head_View" )
    {  await AppConstants.loadConstituencies(selectedState, selectedType, "Party_Head_Viewing_Selected_Candidates_Over_All_Constituencies_SO_Want_'All_Constituencies'_as_option");   }
    else
    {  await AppConstants.loadConstituencies(selectedState, selectedType, "Not_Want_'All_Constituencies'_as_option");   }


    // Check if the widget is still mounted before calling setState
    if (mounted)
    {  setState(() { selectedConstituency = AppConstants.constituencies.isNotEmpty ? AppConstants.constituencies.first : ''; });   }
  }



  @override
  Widget build(BuildContext context)
  {
    return AlertDialog(
      title: const Text('Filter Elections'),
      content: SingleChildScrollView(
        child: Column(
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
                  parties = []; // Clear the current party list
                  fetchParties(); // Fetch parties based on the new filter
                });
              },
              decoration: const InputDecoration(labelText: 'Election Year'),
            ),

            // Election Type Dropdown
            ClipRect(child: buildElectionTypeDropdown()),
            // State Dropdown (based on election type)
            ClipRect(
              child: buildStateDropdownField
                (
                selectedState: selectedState.isNotEmpty ? selectedState : null,
                // items: selectedType == 'Presidential' || selectedType == 'Vice-Presidential' ? AppConstants.statesAndUT_PAN_India : AppConstants.statesAndUT,
                //
                // items: selectedType == 'Presidential' || selectedType == 'Vice-Presidential'
                //     ? AppConstants.statesAndUT_PAN_India
                //     : [...AppConstants.statesAndUT_PAN_India, ...AppConstants.statesAndUT],
              
                onChanged: (value) {
                  setState(()
                  {
                    selectedState = value ?? '';
                    updateConstituencies(); // Update constituencies based on the new state
                    parties = []; // Clear the current party list
                    fetchParties(); // Fetch parties based on the new filter
                  });
                },
                decoration: const InputDecoration(labelText: 'State/UT'), labelText: 'State/UT',
              ),
            ),

            // // ******************************************************************************************************    IMP  will c ...      ********************************************
            // Party Dropdown (only for Candidate role)
            if (widget.role != 'Party Head' && widget.role != 'Party_Head_View' && widget.role != 'Citizen_Previous_Ellection' )
              DropdownButtonFormField<String>(
                value: selectedParty.isEmpty ? null : selectedParty,
                hint: const Text("Select Party"),
                items: parties.map((party) {
                  return DropdownMenuItem(
                    value: party,
                    child: Text(party),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedParty = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Party'),
              ),
            const SizedBox(height: 16.0),

            if(selectedType != 'Presidential' && selectedType != 'Vice-Presidential' && selectedState != "_PAN India"
                // && widget.role != "Party Head" && widget.role != 'Party_Head_View'
            )
              // Constituency Dropdown
              // DropdownButtonFormField<String>
              //   (
              //   value: selectedConstituency.isNotEmpty ? selectedConstituency : null,
              //   items: AppConstants.constituencies.isNotEmpty
              //       ? AppConstants.constituencies.map((constituency)
              //   { return DropdownMenuItem(value: constituency, child: Text(constituency));  }).toList()
              //       : [DropdownMenuItem(value: '', child: Text('No constituencies available'))],
              //   onChanged: (value)
              //   {
              //     setState(() { selectedConstituency = value ?? ''; });
              //   },
              //   decoration: const InputDecoration(labelText: 'Constituency'),
              // ),
              DropdownButtonFormField<String>(
                value: selectedConstituency.isNotEmpty ? selectedConstituency : null,
                items: [
                    ...AppConstants.All_Constituencies.map(
                      (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                      ),
                    ),
                    ...AppConstants.constituencies.map(
                      (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                      ),
                   ),
                  ],
                  onChanged: (value) {
                    setState(() {
                    selectedConstituency = value ?? '';
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Constituency'),
                ),
    ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: ()
          {
            if ( selectedYear.isNotEmpty && selectedType.isNotEmpty && selectedState.isNotEmpty  && selectedConstituency.isEmpty  &&  widget.role == "Citizen_Previous_Ellection"  )
            {
              print("0 hiii ................ ");

              widget.onFilterApplied({
                  'year': selectedYear,
                  'type': selectedType,
                  'state': selectedState,
                });
                Navigator.pop(context);
            }
            else if
            (
                ( widget.role == "Citizen_Previous_Ellection" || widget.role == "Party Head" || widget.role == "Party_Head_View" )
                && selectedYear.isNotEmpty && selectedType.isEmpty && selectedState.isNotEmpty && selectedConstituency.isNotEmpty
            )
            {
              print("1 hiii ................");
              widget.onFilterApplied({
                'year': selectedYear,
                'type': selectedType,
                'state': selectedState,
                'constituency': selectedConstituency,
              });
              Navigator.pop(context);
            }
            else if
            (
                selectedYear.isNotEmpty || selectedType.isNotEmpty || selectedState.isNotEmpty ||
                (
                    (widget.role != "Party Head" && widget.role != 'Party_Head_View'  && widget.role != "Candidate"  &&  selectedState != "_PAN India" )
                    && selectedConstituency.isEmpty
                )
                // || (widget.role != "Candidate" && selectedParty.isEmpty)
            )
            {
              print("2 hiii ................");

              widget.onFilterApplied({
                    'year': selectedYear,
                    'type': selectedType,
                    'state': selectedState,
                    'constituency': selectedConstituency,
                    'party': selectedParty
                  });
                  Navigator.pop(context);
            }
            else
            {
              print("11 hiii ................ $selectedYear");
              print("12 hiii ................ $selectedType");
              print("13 hiii ................ $selectedState");
              print("14 hiii ................ $selectedConstituency");
              print("15 hiii ................ $selectedParty");
              print("16 hiii ................ ${widget.role}");

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all required fields to apply filters.')),    );
            }

          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}






// if ( widget.role == 'Party_Head_View' )
// { setState(() { selectedConstituency = AppConstants.constituencies.isNotEmpty ? 'All_Constituencies' : AppConstants.constituencies.first ;  }); }
