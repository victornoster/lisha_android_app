import 'package:api_example_app/LandingScreen/components/body.dart';
import 'package:api_example_app/constants.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreeState createState() => _LandingScreeState();
}

class _LandingScreeState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: LandingScreenBody(),
    );
  }
}
