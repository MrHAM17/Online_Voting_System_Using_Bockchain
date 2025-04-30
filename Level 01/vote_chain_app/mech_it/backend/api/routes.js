const express = require("express");
const { castVote, getResults } = require("../services/blockchain");
const { addVoter, verifyVoter } = require("../services/firebase");

const router = express.Router();

// Register voter
router.post("/register", async (req, res) => {
  try {
    const { voterId, name } = req.body;
    await addVoter(voterId, name);
    res.status(201).send({ message: "Voter registered successfully!" });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// Cast vote
router.post("/vote", async (req, res) => {
  try {
    const { voterId, candidateId } = req.body;
    const result = await castVote(voterId, candidateId);
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// Get results
router.get("/results", async (req, res) => {
  try {
    const results = await getResults();
    res.status(200).send(results);
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

module.exports = router;
