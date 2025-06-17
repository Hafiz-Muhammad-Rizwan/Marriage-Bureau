import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/RegistrationScreen/genderScreen.dart';
import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';
import '../Essentials/customTextField.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  bool _isPasswordVisible = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Terms & Conditions", style: TextStyle(color: pinkColor)),
          content: SingleChildScrollView(
            child: Text(
              "By logging in, you agree to our privacy policy and terms of service. This includes data usage for personalized content, communication via email/SMS, and adherence to community guidelines. Please read full terms on our website.",
              style: TextStyle(fontSize: subHeadingSize),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close", style: TextStyle(color: pinkColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                height: height * (height > 700 ? 0.65 : 0.75),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: blackColor,
                          fontSize: headingSize * 1.2,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login to your account to continue",
                        style: TextStyle(
                          color: blackColor.withOpacity(0.6),
                          fontSize: subHeadingSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: "Email address",
                              hint: "example@email.com",
                              controller: _emailController,
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              focusedBorderColor: pinkColor,
                              fillColor: Colors.grey[100]!,
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
        
                            CustomTextField(
                              label: "Password",
                              hint: "Enter your password",
                              controller: _passController,
                              prefixIcon: Icons.lock,
                              obscureText: !_isPasswordVisible,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              focusedBorderColor: pinkColor,
                              fillColor: Colors.grey[100]!,
                              borderRadius: 12,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
        
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Forgot Password tapped!", style: TextStyle(color: whiteColor)),
                                      backgroundColor: pinkColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: pinkColor,
                                    fontSize: subHeadingSize * 0.9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
        
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "I agree with the ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: subHeadingSize * 0.95)),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showTermsAndConditions,
                                          child: Text(
                                            "terms",
                                            style: TextStyle(
                                              color: pinkColor,
                                              fontSize: subHeadingSize * 0.95,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                          text: " & ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: subHeadingSize * 0.95)),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showTermsAndConditions,
                                          child: Text(
                                            "conditions",
                                            style: TextStyle(
                                              color: pinkColor,
                                              fontSize: subHeadingSize * 0.95,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  shadowColor: pinkColor.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (!_termsAccepted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Please accept the terms & conditions.", style: TextStyle(color: whiteColor)),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Login successful!", style: TextStyle(color: whiteColor)),
                                        backgroundColor: pinkColor,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "Login",
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
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                              style: TextStyle(color: blackColor)),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GenderScreen()));
                            },
                            child: Text(
                              "Register Now",
                              style: TextStyle(
                                color: pinkColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: subHeadingSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}