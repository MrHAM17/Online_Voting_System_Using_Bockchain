// import 'package:http/src/client.dart';
// import 'package:mech_it/utils/app_constants.dart';
// import 'package:web3dart/web3dart.dart';
// import 'dart:convert';
// import 'dart:io';
//
// class SmartContractService {
//   final String _rpcUrl = AppConstants.rpcUrl_string;
//   final String _privateKey = AppConstants.privateKey_string;
//
//   late Web3Client _client;
//   late EthereumAddress _contractAddress;
//   late Credentials _credentials;
//   late DeployedContract _contract;
//
//   SmartContractService() {
//     _client = Web3Client(_rpcUrl, HttpClient() as Client);
//     _credentials = EthPrivateKey.fromHex(_privateKey);
//   }
//
//   Future Apply[ (reg) & no login ]<void> loadContract() async {
//     String abi = await File('assets/contract_abi.json').readAsString();
//     _contractAddress = EthereumAddress.fromHex(AppConstants.contractAddress_string);
//     _contract = DeployedContract(
//       ContractAbi.fromJson(abi, 'VoteChain'),
//       _contractAddress,
//     );
//   }
//
//   Future Apply[ (reg) & no login ]<void> castVote(int candidateId) async {
//     final voteFunction = _contract.function('castVote');
//     await _client.sendTransaction(
//       _credentials,
//       Transaction.callContract(
//         contract: _contract,
//         function: voteFunction,
//         parameters: [BigInt.from(candidateId)],
//       ),
//     );
//   }
//
//   Future Apply[ (reg) & no login ]<List<dynamic>> getResults() async {
//     final resultsFunction = _contract.function('getResults');
//     return await _client.call(
//       contract: _contract,
//       function: resultsFunction,
//       params: [],
//     );
//   }
// }

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../utils/app_constants.dart';

class SmartContractService {
  final String _rpcUrl = AppConstants.rpcUrl_string;
  final String _privateKey = AppConstants.privateKey_string;

  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  late DeployedContract _contract;

  SmartContractService() {
    _client = Web3Client(_rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> loadContract() async {
    try {
      String abi = await rootBundle.loadString('assets/contract_abi.json');
      _contractAddress = EthereumAddress.fromHex(AppConstants.contractAddress_string);
      _contract = DeployedContract(
        ContractAbi.fromJson(abi, 'Voting'),
        _contractAddress,
      );
    } catch (e) {
      print("Error loading contract: $e");
    }
  }

  Future<void> addCandidate(String name) async {
    try {
      final function = _contract.function('addCandidate');
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [name],
        ),
      );
    } catch (e) {
      print("Error adding candidate: $e");
    }
  }

  Future<void> vote(int candidateId) async {
    try {
      final function = _contract.function('vote');
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [BigInt.from(candidateId)],
        ),
      );
    } catch (e) {
      print("Error voting: $e");
    }
  }

  Future<List<dynamic>> getCandidates() async {
    try {
      final function = _contract.function('getCandidates');
      return await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );
    } catch (e) {
      print("Error getting candidates: $e");
      return [];
    }
  }

  Future<int> getVoteCount(int candidateIndex) async {
    try {
      final function = _contract.function('getVoteCount');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [BigInt.from(candidateIndex)],
      );
      return (result[0] as BigInt).toInt();
    } catch (e) {
      print("Error getting vote count: $e");
      return 0;
    }
  }

  Future<bool> hasVoted(String userAddress) async {
    try {
      final function = _contract.function('hasVoted');
      final address = EthereumAddress.fromHex(userAddress);
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [address],
      );
      return result[0] as bool;
    } catch (e) {
      print("Error checking if user has voted: $e");
      return false;
    }
  }
}
