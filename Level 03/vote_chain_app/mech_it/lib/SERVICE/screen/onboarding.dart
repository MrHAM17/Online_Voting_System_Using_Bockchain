import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Onboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Color(0xfff1f1f1),
      showNextButton: false, // Disable Next button to only show "Get Started"
      done: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text('Get Started', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      onDone: () {
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
      title: 'Welcome to Vote Chain',
      decoration: PageDecoration(
        pageColor: Color(0xfff1f1f1),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        imagePadding: EdgeInsets.zero,
      ),
      body: "A secure, transparent, and efficient way to vote using blockchain technology. Your vote counts and is safely recorded.",
      image: Image.asset('assets/images/vote_chain_logo.jpg', width: size.width * 0.6),
    );
  }

  // Add second, third, and fourth screens similarly
  PageViewModel secondScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: "Blockchain-Powered Voting",
      decoration: PageDecoration(
        pageColor: Color(0xfff1f1f1),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        imagePadding: EdgeInsets.zero,
      ),
      body: "With Vote Chain, all votes are securely stored on the blockchain, ensuring transparency and preventing tampering.",
      image: Image.asset('assets/images/blockchain_security.png', width: size.width * 0.6),
    );
  }

  PageViewModel thirdScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: "Secure and Private",
      decoration: PageDecoration(
        pageColor: Color(0xfff1f1f1),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        imagePadding: EdgeInsets.zero,
      ),
      body: "Our multi-factor authentication ensures that only authorized users can vote, maintaining the integrity of the election process.",
      image: Image.asset('assets/images/authentication.jpg', width: size.width * 0.6),
    );
  }

  PageViewModel fourthScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageViewModel(
      title: "Easy and Accessible",
      decoration: PageDecoration(
        pageColor: Color(0xfff1f1f1),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        bodyTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        titlePadding: EdgeInsets.only(top: size.height * 0.05),
        imagePadding: EdgeInsets.zero,
      ),
      body: "Vote Chain allows users to vote from anywhere, even when they are out of station. No more waiting in long queues!",
      image: Image.asset('assets/images/election_accessibility.png', width: size.width * 0.6),
    );
  }
}
