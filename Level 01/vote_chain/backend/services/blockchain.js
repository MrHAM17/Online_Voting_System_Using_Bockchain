const Web3 = require("web3");
const fs = require("fs");
require("dotenv").config();



const web3 = new Web3(new Web3.providers.HttpProvider("http://000.0.0.0:0000"));   /// ADD YOUR ADDRESS **********************




const contractABI = JSON.parse(fs.readFileSync("./ElectionABI.json", "utf-8"));
const contractAddress = process.env.CONTRACT_ADDRESS;
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Cast a vote
const castVote = async (voterId, candidateId) => {
  const accounts = await web3.eth.getAccounts();
  await contract.methods.vote(candidateId).send({ from: accounts[0] });
  return { message: "Vote cast successfully!" };
};

// Get results
const getResults = async () => {
  const results = await contract.methods.getResults().call();
  return { candidates: results };
};

module.exports = { castVote, getResults };
