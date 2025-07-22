import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/RegistrationScreen/HomeDetailsScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/IntetrestScreen.dart';
import 'package:provider/provider.dart';

class ParentsAliveScreen extends StatefulWidget {
  const ParentsAliveScreen({super.key});

  @override
  State<ParentsAliveScreen> createState() => _ParentsAliveScreenState();
}

class _ParentsAliveScreenState extends State<ParentsAliveScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(builder: (context, progressProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Marriage Beuru",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          backgroundColor: Colors.pink,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              progressProvider.previousScreen();
              Navigator.pop(context);
            },
          ),
          actions: [
            Consumer<ProgressProvider>(
              builder: (context, progressProvider, child) {
                final percentage = (progressProvider.progress * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: progressProvider.progress,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.grey[300],
                          strokeWidth: 2.0,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Are your parents alive?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Father',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Consumer<ParentsStatusProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: provider.options.map((option) {
                          final isSelected = provider.fatherAlive == option;
                          return ListTile(
                            title: Text(
                              option.option,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            tileColor: isSelected ? Colors.grey[200] : null,
                            trailing: isSelected ? Icon(Icons.check_circle, color: Colors.red) : null,
                            onTap: () {
                              provider.selectFatherStatus(option);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Mother',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Consumer<ParentsStatusProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: provider.options.map((option) {
                          final isSelected = provider.motherAlive == option;
                          return ListTile(
                            title: Text(
                              option.option,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            tileColor: isSelected ? Colors.grey[200] : null,
                            trailing: isSelected ? Icon(Icons.check_circle, color: Colors.red) : null,
                            onTap: () {
                              provider.selectMotherStatus(option);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  final provider = Provider.of<ParentsStatusProvider>(context, listen: false);
                  if (provider.fatherAlive != null && provider.motherAlive != null) {
                    progressProvider.nextScreen();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => HomeDetailsScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 500),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select status for both parents', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
