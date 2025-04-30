import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {


  // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
  // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
  // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************

  final String _rpcUrl = "https://snowy-wandering-sponge.ethereum-sepolia.quiknode.pro/xxxxxxxxxxxxxxxxxx"; // Add your QuickNode URL


  // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
  // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
  // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************

  final String _contractAddress = "0x00xxxxxxxxxxxxxxxxxxxxx"; // Add your Deployed contract address
  final Client httpClient = Client();
  late Web3Client ethClient;

  BlockchainService() {
    ethClient = Web3Client(_rpcUrl, httpClient);
  }

  // Call a function on the contract and fetch data
  Future<List<dynamic>> callFunction(String functionName, List<dynamic> params) async {
    final contract = DeployedContract(
      ContractAbi.fromJson('<./backend/ElectionABI.json>', 'Election'), // Replace with actual ABI file path
      EthereumAddress.fromHex(_contractAddress),
    );
    final function = contract.function(functionName);

    try {
      final result = await ethClient.call(
        contract: contract,
        function: function,
        params: params,
      );
      return result;
    } catch (e) {
      throw 'Error calling contract function: $e';
    }
  }

  // Send a transaction to the blockchain
  Future<String> sendTransaction(String functionName, List<dynamic> params, String privateKey) async {
    final credentials = await ethClient.credentialsFromPrivateKey(privateKey);
    final contract = DeployedContract(
      ContractAbi.fromJson('<./backend/ElectionABI.json>', 'Election'), // Replace with actual ABI file path
      EthereumAddress.fromHex(_contractAddress),
    );
    final function = contract.function(functionName);

    try {
      final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: function,
          parameters: params,
          maxGas: 100000,
        ),
        chainId: 5, // Use the appropriate chain ID (e.g., 5 for Goerli, 11155111 for Sepolia)
      );
      return result;
    } catch (e) {
      throw 'Error sending transaction: $e';
    }
  }

  // Create a new election on the blockchain
  Future<String> createElectionOnBlockchain(Map<String, dynamic> electionData) async {
    try {
      // Example of using the `sendTransaction` method to create an election on the blockchain

      // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
      // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
      // *******************  ********************** ***************** **************** *****************    ********************** ***************** **************** *****************
      String privateKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // Add your key & Securely store this in production
      List<dynamic> params = [
        electionData['electionName'],
        electionData['candidates'],
        electionData['startDate'],
        electionData['endDate']
      ];

      String txHash = await sendTransaction('createElection', params, privateKey);
      return txHash;
    } catch (e) {
      throw 'Error creating election on blockchain: $e';
    }
  }

  // Fetch election results from the blockchain
  Future<Map<String, dynamic>> getElectionResults(String electionId) async {
    try {
      List<dynamic> result = await callFunction('getElectionResults', [electionId]);

      // Simulating data format from blockchain
      return {
        'electionId': electionId,
        'results': {
          'partyA': result[0],
          'partyB': result[1],
        },
      };
    } catch (e) {
      throw 'Error fetching election results from blockchain: $e';
    }
  }

  Future<void> deleteElectionFromBlockchain(String electionId) async {
    try {
      // Logic to mark the election as deleted on the blockchain
      // Example: Interact with the smart contract using web3dart or HTTP calls
      print("Election with ID $electionId marked as deleted on blockchain");
    } catch (e) {
      throw 'Error deleting election from blockchain: $e';
    }
  }

}
