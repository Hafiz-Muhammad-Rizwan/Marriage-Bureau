import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Services/connection_service.dart';

import 'package:marriage_bereau_app/Services/profile_service.dart';
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
        ChangeNotifierProvider(create: (_)=>SmokingProvider()),
        ChangeNotifierProvider(create: (_)=>AlcoholConsumptionProvider()),
        ChangeNotifierProvider(create: (_)=>ChildrenProvider()),
        ChangeNotifierProvider(create: (_)=>MoveAbroadProvider()),
        ChangeNotifierProvider(create: (_)=>InterestProvider()),
        ChangeNotifierProvider(create: (_)=>ProgressProvider()),
        ChangeNotifierProvider(create: (_)=>ProfileService()),
        ChangeNotifierProvider(create: (_)=>EducationLevelProvider()),
        ChangeNotifierProvider(create: (_)=>ProfessionProvider()),
        ChangeNotifierProvider(create: (_)=>SectProvider()),
        ChangeNotifierProvider(create: (_)=>GenderProvider()),
        ChangeNotifierProvider(create: (_)=>NameAgeProvider()), 
        ChangeNotifierProvider(create: (_)=>ConnectionService()),
        ChangeNotifierProvider(create: (_)=>SiblingsProvider()),
        ChangeNotifierProvider(create: (_)=>CasteProvider()),
        ChangeNotifierProvider(create: (_)=>ParentsStatusProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => GuardianLevelProvider())
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
      home: Introscreen(),
    );
  }
}
