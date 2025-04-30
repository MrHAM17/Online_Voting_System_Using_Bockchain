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


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Correct import for http.Client
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'dart:io';

import '../utils/app_constants.dart';

class SmartContractService {
  final String _rpcUrl = AppConstants.rpcUrl_string;
  final String _privateKey = AppConstants.privateKey_string;

  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  late DeployedContract _contract;

  SmartContractService() {
    _client = Web3Client(_rpcUrl, http.Client()); // Correct Client type here
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> loadContract() async {
    String abi = await File('assets/contract_abi.json').readAsString();
    _contractAddress = EthereumAddress.fromHex(AppConstants.contractAddress_string);
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, 'VoteChain'),
      _contractAddress,
    );
  }

  Future<void> castVote(int candidateId) async {
    final voteFunction = _contract.function('castVote');
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: voteFunction,
        parameters: [BigInt.from(candidateId)],
      ),
    );
  }

  Future<List<dynamic>> getResults() async {
    final resultsFunction = _contract.function('getResults');
    return await _client.call(
      contract: _contract,
      function: resultsFunction,
      params: [],
    );
  }
}
