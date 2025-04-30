
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      // globalBackgroundColor: Color(0xfff1f1f1),
      globalBackgroundColor: Colors.white,
      showNextButton: false, // Disable Next button to only show "Get Started"
      done: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text("Let's Go", style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),  // Get Started  // Proceed
      ),
      onDone: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seenOnboarding', true);

        // Navigate to the Home screen after onboarding
        Navigator.pushReplacementNamed(context, '/Login');
      },
      pages: [
        firstScreen(context),
        secondScreen(context),
        thirdScreen(context),
        fourthScreen(context),
      ],
    );
  }

  PageViewModel firstScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: 'Welcome to VoteChain',
      decoration: PageDecoration(
        // pageColor: Color(0xfff1f1f1),
        pageColor: Colors.white, // BG color Set to white
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),  // space between img & title
        bodyPadding: EdgeInsets.only(top: 50), // space between title and body
        imagePadding: EdgeInsets.zero,
      ),
      body: "A secure, transparent & efficient way to vote using blockchain technology.\nYour vote counts & is safely recorded.",  // at reduced cost.\nYour...
      image: Image.asset('assets/images/VoteChain_App_Logo.png', width: size.width * 0.4900),  // 0.5
    );
  }

  PageViewModel secondScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: "Blockchain-Powered Voting",
      decoration: PageDecoration(
        // pageColor: Color(0xfff1f1f1),
        pageColor: Colors.white, // BG color Set to white
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        bodyPadding: EdgeInsets.only(top: 50), // space between title and body
        imagePadding: EdgeInsets.zero,
      ),
      body: "With VoteChain, all votes are securely stored on the blockchain, ensuring  transparency & preventing tampering.",  // blockchain-certified transparency...
      image: Image.asset('assets/images/blockchain_security.png', width: size.width * 0.8),  // 0.5
    );
  }

  PageViewModel thirdScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: "Secure & Private",
      decoration: PageDecoration(
        // pageColor: Color(0xfff1f1f1),
        pageColor: Colors.white, // BG color Set to white
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        bodyPadding: EdgeInsets.only(top: 50), // space between title and body
        imagePadding: EdgeInsets.zero,
      ),
      // body: "Our multi-factor authentication ensures that only authorized users can vote,\nmaintaining the integrity of the election process.",
      body: "Robust multi-factor authentication & stringent voter verification ensure that\nonly eligible citizens cast their votes, safeguarding both security & privacy.",
      image: Image.asset('assets/images/authentication.jpg', width: size.width * 1),  // 0.6
    );
  }

  PageViewModel fourthScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: "Easy & Accessible",
      decoration: PageDecoration(
        // pageColor: Color(0xfff1f1f1),
        pageColor: Colors.white, // BG color Set to white
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        bodyPadding: EdgeInsets.only(top: 50), // space between title and body
        imagePadding: EdgeInsets.zero,
      ),
      // body: "VoteChain allows users to vote from anywhere, even when they are out of station.\nNo more waiting in long queues!",
      body: "VoteChain empowers you to vote from anywhere, anytime during the election window,\nNo more waiting in long queues, even when you're out of station!",
      image: Image.asset('assets/images/election_accessibility.png', width: size.width * 0.8), // 0.6
    );
  }
}



