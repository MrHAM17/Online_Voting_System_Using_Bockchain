
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart';
import '../../USER/admin/election_details.dart';
import '../utils/app_constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Alias Firebase Firestore
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

// Alias Web3dart

class FirebaseService {
  static Future<void> markVotingStartedInFirebase(String year, String electionName, String state) async {
    try
    {
      String fetchedResultPath = '';
      if
      (electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
      { fetchedResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Admin/Election Activity"; }
      else if
      (electionName == "State Assembly (Vidhan Sabha)" || electionName == "Legislary Council (Vidhan Parishad)" || electionName == "Municipal" || electionName == "Panchayat")
      { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Admin/Election Activity"; }

      // Update the isElectionActive field. If the document or field doesn't exist, they will be created.
      await FirebaseFirestore.instance.doc(fetchedResultPath).set(
        {"isElectionActive": true},
        SetOptions(merge: true),
      );
    }
    catch (e) {  print("Error updating election status in Firebase: $e");  }
  }
}

class SmartContractService {
  final String _rpcUrl = AppConstants.rpcUrl_string;
  // final String _privateKey = AppConstants.privateKey_string;


  // String? _privateKey; // Make it a class variable
  // String? _privateKey = ElectionDetails.instance.privateKeyMetaMask;
  // final String? privateKey;
  // final String? privateKey = ElectionDetails.instance.privateKeyMetaMask;
  String? privateKey = ElectionDetails.instance.privateKeyMetaMask;

  // late web3dart.Web3Client _client; // Use web3dart alias
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  // late DeployedContract _contract;
  DeployedContract? _contract; // Allow nullable to handle late initialization
  web3dart.Web3Client? _client; // Nullable _client

  SmartContractService() {
    // _client = web3dart.Web3Client(_rpcUrl,http.Client(), );

    // _privateKey = ElectionDetails.instance.privateKeyMetaMask;
    // print("private Key Meta Mask SingleTon : ${ElectionDetails.instance.privateKeyMetaMask}");
    // if (_privateKey == null || _privateKey!.isEmpty) {
    //   print("private Key Meta Mask : $_privateKey");
    //   throw Exception("Admin private key is missing.");
    // }

    // String? privateKey = ElectionDetails.instance.privateKeyMetaMask;
    print("private Key Meta Mask SingleTon : $privateKey");
    _credentials = EthPrivateKey.fromHex(privateKey!);
    // _credentials = EthPrivateKey.fromHex(ElectionDetails.instance.privateKeyMetaMask);
    _contractAddress = EthereumAddress.fromHex(AppConstants.contractAddress_string);       // Initialize the contract address here

    // print('**** 11 client: $_client');  // Debugging step: Check if ABI is loaded
    // print('**** 11 credentials: $_credentials');  // Debugging step: Check if ABI is loaded
  }

  // Lazy initialization for _client
  Future<web3dart.Web3Client> getClient() async {
    if (_client != null) return _client!;
    try
    {
      if (_client == null)
      {
        _client = web3dart.Web3Client(_rpcUrl, http.Client(),   // Improve stability
        );
        // print('Web3Client initialized: $_client');
        return _client!;
      }
    }
    catch (e)
    {
      print("Error loading client: $e");
      print('*** client: $_client');  // Debugging step: Check if ABI is loaded
    }
    throw Exception("Failed to load client"); // Ensure function always returns a value
  }
  Future<DeployedContract> loadContract() async {
    if (_client == null) getClient();
    if (_contract != null) return _contract!; // Return already loaded contract
    try {
      String abi = await rootBundle.loadString('assets/contract_abi.json');
      // _contractAddress = EthereumAddress.fromHex(AppConstants.contractAddress_string);
      // print('**** ABI Loaded: $abi');  // Debugging step: Check if ABI is loaded
      // print('**** contractAddress: $_contractAddress');  // Debugging step: Check if ABI is loaded

      _contract = DeployedContract(
        ContractAbi.fromJson(abi, 'VoteChain'),
        _contractAddress,
      );
      // print('**** 22 contract: $_contract');  // Debugging step: Check if ABI is loaded

      return _contract!;

    }
    catch (e)
    {
      print("22 Error loading contract: $e");
      print('**** 22 contract: $_contract');  // Debugging step: Check if ABI is loaded
    }
    throw Exception("Failed to load contract"); // Ensure function always returns a value
  }

  /// ✅✅✅ Refactored Code with Reusable Function
  Future<void> processTransaction( String functionName, String year, String electionName, String state, String firebaseStatusUpdateKey, String firebaseStatusUpdateValue) async
  {
    if (_contract == null) { await loadContract();  }          // Ensure _contract is initialized
    try
    {
      final function = _contract!.function(functionName);

      // ✅ Create transaction object
      final transaction = web3dart.Transaction.callContract(
        contract: _contract!,
        function: function,
        parameters: [BigInt.from(int.parse(year)), electionName, state],
        // parameters: [BigInt.from(int.parse(year)), electionName, state],
        // parameters: [year, electionName, state],        // FAILS && NOT WORKS FOR INT/BigInt VIA FUN SIGNATURE
      );

      // ✅ Estimate gas
      final estimatedGas = await _client!.estimateGas(
        sender: await _credentials.extractAddress(),
        to: _contract!.address,
        data: transaction.data,
      );

      print("🔹 Estimated Gas: $estimatedGas");
      // Adjust gas limit with a buffer
      final adjustedGas = estimatedGas.toInt() + 50000;

      // ✅ Create new transaction object with adjusted gas
      final adjustedTransaction = web3dart.Transaction.callContract(
        contract: _contract!,
        function: function,
        parameters: [BigInt.from(int.parse(year)), electionName, state],
        // parameters: [BigInt.from(int.parse(year)), electionName, state],
        // parameters: [year, electionName, state],        // FAILS && NOT WORKS FOR INT/BigInt VIA FUN SIGNATURE
        maxGas: adjustedGas,
      );

      // ✅ Sign the transaction manually (Sepolia testnet chain ID: 11155111)
      final signedTx = await _client!.signTransaction(
        _credentials,
        adjustedTransaction,
        chainId: 11155111,
      );

      // ✅ Send the signed transaction
      final txHash = await _client!.sendRawTransaction(signedTx);
      print("🚀 Transaction sent! Hash: $txHash");

      // ✅ Determine Firebase path
      String fetchedResultPath = '';
      if
      ( electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
      {  fetchedResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Admin/Election Activity";  }
      else if
      ( electionName == "State Assembly (Vidhan Sabha)" || electionName == "Legislary Council (Vidhan Parishad)" || electionName == "Municipal" || electionName == "Panchayat")
      { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Admin/Election Activity"; }

      // ✅ Update Firebase
      await FirebaseFirestore.instance
          .doc(fetchedResultPath)
          .update({ firebaseStatusUpdateKey: firebaseStatusUpdateValue });

    }
    catch (e) {
      print("Error in $functionName: $e");
      print('Client: $_client');
      print('Credentials: $_credentials');
      print('Contract Address: $_contractAddress');
      print('Contract: $_contract');

      print("\n\n*****************");
      print(await _client!.getNetworkId());  // Should print `11155111`
      print("Using RPC URL: $_rpcUrl");
      EthereumAddress sender = await _credentials.extractAddress();
      print("Sender Address: $sender");
    }
  }

  /// ✅✅✅ A helper function to fetch the status from the contract
  Future<String> fetchStatusFromContract(String functionName, String year, String electionName, String state) async
  {
    // Ensure the contract is loaded before calling
    if (_contract == null) { await loadContract(); }
    try {
      final function = _contract!.function(functionName);

      // ✅ Print input values before calling contract
      print("📌 Fetching Status for: Year = $year, Election = $electionName, State = $state");

      // ✅ Convert 'year' to BigInt
      final BigInt parsedYear = BigInt.from(int.parse(year));

      // Call the contract function
      List<dynamic> result = await _client!.call(
        contract: _contract!,
        function: function,
        params: [parsedYear, electionName, state],
      );

      // ✅ Debug output
      print("🟢 Contract Response for --> $functionName: $result");

      // Process the result
      BigInt getStatus = result[0] as BigInt;
      String status = '';

      // Separate conditions for each status
      if (getStatus == BigInt.zero)
      {
        status = "NOT_STARTED" ;
        print("🟢 Contract Response for --> $functionName: $status");
        return status;
      } // 0 means NOT_STARTED
      else if
      (getStatus == BigInt.one)
      {
        status = "STARTED" ;
        print("🟢 Contract Response for --> $functionName: $status");
        return status;
      } // 1 means STARTED
      else if
      (getStatus == BigInt.two)
      {
        status = "STOPPED" ;
        print("🟢 Contract Response for --> $functionName: $status");
        return status;
      }  // 2 means STOPPED
      else
      {
        print("⚠️ Unexpected contract response for --> $functionName: $result");
        return "Unknown Status";
      }
    }
    catch (e)
    {
      print("❌ Error fetching status of $functionName: $e");
      return "Error";
    }
  }



  /// Function to start election
  Future<void> startElection( String year, String electionName, String state) async {

    // print('**** 33.1 client: $_client');  // Debugging step: Check if ABI is loaded
    // print('**** 33 credentials: $_credentials');  // Debugging step: Check if ABI is loaded
    // print('**** 33 contractAddress: $_contractAddress');  // Debugging step: Check if ABI is loaded
    // print('hi');
    // print('**** 33 contract: $_contract');  // Debugging step: Check if ABI is loaded
    // print('hello');

    await processTransaction('startElection', year, electionName, state, "isElectionCreated","true");

    // print('**** 33.2 client: $_client');  // Debugging step: Check if ABI is loaded
    // print('**** 33 credentials: $_credentials');  // Debugging step: Check if ABI is loaded
    // print('**** 33 contractAddress: $_contractAddress');  // Debugging step: Check if ABI is loaded
    // print('hi');
    // print('**** 33 contract: $_contract');  // Debugging step: Check if ABI is loaded
    // print('hello');

    ///
    // try {
    //   // final function = _contract.function('startElection');
    //   final function = _contract!.function('startElection');
    //
    //   // await _client!.sendTransaction(
    //   //   _credentials,
    //   //   web3dart.Transaction.callContract(
    //   //     contract: _contract!,
    //   //     function: function,
    //   //     parameters: [BigInt.parse(year), electionName, state],
    //   //   ),
    //   // );
    //
    //   final BigInt parsedYear = BigInt.from(int.parse(year)); // Convert String to BigInt
    //
    //   // ✅ Create transaction object first
    //   final transaction = web3dart.Transaction.callContract(
    //     contract: _contract!,
    //     function: function,
    //     parameters: [parsedYear, electionName, state],
    //     // parameters: [BigInt.from(int.parse(year)), electionName, state],
    //     // parameters: [year, electionName, state],             // FAILS && NOT WORKS FOR INT/BigInt VIA FUN SIGNATURE
    //   );
    //
    //   // ✅ Estimate gas
    //   final estimatedGas = await _client!.estimateGas(
    //     sender: await _credentials.extractAddress(),
    //     to: _contract!.address,
    //     data: transaction.data,
    //   );
    //
    //   print("🔹 Estimated Gas: $estimatedGas");
    //
    //   // Use the estimated gas + some buffer
    //   final adjustedGas = estimatedGas.toInt() + 50000;
    //
    //   // ✅ Create a new transaction object with adjusted gas
    //   final adjustedTransaction = web3dart.Transaction.callContract(
    //     contract: _contract!,
    //     function: function,
    //     parameters: [BigInt.parse(year), electionName, state],
    //     // parameters: [BigInt.from(int.parse(year)), electionName, state],
    //     // parameters: [year, electionName, state],        // FAILS && NOT WORKS FOR INT/BigInt VIA FUN SIGNATURE
    //     maxGas: adjustedGas, // Adjusted dynamically
    //   );
    //
    //   // ✅ Manually sign the transaction with Sepolia Chain ID (11155111)
    //   final signedTx = await _client!.signTransaction(
    //     _credentials,
    //     adjustedTransaction,
    //     chainId: 11155111, // 🔥 Fix the invalid sender issue
    //   );
    //
    //   // ✅ Send the raw signed transaction
    //   final txHash = await _client!.sendRawTransaction(signedTx);
    //   print("🚀 Transaction sent! Hash: $txHash");
    //   // print("Stored Year: ${result.first}");
    //   print("Encoded Transaction Data: ${transaction.data}");
    //
    //
    //   String fetchedResultPath = '';
    //   if (electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
    //   {  fetchedResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Admin/Election Activity";  }
    //   else if (electionName == "State Assembly (Vidhan Sabha)" || electionName == "Legislary Council (Vidhan Parishad)" || electionName == "Municipal" || electionName == "Panchayat")
    //   { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Admin/Election Activity"; }
    //
    //   // ✅ Update Firebase
    //   await FirebaseFirestore.instance
    //       .doc(fetchedResultPath)
    //       .update({"isElectionCreated": true});
    // }
    // catch (e) {
    //   // print('**** 33 client: $_client');  // Debugging step: Check if ABI is loaded
    //   // print('**** 33 credentials: $_credentials');  // Debugging step: Check if ABI is loaded
    //   // print('**** 33 contractAddress: $_contractAddress');  // Debugging step: Check if ABI is loaded
    //   // print('hi');
    //   // print('**** 33 contract: $_contract');  // Debugging step: Check if ABI is loaded
    //   // print('hello');
    //   //
    //   // print("\n\n*****************");  // Should print `11155111`
    //   print(await _client!.getNetworkId());  // Should print `11155111`
    //   print("Error starting election: $e");
    //
    //   print("Using RPC URL: $_rpcUrl");
    //   EthereumAddress sender = await _credentials.extractAddress();
    //   print("Sender Address: $sender");
    // }
  }

  // Function to stop election (Admin Only)
  // Future<void> stopElection(String year, String electionName, String state) async
  // {
  //   try {
  //     final function = _contract!.function('stopElection');
  //     await _client!.sendTransaction(
  //       _credentials,
  //       web3dart.Transaction.callContract(
  //         contract: _contract!,
  //         function: function,
  //         parameters: [BigInt.parse(year), electionName, state],
  //       ),
  //     );
  //
  //     String fetchedResultPath = '';
  //     if (electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
  //     { fetchedResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Admin/Election Activity"; }
  //     else if
  //     (electionName == "State Assembly (Vidhan Sabha)" || electionName == "Legislary Council (Vidhan Parishad)" || electionName == "Municipal" || electionName == "Panchayat")
  //     { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Admin/Election Activity"; }
  //
  //     // ✅ Update Firebase
  //     await FirebaseFirestore.instance
  //         .doc(fetchedResultPath)
  //         .update({"isElectionActive": false});
  //   }
  //   catch (e)
  //   {
  //     print("Error stopping election: $e");
  //   }
  // }
  Future<void> stopElection(String year, String electionName, String state) async
  { await processTransaction('stopElection', year, electionName, state, "isElectionActive","false"); }

  // Function to check election status
  Future<String> checkElectionStatus(String year, String electionName, String state) async
  { return await fetchStatusFromContract('getElectionStatus', year, electionName, state); }



  /// Function to start party application
  Future<void> startPartyApplication(String year, String electionName, String state) async
  { await processTransaction('startPartyApplications', year, electionName, state, "partyApplicationStatus","STARTED"); }

  // Function to stop party application
  Future<void> stopPartyApplication(String year, String electionName, String state) async
  { await processTransaction('stopPartyApplications', year, electionName, state, "partyApplicationStatus","STOPPED");  }

  // Function to check party application status
  Future<String> checkPartyApplicationStatus(String year, String electionName, String state) async
  {
    return await fetchStatusFromContract('getPartyApplicationStatus', year, electionName, state);
    // if (_contract == null) { await loadContract(); }   // Ensure _contract is initialized
    //
    // try
    // {
    //   final function = _contract!.function('getPartyApplicationStatus');
    //
    //   // ✅ Print input values before calling contract
    //   print("📌 Fetching PartyApplicationStatus for: Year = $year, Election = $electionName, State = $state");
    //
    //   List<dynamic> result = await _client!.call(
    //     contract: _contract!,
    //     function: function,
    //     params: [BigInt.from(int.parse(year)), electionName, state], // Correct parameter name
    //   );
    //
    //   // return result[0] == 0 ? "STOPPED" : "STARTED"; // Assuming 0 means STOPPED, 1 means STARTED
    //   print("🟢 Contract Response: $result");
    //
    //   // Directly access the result assuming it's valid
    //   BigInt getStatus = result[0] as BigInt;
    //   String status = '';
    //
    //   // Separate conditions for each status
    //   if (getStatus == BigInt.zero)
    //   {
    //     status = "NOT_STARTED" ;
    //     print("🟢 Contract Response: $status");
    //     return status;
    //   } // 0 means NOT_STARTED
    //   else if
    //   (getStatus == BigInt.one)
    //   {
    //     status = "STARTED" ;
    //     print("🟢 Contract Response: $status");
    //     return status;
    //   } // 1 means STARTED
    //   else if
    //   (getStatus == BigInt.two)
    //   {
    //     status = "STOPPED" ;
    //     print("🟢 Contract Response: $status");
    //     return status;
    //   }  // 2 means STOPPED
    //   else
    //   {
    //     print("⚠️ Unexpected contract response: $result");
    //     return "Unknown Status";
    //   }
    //
    // }
    // catch (e)
    // {
    //   print("❌ Error fetching party application status: $e");
    //   return "Error";
    // }
  }



  /// Function to start candidate application
  Future<void> startCandidateApplication(String year, String electionName, String state) async
  { await processTransaction('startCandidateApplications', year, electionName, state, "candidateApplicationStatus","STARTED"); }

  // Function to stop candidate application
  Future<void> stopCandidateApplication(String year, String electionName, String state) async
  { await processTransaction('stopCandidateApplications', year, electionName, state, "candidateApplicationStatus","STOPPED"); }

  // Function to check candidate application status
  Future<String> checkCandidateApplicationStatus(String year, String electionName, String state) async
  { return await fetchStatusFromContract('getCandidateApplicationStatus', year, electionName, state); }



  // ✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅


  /// Cast a vote (Only when election is active)
  // Future<void> vote(String year, String electionName, String state, String candidateEmail) async {
  //   try {
  //     // // ✅ First, check Firebase before sending transaction
  //     // bool isActive = await FirebaseService.isElectionActive(state, year, electionName);
  //     // if (!isActive) {
  //     //   print("Election is stopped. Cannot vote!");
  //     //   return;
  //     // }
  //
  //     // ✅ Proceed with blockchain transaction
  //     final function = _contract!.function('castVote');
  //     await _client!.sendTransaction(
  //       _credentials,
  //       web3dart.Transaction.callContract(contract: _contract!, function: function, parameters: [candidateEmail]), // Use web3dart alias here
  //     );
  //
  //     print("Vote successfully cast for candidate $candidateEmail.");
  //   } catch (e) {
  //     print("Error voting: $e");
  //   }
  // }
  ///  Wrong due to incomplete parameters
  // Future<void> vote(String year, String electionName, String state, String candidateEmail) async {
  //   // Ensure that the contract is loaded
  //   if (_contract == null) {
  //     await loadContract();
  //   }
  //
  //   try {
  //     // Retrieve the 'castVote' function from the contract
  //     final function = _contract!.function('castVote');
  //
  //     // Create a transaction object using the candidateEmail parameter.
  //     final transaction = web3dart.Transaction.callContract(
  //       contract: _contract!,
  //       function: function,
  //       parameters: [candidateEmail],
  //     );
  //
  //     // Estimate gas for the transaction
  //     final estimatedGas = await _client!.estimateGas(
  //       sender: await _credentials.extractAddress(),
  //       to: _contract!.address,
  //       data: transaction.data,
  //     );
  //
  //     print("🔹 Estimated Gas: $estimatedGas");
  //
  //     // Adjust the gas limit by adding a buffer (e.g., 50,000)
  //     final adjustedGas = estimatedGas.toInt() + 50000;
  //
  //     // Create a new transaction object with the adjusted gas limit
  //     final adjustedTransaction = web3dart.Transaction.callContract(
  //       contract: _contract!,
  //       function: function,
  //       parameters: [candidateEmail],
  //       maxGas: adjustedGas,
  //     );
  //
  //     // Manually sign the transaction with the appropriate chain ID (e.g., Sepolia: 11155111)
  //     final signedTx = await _client!.signTransaction(
  //       _credentials,
  //       adjustedTransaction,
  //       chainId: 11155111,
  //     );
  //
  //     // Send the signed (raw) transaction
  //     final txHash = await _client!.sendRawTransaction(signedTx);
  //     print("🚀 Transaction sent! Hash: $txHash");
  //
  //   } catch (e) {
  //     // Detailed error logging for debugging
  //     print("Error in castVote: $e");
  //     print('Client: $_client');
  //     print('Credentials: $_credentials');
  //     print('Contract: $_contract');
  //     print('Contract Address: ${_contract!.address}');
  //     print("Network ID: ${await _client!.getNetworkId()}");
  //     EthereumAddress sender = await _credentials.extractAddress();
  //     print("Sender Address: $sender");
  //   }
  // }

  // Function to fetch and store votes from blockchain to Firebase
  /// working
  // Future<void> vote(String year, String electionName, String state, String candidateEmail) async {
  //   // Ensure that the contract is loaded
  //   if (_contract == null) {
  //     await loadContract();
  //   }
  //
  //   try {
  //     // Retrieve the 'castVote' function from the contract
  //     final function = _contract!.function('castVote');
  //
  //     // Create a transaction object with all required parameters:
  //     final transaction = web3dart.Transaction.callContract(
  //       contract: _contract!,
  //       function: function,
  //       parameters: [
  //         BigInt.from(int.parse(year)),  // year as BigInt
  //         electionName,                   // election type as string
  //         state,                          // state as string
  //         candidateEmail                  // candidate email as string
  //       ],
  //     );
  //
  //     // Estimate gas for the transaction
  //     final estimatedGas = await _client!.estimateGas(
  //       sender: await _credentials.extractAddress(),
  //       to: _contract!.address,
  //       data: transaction.data,
  //     );
  //
  //     print("🔹 Estimated Gas: $estimatedGas");
  //
  //     // Adjust the gas limit by adding a buffer (e.g., 50,000)
  //     final adjustedGas = estimatedGas.toInt() + 50000;
  //
  //     // Create a new transaction object with the adjusted gas limit
  //     final adjustedTransaction = web3dart.Transaction.callContract(
  //       contract: _contract!,
  //       function: function,
  //       parameters: [
  //         BigInt.from(int.parse(year)),
  //         electionName,
  //         state,
  //         candidateEmail
  //       ],
  //       maxGas: adjustedGas,
  //     );
  //
  //     // Manually sign the transaction with the appropriate chain ID (e.g., Sepolia: 11155111)
  //     final signedTx = await _client!.signTransaction(
  //       _credentials,
  //       adjustedTransaction,
  //       chainId: 11155111,
  //     );
  //
  //     // Send the signed (raw) transaction
  //     final txHash = await _client!.sendRawTransaction(signedTx);
  //     print("🚀 Transaction sent! Hash: $txHash");
  //
  //   } catch (e) {
  //     // Detailed error logging for debugging
  //     print("Error in castVote: $e");
  //     print('Client: $_client');
  //     print('Credentials: $_credentials');
  //     print('Contract: $_contract');
  //     print('Contract Address: ${_contract!.address}');
  //     print("Network ID: ${await _client!.getNetworkId()}");
  //     EthereumAddress sender = await _credentials.extractAddress();
  //     print("Sender Address: $sender");
  //   }
  // }
  /// imporoveed
  Future<void> vote(String year, String electionName, String state, String candidateEmail) async
  {
    // Ensure that the contract is loaded
    if (_contract == null) {
      await loadContract();
    }

    try {
      print("🔥🔥🔥  🔥🔥🔥 🔥🔥🔥 .................. ");
      // await syncVotesInFirebase(year, electionName, state);


      // Retrieve the 'castVote' function from the contract
      final function = _contract!.function('castVote');

      // Fetch the sender's address
      final senderAddress = await _credentials.extractAddress();

      // Estimate gas for the transaction
      final estimatedGas = await _client!.estimateGas(
        sender: senderAddress,
        to: _contract!.address,
        data: function.encodeCall([
          BigInt.from(int.parse(year)),
          electionName,
          state,
          candidateEmail,
        ]),
      );

      print("🔹 Estimated Gas: $estimatedGas");

      // Adjust the gas limit by adding a buffer (e.g., 20%)
      final adjustedGas = (estimatedGas.toInt() * 1.2).toInt();

      // Fetch the current gas price from the network
      final currentGasPrice = await _client!.getGasPrice();

      // Adjust the gas price by adding a buffer (e.g., 20%)
      final increasedGasPrice = currentGasPrice.getInWei * BigInt.from(120) ~/ BigInt.from(100);

      // Fetch the current nonce for the sender's address
      final currentNonce = await _client!.getTransactionCount(
        senderAddress,
        atBlock: const web3dart.BlockNum.pending(),
      );

      // Create the transaction object with all required parameters
      final transaction = web3dart.Transaction.callContract(
        contract: _contract!,
        function: function,
        parameters: [
          BigInt.from(int.parse(year)),
          electionName,
          state,
          candidateEmail,
        ],
        gasPrice: EtherAmount.inWei(increasedGasPrice),
        maxGas: adjustedGas,
        nonce: currentNonce,
      );

      // Send the transaction and obtain the transaction hash
      final txHash = await _client!.sendTransaction(
        _credentials,
        transaction,
        chainId: 11155111, // Replace with your network's chain ID
      );

      print("🚀 Transaction sent! Hash: $txHash");

      // Optionally, monitor the transaction status
      final receipt = await _client!.getTransactionReceipt(txHash);
      if (receipt != null && receipt.status!) {
        print('✅ Transaction successful');
      } else {
        print('❌ Transaction failed or still pending');
      }

      // Store the transaction hash and timestamp in Firestore
      await storeTransactionDetails(txHash);
    }
    catch (e)
    {
      // Detailed error logging for debugging
      print('Client: $_client');
      print('Credentials: $_credentials');
      print('Contract: $_contract');
      print('Contract Address: ${_contract!.address}');
      print("Network ID: ${await _client!.getNetworkId()}");
      final sender = await _credentials.extractAddress();
      print("Sender Address: $sender");

      print("Error in castVote: $e");
      throw Exception("Blockchain voting failed: $e"); // Rethrow error
    }
  }

  /// Store Transaction
  // Future<void> storeTransactionDetails(String transactionHash) async {
  //   // Initialize Firestore instance
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //   // Generate timestamp key in "dd_MM_yyyy_HH_mm_ss" format
  //   String timestampKey = DateFormat('dd_MM_yyyy_HH_mm_ss').format(DateTime.now());
  //
  //   DocumentReference transactionsDoc = firestore
  //       .collection("Vote Chain")
  //       .doc("Transactions");
  //
  //   await transactionsDoc.set({
  //     timestampKey: transactionHash
  //   }, SetOptions(merge: true)).catchError((error) {
  //     print("Failed to update transaction hash: $error");
  //   });
  // }
  Future<void> storeTransactionDetails(String transactionHash) async {
    try {
      // Initialize Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Generate timestamp key in "dd_MM_yyyy_HH_mm_ss" format
      String timestampKey = DateFormat('dd_MM_yyyy_HH_mm_ss').format(DateTime.now());

      DocumentReference transactionsDoc = firestore
          .collection("Vote Chain")
          .doc("Transactions");

      // Update instead of set
      await transactionsDoc.update({
        timestampKey: transactionHash
      }).catchError((error) async {
        if (error.code == 'not-found') {
          // Document doesn't exist, create it
          await transactionsDoc.set({
            timestampKey: transactionHash
          }, SetOptions(merge: true));
        } else {
          print("❌ Firestore Update Error: $error");
        }
      });

      print("✅ Transaction stored: $timestampKey → $transactionHash");
    } catch (e) {
      print("❌ Firestore Error: $e");
    }
  }




  /// Sync Votes
  Future<void> syncVotesInFirebase(String year, String electionName, String state) async
  {
    try
    {
      print("🔄 Fetching votes from blockchain for: Year: $year, Election: $electionName, State: $state");

      // Fetch votes from the blockchain using the getVoteCounts function
      final voteCounts = await _getVoteCounts(year, electionName, state);

      // Construct the Firebase path based on the election year, type, and state

      print("✅ Votes fetched: $voteCounts");
      if (voteCounts.isEmpty) {
        print("❌ No votes received from blockchain.");
        return;
      }

      String fetchedResultPath = '';

      if
      (electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
      { fetchedResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Result/Fetched_Result/"; }
      else if
      (electionName == "State Assembly (Vidhan Sabha)" || electionName == "Legislary Council (Vidhan Parishad)" || electionName == "Municipal" || electionName == "Panchayat")
      { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Result/Fetched_Result/"; }

      // Build a nested map for votes.
      // Each candidate's email will be a key under "votes", and its value will be a sub-map containing vote_count.
      Map<String, dynamic> nestedVotesMap = {};

      for (var entry in voteCounts.entries)
      {
        String candidateEmail = entry.key;
        int voteCount = entry.value;

        // Here we add each candidate's vote data.

        if (candidateEmail == "NOTA")
        {
          // Store NOTA votes separately
          nestedVotesMap['_NOTA'] = {'vote_count': voteCount};
        }
        else
        {
          // Add the candidate's vote count to the candidate-sub-map
          nestedVotesMap[candidateEmail] = {'vote_count': voteCount};
        }
      }

      // Prepare the update data with the nested "votes" map.
      Map<String, dynamic> updateData = {'votes': nestedVotesMap};

      // Write the updateData to Firestore at the constructed document path.
      await FirebaseFirestore.instance.doc(fetchedResultPath).set(updateData, SetOptions(merge: true));
      print("🚀 Votes stored successfully in Metadata Map.");

      // store specifically.
      await storeVotesInFirebaseSpecifically(year, electionName, state, voteCounts);
      print("\n🚀🚀🚀 Votes stored successfully in Election Result path.");
    }
    catch (e)
    {
      print("Error storing votes in Firebase: $e");
      throw Exception("Blockchain voting failed: $e"); // Rethrow error
    }
  }

  /// Helper function to fetch vote counts from the blockchain
  // Future<Map<String, int>> _getVoteCounts(  String year, String electionName, String state  ) async
  // {
  //   try
  //   {
  //     // The smart contract's address
  //     final contractAddress = EthereumAddress.fromHex(AppConstants.contractAddress_string);
  //
  //     // Define the ABI of the contract
  //     final abi = '''[
  //       {
  //         "constant": true,
  //         "inputs": [
  //           { "name": "year", "type": "uint256" },
  //           { "name": "electionType", "type": "string" },
  //           { "name": "state", "type": "string" }
  //         ],
  //         "name": "getAllVotes",
  //         "outputs": [
  //           { "name": "emails", "type": "string[]" },
  //           { "name": "voteCounts", "type": "uint256[]" }
  //         ],
  //         "payable": false,
  //         "stateMutability": "view",
  //         "type": "function"
  //       }
  //     ]''';
  //
  //     final contract = DeployedContract(
  //       ContractAbi.fromJson(abi, 'Voting'),
  //       contractAddress,
  //     );
  //
  //     // Calling the getAllVotes function
  //     final getVotesFunction = contract.function('getAllVotes');
  //     final result = await _client!.call(
  //       contract: contract,
  //       function: getVotesFunction,
  //       params: [BigInt.from(int.parse(year)), electionName, state],
  //     );
  //
  //     // Map to store the result
  //     Map<String, int> voteCounts = {};
  //
  //     // Iterate through the result and populate the map
  //     final List<dynamic> emails = result[0];
  //     final List<dynamic> counts = result[1];
  //
  //     for (int i = 0; i < emails.length; i++) {
  //       final candidateEmail = emails[i] as String;
  //       final voteCount = counts[i] as BigInt;
  //
  //       // Store the vote count in the map
  //       voteCounts[candidateEmail] = voteCount.toInt();
  //     }
  //
  //     return voteCounts;
  //   }
  //   catch (e)
  //   {
  //     print("Error fetching vote counts from blockchain: $e");
  //     return {};
  //   }
  // }
  /// no error but no sync
  // Future<Map<String, int>> _getVoteCounts(String year, String electionName, String state) async {
  //   try {
  //     // Ensure that the client is loaded
  //     if (_client == null) {
  //       await getClient();
  //     }
  //
  //     // Ensure that the contract is loaded
  //     if (_contract == null) {
  //       await loadContract();
  //     }
  //
  //     // Convert the year string to BigInt once
  //     final BigInt yearBigInt = BigInt.from(int.parse(year));
  //
  //     // Use the loaded contract's getAllVotes function
  //     final getVotesFunction = _contract!.function('getAllVotes');
  //
  //     // Call the function on the blockchain
  //     final result = await _client!.call(
  //       contract: _contract!,
  //       function: getVotesFunction,
  //       params: [yearBigInt, electionName, state],
  //     );
  //
  //     // Check that result has the expected structure
  //     if (result.isEmpty || result.length < 2) {
  //       print("❌Error: Received an unexpected result structure from the blockchain.");
  //       return {};
  //     }
  //
  //     // Safely extract emails and counts from the result
  //     final List<dynamic>? emailsDynamic = result[0] as List<dynamic>?;
  //     final List<dynamic>? countsDynamic = result[1] as List<dynamic>?;
  //
  //     if (emailsDynamic == null || countsDynamic == null) {
  //       print("❌Error: Received null for emails or vote counts.");
  //       return {};
  //     }
  //
  //     if (emailsDynamic.length != countsDynamic.length) {
  //       print("❌Error: Mismatch between emails and vote counts lengths.");
  //       return {};
  //     }
  //
  //     // Build and return the map of candidate emails to vote counts
  //     Map<String, int> voteCounts = {};
  //     for (int i = 0; i < emailsDynamic.length; i++) {
  //       final String? candidateEmail = emailsDynamic[i] as String?;
  //       final BigInt? voteCount = countsDynamic[i] as BigInt?;
  //       if (candidateEmail != null && voteCount != null) {
  //         voteCounts[candidateEmail] = voteCount.toInt(); // Zero votes will be 0
  //       } else {
  //         print("❌Warning: Null value encountered at index $i");
  //       }
  //     }
  //     return voteCounts;
  //   } catch (e) {
  //     print("❌Error fetching vote counts from blockchain: $e");
  //     return {};
  //   }
  // }
  /// improved
  Future<Map<String, int>> _getVoteCounts(String year, String electionName, String state) async {

    if (_contract == null) {
      print("⚠️ Contract not loaded. Loading now...");
      await loadContract();
      if (_contract == null) {
        print("❌ Contract loading failed!");
        return {};
      }
    }

    try {
      final function = _contract!.function('getAllVotes');

      // Sanitize the electionName and state before using them.
      // final sanitizedElectionName = sanitize(electionName);
      // final sanitizedState = sanitize(state);
      // final storedElectionName = "\u001dState Assembly (Vidhan Sabha)";

      // print("📡 Calling getAllVotes with -> Year: '$year', Election: '$sanitizedElectionName', State: '$sanitizedState'");
      print("📡 Calling getAllVotes with -> Year: '$year', Election: '$electionName', State: '$state'");
      // print("📡 Calling getAllVotes with -> Year: '$year', Election: 'State', State: '$state'");

      // Validate if year is an integer
      if (!RegExp(r'^\d+$').hasMatch(year)) {
        print("❌ ERROR: Year '$year' is not a valid integer!");
        return {};
      }

      final result = await _client!.call(
        contract: _contract!,
        function: function,
        params: [
          BigInt.from(int.parse(year)),
          electionName,
          // storedElectionName,
          state,
        ],
      );

      print("📡 Raw blockchain response: $result");

      if (result.isEmpty || result[0] is! List || result[1] is! List) {
        print("❌ ERROR: Unexpected response format from blockchain: $result");
        return {};
      }

      List<dynamic> candidateEmails = result[0];
      List<dynamic> voteCounts = result[1];

      if (candidateEmails.isEmpty) {
        print("❌ No candidates found in blockchain response!");
        // return {};
      }

      // Check if voteCounts contains non-numeric values
      for (var i = 0; i < voteCounts.length; i++) {
        if (voteCounts[i] is! BigInt) {
          print("❌ ERROR: Non-numeric value detected in voteCounts: $voteCounts[i]");
          // return {};
        }
      }

      Map<String, int> voteMap = {};
      for (int i = 0; i < candidateEmails.length; i++) {
        voteMap[candidateEmails[i]] = voteCounts[i].toInt();
      }

      print("✅ Parsed vote data: $voteMap");
      return voteMap;
    } catch (e) {
      print("❌ Error fetching votes from blockchain: $e");
      return {};
    }
  }
  // String sanitize(String input) {
  //   // Remove control characters (ASCII 0x00 to 0x1F) and trim whitespace
  //   return input.replaceAll(RegExp(r'[\x00-\x1F]'), '').trim();
  // }

  /// Store votes specifically (in election result path) apart from Metadata Map
  Future<void> storeVotesInFirebaseSpecifically( String year, String electionName, String state, Map<String, int> voteCounts,) async
  {
    try
    {

      // Construct the Firebase path to fetch constituency, party, and candidate details from already Fetched data from the blockchain & stored temporarily here.
      String fetchedResultPath = '';

      if
      (electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
      { fetchedResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Result/Fetched_Result/";  }
      else if
      (electionName == "State Assembly (Vidhan Sabha)" || electionName == "Legislary Council (Vidhan Parishad)" || electionName == "Municipal" || electionName == "Panchayat")
      { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Result/Fetched_Result/"; }

      // Fetch candidate metadata from the Fetched_Result document.
      DocumentSnapshot<Map<String, dynamic>> fetchedResultSnapshot =
      await FirebaseFirestore.instance.doc(fetchedResultPath).get();

      if (!fetchedResultSnapshot.exists) {
        print("No vote data found in fetched result path.");
        return;
      }

      Map<String, dynamic>? fetchedData = fetchedResultSnapshot.data();
      if (fetchedData == null) {
        print("Fetched result data is empty.");
        return;
      }

      // The candidate metadata should be stored under the "votes" key.
      if (!fetchedData.containsKey("votes")) {
        print("No candidate metadata found under 'votes' in fetched data.");
        return;
      }

      var candidatesData = fetchedData["votes"];
      if (candidatesData is! Map<String, dynamic>) {
        print("Candidate metadata is not in the expected map format.");
        return;
      }

      // Iterate over the voteCounts map and update each candidate's Election_Result document.
      for (var entry in voteCounts.entries)
      {
        String candidateEmail = entry.key;
        int voteCount = entry.value;

        // Skip if candidateEmail is "NOTA" (we handle NOTA votes separately by Metadata map)
        if (candidateEmail == "NOTA")
        {
          print("Skipping candidate $candidateEmail - NOTA votes handled separately.");
          print("Skipping NOTA vote count here, as NOTA votes are stored in Metadata.");
          continue;
        }

        // Check if candidate details exist in the nested "votes" map.
        if (!candidatesData.containsKey(candidateEmail)) {
          print("No candidate details found for $candidateEmail in fetched data.");
          continue;
        }

        var candidateData = candidatesData[candidateEmail];
        if (candidateData is! Map<String, dynamic>) {
          print("Candidate details for $candidateEmail are not in the expected format.");
          continue;
        }

        // Ensure candidateData has "party" and "constituency".
        if (!candidateData.containsKey("party") || !candidateData.containsKey("constituency")) {
          print("Skipping candidate $candidateEmail - Missing 'party' or 'constituency' in metadata.");
          continue;
        }

        // Find candidate details (constituency & party)
        String partyName = candidateData["party"];
        String constituency = candidateData["constituency"];

        // Construct the dynamic Firebase path for the Election_Result document.
        String electionResultPath = '';
        if
        (electionName == "General (Lok Sabha)" || electionName == "Council of States (Rajya Sabha)")
        { electionResultPath = "Vote Chain/Election/$year/$electionName/State/$state/Result/Election_Result/$constituency/$partyName/"; }
        else
        {electionResultPath = "Vote Chain/State/$state/Election/$year/$electionName/Result/Election_Result/$constituency/$partyName/"; }

        // Update the candidate's vote count in that document.
        await FirebaseFirestore.instance.doc(electionResultPath).set({
          'candidate_email': candidateEmail,
          'vote_count': voteCount,
        }, SetOptions(merge: true));

        print("Stored votes for $candidateEmail in constituency $constituency under party $partyName.");
      }
    }
    catch (e)
    { print("Error storing votes in Firebase: $e"); }
  }




  /// Function to check Voting stop status (voting started status is managed by election started status which is mainly use as a status for election created for applications...)

}
