import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:provider/provider.dart';

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
                      SizedBox(height: 20,),
                      Consumer<SignUp>(
                          builder: (ctx,Provider,_)=> ElevatedButton(
                            onPressed: () async{
                              String Email=_emailController.text.trim();
                              String Password=_passController.text.trim();
                             String?Result=await Provider.signUp(Email,Password);
                             if(Result==null)
                               {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text("Sign up successful!")),
                                 );
                               }
                             _emailController.clear();
                             _passController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple, // Button color
                              foregroundColor: Colors.white, // Text color
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                              ),
                              elevation: 5, // Shadow
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            child: Text('Sign Up'),
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
      ),
    );
  }
}
