import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/BioScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ChildrenScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/CountrySelection.dart';
import 'package:marriage_bereau_app/RegistrationScreen/Editing%20Screen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/HalalFood.dart';
import 'package:marriage_bereau_app/RegistrationScreen/HeightScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/IntetrestScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/MaritalStatus.dart';
import 'package:marriage_bereau_app/RegistrationScreen/PrayScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/RelegiousPractice.dart';
import 'package:marriage_bereau_app/RegistrationScreen/name_ageScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/photoUploadScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/stepManager.dart';
import 'package:provider/provider.dart';

import 'Screens/introScreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MultiProvider(providers:[
        ChangeNotifierProvider(create: (_)=>SignUp()),
        ChangeNotifierProvider(create: (_)=>countryData()..fetchCountries()),
        ChangeNotifierProvider(create: (_)=>HeightProvider()),
        ChangeNotifierProvider(create: (_)=>MaritalStatusProvider()),
        ChangeNotifierProvider(create: (_)=>ReligiousPracticeProvider()),
        ChangeNotifierProvider(create: (_)=>PrayerFrequencyProvider()),
        ChangeNotifierProvider(create: (_)=>HalalFoodProvider()),
        ChangeNotifierProvider(create: (_)=>SmokingProvider()),
        ChangeNotifierProvider(create: (_)=>AlcoholConsumptionProvider()),
        ChangeNotifierProvider(create: (_)=>ChildrenProvider()),
        ChangeNotifierProvider(create: (_)=>MoveAbroadProvider()),
        ChangeNotifierProvider(create: (_)=>BornMuslimProvider()),
        ChangeNotifierProvider(create: (_)=>InterestProvider()),
        ChangeNotifierProvider(create: (_)=>ProgressProvider()),
        ChangeNotifierProvider(create: (_)=>BioProvider())
      ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarriageBureau',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: EditingScreen(),
    );
  }
}
