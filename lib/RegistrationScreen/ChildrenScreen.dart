import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ChildrenDetailsScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/MoveAbroad.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SiblingsScreen.dart';
import 'package:provider/provider.dart';
class Childrenscreen extends StatefulWidget {
  const Childrenscreen({super.key});

  @override
  State<Childrenscreen> createState() => _ChildrenscreenState();
}

class _ChildrenscreenState extends State<Childrenscreen> {
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
                'Do you have children?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Consumer<ChildrenProvider>(
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

                          // Navigate to the appropriate screen based on the selection
                          if (option.option == "Yes") {
                            // If user has children, go to children details screen
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => ChildrenDetailsScreen(),
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
                            // If user doesn't have children, skip to move abroad screen
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => SiblingsScreen(),
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
                          }
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
