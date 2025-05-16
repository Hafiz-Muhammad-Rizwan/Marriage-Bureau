import 'package:flutter/material.dart';

import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
              height: height * 0.70,
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
                    const SizedBox(height: 20),
                     Text(
                      "Create an account",
                      style: TextStyle(
                        color: blackColor,
                        fontSize: headingSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email address",
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passController,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _termsAccepted,
                                checkColor: whiteColor,
                                activeColor: pinkColor,
                                onChanged: (value) {
                                  setState(() {
                                    _termsAccepted = value!;
                                  });
                                },
                              ),
                              Flexible(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "I agree with the ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: subHeadingSize)),
                                       TextSpan(
                                          text: "terms ",
                                          style: TextStyle(
                                              color: pinkColor,
                                              fontSize: subHeadingSize)),
                                       TextSpan(
                                          text: "& ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: subHeadingSize)),
                                       TextSpan(
                                          text: "conditions",
                                          style: TextStyle(
                                              color: pinkColor,
                                              fontSize: subHeadingSize)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                        child: Text("Already have an account?",style: TextStyle(color: blackColor),))
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
