import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SmokeScreen.dart';

import 'package:provider/provider.dart';
class Moveabroad extends StatefulWidget {
  const Moveabroad({super.key});

  @override
  State<Moveabroad> createState() => _MoveabroadState();
}

class _MoveabroadState extends State<Moveabroad> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(builder: (context,progressProvider,child){
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Would you move abroad for marriage?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Consumer<MoveAbroadProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    itemCount: provider.options.length,
                    itemBuilder: (context, index) {
                      final option = provider.options[index];
                      final isSelected = provider.selectedOption == option;

                      return ListTile(
                        title: Text(
                          option.option,
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                        ),
                        tileColor: isSelected ? Colors.grey[200] : null,
                        trailing: isSelected ? Icon(Icons.check_circle, color: Colors.red) : null,
                        onTap: () async {
                          provider.selectOption(option);
                          final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                          progressProvider.nextScreen();
                          await Future.delayed(Duration(milliseconds: 500));
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => Smokescreen(),
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
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
