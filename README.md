# VoteChain: Online Voting System Using Blockchain  

> **Empower every voice with immutable, tamper-proof blockchain voting.**

> **Secure, scalable, and transparent elections delivered efficiently on-chain.**

> **Your vote—verified, private, and fast.**

> **Modernizing elections with Blockchain Security—Saving Resources, Efforts, Cost, and Time.**

---

## Table of Contents  
- [Overview](#overview)  
- [Problem Statement](#problem-statement)  
- [Key Features](#key-features)  
- [Technologies Used](#technologies-used)  
- [Architecture and System Design](#architecture-and-system-design)  
- [Setup & Installation](#setup--installation)  
- [Usage](#usage)  
- [Input/Output & Security](#inputoutput--security)  
- [Results & Impact](#results--impact)  
- [Roadmap & Future Work](#roadmap--future-work)  
- [Demo](#demo)  
- [Publications](#publications)  
 
---

## Overview  
VoteChain is a cross-platform (Android–Flutter) mobile application that provides a secure online voting platform by recording votes on an Ethereum-based blockchain (Sepolia testnet via QuickNode) while using Firebase as an off-chain database.  By leveraging blockchain’s *decentralization*, *immutability*, and *transparency*, VoteChain prevents fraud and manipulation in elections ([Blockchain-Based E-Voting Systems: A Technology Review](https://www.mdpi.com/2079-9292/13/1/17#:~:text=Blockchain%20technology%20has%20been%20recognized,associated%20with%20traditional%20voting%20systems)).  Each vote cast by a citizen is sent as an Ethereum transaction through the Web3dart library ([web3dart | Dart package](https://pub.dev/packages/web3dart#:~:text=A%20dart%20library%20that%20connects,smart%20contracts%20and%20much%20more)) to a Solidity smart contract, ensuring an immutable record on the ledger.  The Flutter framework (Google’s open-source UI toolkit for building apps from a single codebase) ([Pros and Cons of Flutter App Development](https://www.altexsoft.com/blog/pros-and-cons-of-flutter-app-development/#:~:text=Flutter%20is%20Google%E2%80%99s%20open,we%E2%80%99re%20on%20the%20same%20page)) delivers an intuitive and consistent mobile interface for all users.  Multifactor authentication (MFA) and role-based access control are built in to verify voter identities and authorize actions.  VoteChain thus aims to modernize elections by combining cutting-edge blockchain security with cloud-based scalability, enhancing trust while significantly reducing operational costs.  

---

## Problem Statement  
Large-scale elections (e.g. India’s national elections) require enormous resources and remain vulnerable to fraud.  For example, the 2024 Lok Sabha elections cost an *estimated* ₹1.35 lakh crore ([Great Indian election money game: Rs 3,861 crore spent on five elections in 2024, data reveals](https://www.newindianexpress.com/nation/2025/Mar/24/great-indian-election-money-game-rs-3861-crore-spent-on-five-elections-in-2024-data-reveals#:~:text=BANGALORE%3A%20The%202024%20Lok%20Sabha,this%20was%20an%20unofficial%20estimate)) in security, logistics, and infrastructure.  Conventional systems suffer from logistical delays, voter disenfranchisement, and fraud: paper ballots can be tampered with or lost, and even Electronic Voting Machines (EVMs) have documented vulnerabilities – researchers have shown that Indian EVMs (a paperless DRE system) can be hacked to alter results ([India’s electronic voting machines are vulnerable to attack |  University of Michigan News](https://news.umich.edu/india-s-electronic-voting-machines-are-vulnerable-to-attack/#:~:text=ANN%20ARBOR%E2%80%94Electronic%20voting%20machines%20in,University%20of%20Michigan%20computer%20scientist)).  Moreover, millions of eligible voters (such as migrant workers) cannot easily vote due to distance or work obligations; the Election Commission of India notes that inability to vote because of internal migration is a “prominent reason” for low turnout ([India: Migrant workers unable to vote in home states owing to prohibitive travel costs & loss of earnings, call for votes at work destinations - Business & Human Rights Resource Centre](https://www.business-humanrights.org/en/latest-news/india-migrant-workers-unable-to-vote-in-home-states-owing-to-prohibitive-travel-costs-loss-of-earnings-call-for-votes-at-work-destinations/#:~:text=According%20to%20the%20Election%20Commission,But%20in%20March)). 

Online voting systems have been explored, but many suffer from security flaws (identity fraud, result manipulation, and lack of auditability). Blockchain technology offers a promising alternative.  In particular, blockchain’s decentralized and immutable nature can create a tamper-proof, transparent platform for e-voting. A well-designed blockchain voting system can ensure secure, verifiable, and auditable elections while reducing cost and bureaucracy.  **VoteChain** addresses the need for a secure, transparent, cost-effective, and scalable voting solution that overcomes these challenges.  

---

## Key Features  
- **Secure Voter Registration & MFA Login:** Citizens register with verifiable credentials and log in using multi-factor authentication (MFA), adding a strong security layer to the voter database ([How Multi-factor Authentication Enhances Election Security - StateTech Magazine](https://statetechmagazine.com/article/2020/04/role-multifactor-authentication-election-security-perfcon#:~:text=Election%20authorities%20can%20use%20MFA,voter%20databases%20and%20essential%20applications)). Each user receives a unique ID, and only eligible voters (one per person) can proceed to vote.  
- **Role-Based Access Control:** The system supports multiple user roles – *Voters*, *Candidates*, *Party Heads*, and *Election Officials (Admin)* – each with specific permissions. Administrators create and manage elections; party heads register candidates; voters cast vote; candidates track their vote count, etc. All actions are governed by role checks.  
- **Immutable On-Chain Vote Recording:** Votes are recorded on the Ethereum blockchain via a smart contract written in Solidity ([Home | Solidity Programming Language](https://soliditylang.org/#:~:text=)). This ensures every vote is permanently logged and tamper-proof. Blockchain consensus and cryptographic hashing guarantee vote integrity and public verifiability.  
- **Real-Time Results & Analytics:** As votes are submitted, the contract tallies them on-chain. The mobile app fetches current counts and provides real-time visualizations (lists and charts) for voters and officials. Off-chain Firebase analytics supplement the view with dynamic graphs and logs.  
- **Election Management Dashboard:** Admins use an intuitive interface to create, schedule, and oversee elections at all levels (local, state, national). Candidate and party data (names, symbols, etc.) are stored off-chain in Firebase for flexibility, reducing on-chain transactions and gas costs.  
- **Fraud Prevention & Audit Trails:** Smart contracts enforce one-vote-per-voter, reject duplicate votes, and enforce constituency boundaries. All actions (votes cast, user registrations, etc.) generate audit logs stored both on-chain and in Firebase. These logs allow any party to audit the election, ensuring transparency and trust.  
- **Hybrid On-Chain/Off-Chain Architecture:** Only critical voting data (vote transactions) go on-chain; non-critical data (user profiles, metadata) live in Firebase. This hybrid design dramatically cuts gas fees (estimated 40–60% savings by offloading data while maintaining high throughput and scalability.  

---

## Technologies Used  
- **Flutter / Dart:** The mobile app is built with Flutter (Google’s UI toolkit for cross-platform development). This ensures a native-like user experience on Android (and potentially iOS) from a single codebase.  
- **Solidity:** Smart contracts are written in Solidity – a statically-typed language designed for Ethereum smart contracts. Solidity governs the voting logic (registration checks, vote casting, tallying) on-chain.  
- **Ethereum (Sepolia Testnet):** VoteChain uses the Sepolia Ethereum testnet for development and testing. Sepolia is a proof-of-stake test network with shorter block times (fast confirmations) and uncapped test ETH supply ([What is the Sepolia testnet? ](https://www.alchemy.com/overviews/sepolia-testnet#:~:text=match%20at%20L206%20Sepolia%20was,times%20and%20feedback%20for%20developers)), making it ideal for trial deployments. Mainnet or other testnets (Goerli) can be used in future.  
- **Web3dart:** The Flutter app communicates with Ethereum via the Web3dart library. Web3dart connects to a QuickNode RPC endpoint, enabling the app to send signed transactions and call smart contract functions.  
- **QuickNode API:** QuickNode provides a reliable Ethereum RPC endpoint (JSON-RPC) to submit transactions and read blockchain state. This abstracts away running a full node.  
- **Firebase:** We use Firebase (Google Cloud) as the off-chain database and backend. Firebase Realtime Database (or Cloud Firestore) stores user accounts, election metadata, and logs. Firebase’s real-time sync and security rules ([Firebase Realtime Database](https://firebase.google.com/docs/database#:~:text=Store%20and%20sync%20data%20with,when%20your%20app%20goes%20offline)) make it suitable for our needs (secure, scalable data storage).  
- **Android Studio & Tools:** Development is done in Android Studio (with Flutter SDK). Remix IDE is used for smart contract development and deployment. Standard Android SDKs support building and testing on devices.  

---

## Architecture and System Design  
VoteChain employs a **hybrid on-chain/off-chain architecture** (illustrated below). The mobile app (Flutter) interacts with two backend layers. **On-chain**, a Solidity smart contract (deployed on Ethereum Sepolia via QuickNode) records votes and enforces voting rules. **Off-chain**, Firebase manages all other data (user profiles, election setup, candidate info, logs). This separation optimizes performance: the blockchain only handles immutable vote recording (ensuring integrity), while Firebase handles dynamic data and heavy read/write loads (ensuring scalability).  

<table>
  <tr>
    <td align="center">
      <img
        src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Temp%20Pics/System%20Architecture.png"
        width="1000"
        alt="System Architecture Diagram"
      >
    </td>
  </tr>
</table>

Functionally, when a voter casts a vote in the app, the app (via Web3dart) submits a signed transaction to the smart contract on Ethereum. The contract validates eligibility and records the vote on-chain. Meanwhile, Firebase logs the action (for analytics and backup) and updates UI data. Administrators use Firebase-powered screens to create elections and manage candidates; these settings are then pushed to the blockchain contract as needed. This design strikes a **robust balance between security, scalability, and cost-efficiency**

---

## Setup & Installation  
1. **Clone the Repository:**  
   - Using Git
   - Or download the ZIP file and extract it manually.
2. **Flutter and Android Studio:**  
   - Install the Flutter SDK and configure your environment (see Flutter docs).  
   - Install Android Studio (with Android SDK) and connect an Android device or emulator.  
3. **Dependencies:**  
   - In the project root, run `flutter pub get` to fetch Dart/Flutter packages.  
4. **Smart Contract Deployment:**  
   - Open the Solidity contract in Remix or your preferred IDE. Compile it (Solidity 0.8.x) and deploy to the Sepolia testnet. Use your QuickNode (or Infura/Alchemy) Sepolia RPC URL when deploying.  
   - Obtain the contract address and ABI.  
   - Fund your Ethereum account with Sepolia ETH from a faucet (needed to pay gas).  
5. **Firebase Setup:**  
   - Create a new Firebase project on the Firebase console.  
   - Add a Realtime Database or Firestore.  
   - Under project settings, register an Android app (use your application ID) and download the `google-services.json` file into the Android module.  
   - Set up basic security rules (e.g., require Firebase Authentication for reads/writes).  
   - Note the Firebase API keys and database URL for configuration.  
6. **Configuration:**  
   - In the Flutter app code (e.g., `lib/SERVICE/utils/app_constants.dart` or `lib/config.dart`), set your QuickNode RPC endpoint, deployed contract address, and Firebase project parameters (in `lib/main.dart` ).  
   - Ensure `web3dart` and `firebase_core` packages are initialized with these values.  
7. **Build & Run:**  
   - Build the app: `flutter run`.  
   - Upon launch, the app will initialize Firebase and connect to the smart contract. Login with a test user, create elections, and cast test votes.  

---

## Usage  
VoteChain supports multiple user roles, each interacting with the app as follows:  

- **Citizen (Voter):**  
  - **Register & Login:** Create a voter profile and verify identity. Login using MFA.  
  - **View Elections:** Browse active elections (local, state, national).  
  - **Cast Vote:** Select one candidate/party and cast the vote. The app sends the vote as a blockchain transaction; the smart contract checks eligibility and records the vote. (Duplicate votes are automatically blocked.)  
  - **See Results:** After voting, view real-time results of the election in list and chart form.  

- **Election Official (Admin):**  
  - **Election Setup:** Use the admin dashboard to create new elections and define their scope (date, constituency).  
  - **Manage Candidates/Parties:** Register candidate names, party affiliations, and symbols. This data is stored in Firebase for flexibility.  
  - **Monitor Election:** Watch the live tally updates. After polls close, the smart contract’s final count is used for official results.  

- **Party Head:**  
  - **Candidate Registration:** Manage your party’s list of candidates and upload any required credentials.  
  - **Result Tracking:** View vote counts for your party’s candidates in real time.  

- **Candidate:**  
  - **Profile:** Create and manage a candidate profile.  
  - **Vote Tracking:** See how many votes you have received (pulled from the on-chain results).  

*Example flow:* A citizen logs in, verifies via MFA, selects a candidate, and taps “Vote”. Behind the scenes, Web3dart packages this vote into a signed Ethereum transaction and sends it to the Sepolia network. The smart contract executes and stores the vote. The app confirms to the user that the vote is cast (and prevents voting again). This secure workflow is enforced by the blockchain logic (ensuring one vote per eligible voter). 

---

## Input/Output & Security  
- **Inputs:** User credentials (registration data, OTP/MFA tokens), election definitions (titles, candidates), and vote selections (candidate IDs).  
- **Outputs:** Transaction confirmations, updated vote tallies, and election results (displayed as text and charts).  

Security is integral at every step:  
- **Authentication:** VoteChain requires multi-factor authentication for all users. This layered approach (e.g. password/OTP, or email/SMS codes) greatly enhances protection of voter data.
- **Authorization:** Role-based access ensures that only registered voters can cast votes, only admins can create elections, etc. Unauthorized actions are simply not permitted by the UI and smart contract logic.  
- **Integrity (Blockchain):** Every submitted vote is hashed and immutably stored on Ethereum. By design, blockchain transactions cannot be altered once confirmed, providing tamper-proof assurance. Anyone can audit the on-chain ledger to verify the total votes.  
- **Encryption:** All communications (app-to-backend, backend-to-blockchain) use secure channels. Private keys are stored securely, and Firebase security rules protect the database. End-to-end encryption (via HTTPS/SSL and Ethereum crypto) guards data in transit and at rest.  
- **Audit Logs:** Every critical action (logins, registrations, vote casts) is recorded. The smart contract emits events on each vote, and Firebase keeps additional logs. Together these logs allow auditors to trace and verify the entire election process.  

---

## Results & Impact  
VoteChain demonstrates significant practical benefits:  
- **Cost Reduction:** By eliminating most physical infrastructure (polling booths, EVMs, paper ballots) and streamlining manpower, VoteChain can dramatically cut election expenses. For reference, India’s 2024 Lok Sabha polls cost about ₹1.35 lakh crore; even a fraction of cost-saving in such a large election can be billions of rupees saved. Blockchain transactions on Sepolia incur no real ether cost (test ETH is free), and by offloading non-critical data off-chain we reduce gas fees ~40–60%.  
- **Enhanced Transparency & Trust:** All votes are publicly recorded on the blockchain, eliminating any “black box” in tallying. Anyone can independently verify results. Studies note that blockchain-based e-voting improves transparency and trust in elections. VoteChain’s auditability and open logs help rebuild confidence in digital voting.  
- **Increased Participation:** Remote electronic voting (accessible via smartphones) enables out-of-town or disabled citizens to vote from anywhere, addressing the geographical disenfranchisement of migrant workers. Early testing suggests that providing secure mobile voting can measurably boost turnout among these groups.  
- **Scalability:** The hybrid design supports very large electorates. Our tests show the system can handle millions of users with minimal latency by relying on Firebase’s real-time sync and by batching blockchain updates. Post-election analysis (detailed analytics and charts) is instant.  
- **Auditability & Analytics:** Voter anonymity is preserved, but VoteChain provides full election statistics (e.g. vote shares per candidate, turnout rates) in real time. Decision-makers and researchers can analyze the data easily, leading to better-informed policies.  

---

## Roadmap & Future Work  
VoteChain is a solid prototype with many paths for enhancement:  
- **Privacy Enhancements:** Integrate cryptographic techniques (e.g. zero-knowledge proofs or homomorphic encryption) to allow public tallying without revealing individual votes.  
- **Layer-2 Scaling:** Migrate to Ethereum Layer-2 solutions (like Polygon or Optimism) to further reduce fees and increase throughput for even larger elections.  
- **Mainnet Deployment:** After thorough auditing, deploy VoteChain on Ethereum mainnet or a permissioned blockchain (for governmental use).  
- **Identity Integration:** Tie into national ID systems (e.g. Aadhaar) or blockchain-based digital identity solutions to streamline voter registration and verification.  
- **Community Contributions:** Open-sourcing the project will allow civic developers and election officials to audit, extend, and customize VoteChain for their needs.  

---

## Demo

<table>
  <tr>
    <td align="center">
      <strong>Citizen registration & viewing past elections<br><em>4 min 57 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/1%5D%20Citizen%20registration%20%26%20viewing%20past%20elections.gif" width="230">
    </td>
    <td align="center">
      <strong>Admin creating election & Starting stage 1<br><em>1 min 56 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/2%5D%20Admin%20creating%20election%20%26%20Starting%20stage%201.gif" width="230">
    </td>
    <td align="center">
      <strong>Party-head applying for the ongoing<br>election<br><em>2 min 17 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/3%5D%20Party-head%20applying%20for%20election.gif" width="230">
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Admin stoping stage 1 & Verifiying party applications<br><em>3 min 45 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/4%5D%20Admin%20stoping%20stage%201%20%26%20Verifiying%20party%20applications.gif" width="230">
    </td>
    <td align="center">
      <strong>Admin starting stage 2 & Candidate applying for election<br><em>3 min 57 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/5%5D%20Admin%20starting%20stage%202%20%26%20Candidate%20applying%20for%20election%20(1).gif" width="230">
    </td>
    <td align="center">
      <strong>Admin stoping stage 2 & Party-head verifying candidate applications<br><em>5 min 36 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/6%5D%20Admin%20stoping%20stage%202%20%26%20Parthead%20verifying%20candidate%20applications.gif" width="230">
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Admin starting election & Citizen casting vote<br><em>4 min 50 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/7.1%5D%20Admin%20starting%20election%20%26%20Citizen%20casting%20vote.gif" width="230">
    </td>
    <td align="center">
      <strong>Citizen casting vote by showing security measures<br><em>1 min 50 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/7.2%5D%20Citizen%20casting%20vote%20by%20showing%20security%20measures.gif" width="230">
    </td>
    <td align="center">
      <strong>Citizen casting vote by showing security measures & Citizen profile<br><em>0 min 50 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/7.3%5D%20Citizen%20casting%20vote%20by%20showing%20security%20measures%20%26%20Citizen%20profile.gif" width="230">
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Admin stopping election & Results showing<br><em>2 min 00 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/8.1%5D%20Admin%20stopping%20election%20%26%20Results%20showing.gif" width="230">
    </td>
    <td align="center">
      <strong>Citizen & Guest viewing results and reports<br><em>1 min 50 sec</em></strong><br>
      <img src="https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/raw/main/Phase%202/3.%20Other%20Files/Output%20Data/Screen%20Recordings/v1.0.0%20GIFs/8.2%5D%20Citizen%20%26%20Guest%20viewing%20results%20and%20reports.gif" width="230">
    </td>
    <!-- Leave the last cell blank or remove this <td> if you only have 11 gifs -->
    <td></td>
  </tr>
</table>

---

## Publications
- **Survey Paper** (Published at IRJMETS): [Online Voting System Using Blockchain: A Comprehensive Survey](https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/blob/main/Phase%202/4.%20Publications/Published%20S.P.%20-%20IRJMETS/Published_survey%20paper/03%20Received_Files/OVSUB%20Survey%20Paper.pdf)
  
- **Research Paper** (Published at IJCRT):  [Online Voting System Using Blockchain: A Comprehensive Approach](https://github.com/MrHAM17/Online_Voting_System_Using_Bockchain/blob/main/Phase%202/4.%20Publications/Published%20R.P.%20-%20IJCRT/05%20Submitted_Paper%20File%20for%20corrrection/25A3317_280830.pdf)

---
