import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Screens/signUpScreen.dart';

import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';

class Introscreen extends StatelessWidget {
  const Introscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height;
    final width=MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Images/coupleImage.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: width,
              height: height*0.40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text(
                      "Find your Soulmate !!",
                      style: TextStyle(color: blackColor, fontSize: headingSize,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20,),
                    Text(
                      "Its time to find your soulmate wholeheartedly.",
                      style: TextStyle(color: greyColor, fontSize: subHeadingSize,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 25,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(13),
                        backgroundColor: pinkColor
                      ),
                        onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Signupscreen()));
                        },
                        child: Text("Get Started",style: TextStyle(color: whiteColor,fontWeight: FontWeight.bold,fontSize: subHeadingSize),))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
