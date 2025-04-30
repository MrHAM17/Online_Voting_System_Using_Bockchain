const admin = require("firebase-admin");
require("dotenv").config();

admin.initializeApp({
  credential: admin.credential.cert(require("./firebase_config.json")),
});

const db = admin.firestore();

// Add voter
const addVoter = async (voterId, name) => {
  await db.collection("voters").doc(voterId).set({ name, hasVoted: false });
};

// Verify voter
const verifyVoter = async (voterId) => {
  const voter = await db.collection("voters").doc(voterId).get();
  if (!voter.exists) throw new Error("Voter not found!");
  return voter.data();
};

module.exports = { addVoter, verifyVoter };
