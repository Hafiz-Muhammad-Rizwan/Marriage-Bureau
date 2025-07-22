import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/RegistrationScreen/GuardianScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/HomeDetailsScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ProfileCompletionScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/educationLevelScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/genderScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/professionScreen.dart';
import 'package:marriage_bereau_app/Screens/homeScreen.dart';
import 'package:marriage_bereau_app/Screens/signInScreen.dart';
import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';

class Introscreen extends StatelessWidget {
  const Introscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final double cardHeightPercentage;
          if (screenWidth > screenHeight) {
            cardHeightPercentage = 0.80;
          } else {
            if (screenHeight < 600) {
              cardHeightPercentage = 0.60;
            } else if (screenHeight < 750) {
              cardHeightPercentage = 0.50;
            } else {
              cardHeightPercentage = 0.45;
            }
          }

          final double cardActualHeight = screenHeight * cardHeightPercentage;

          return Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Images/coupleImage.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: screenWidth,
                      height: cardActualHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Find Your Soulmate!",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: headingSize * 1.2,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "It's time to find your soulmate wholeheartedly and embark on a beautiful journey.",
                              style: TextStyle(
                                color: greyColor,
                                fontSize: subHeadingSize * 1.05,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 35),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkColor,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  shadowColor: pinkColor.withOpacity(0.5),
                                ),
                                onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
                                },
                                child: Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: headingSize * 0.9,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}