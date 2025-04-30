import 'package:flutter/material.dart';
import '../services/blockchain_service.dart';

class VoteScreen extends StatelessWidget {
  final String electionName;
  VoteScreen({required this.electionName});

  final List<String> candidates = ["Candidate A", "Candidate B", "Candidate C"];

  @override
  Widget build(BuildContext context) {
    final BlockchainService blockchainService = BlockchainService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Vote for $electionName'),
      ),
      body: ListView.builder(
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(candidates[index]),
            trailing: ElevatedButton(
              onPressed: () async {
                // Here you send the vote to the blockchain
                String privateKey = "<UserPrivateKey>"; // Fetch this securely from the user
                await blockchainService.sendTransaction(
                  'voteFunctionName', // Replace with actual smart contract function name
                  [candidates[index]], // Parameters (e.g., candidate name)
                  privateKey,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voted for ${candidates[index]}')),
                );
              },
              child: Text('Vote'),
            ),
          );
        },
      ),
    );
  }
}
