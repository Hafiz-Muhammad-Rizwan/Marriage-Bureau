import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ChildrenScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/MoveAbroad.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SiblingsScreen.dart';
import 'package:provider/provider.dart';

class maritalStatus extends StatefulWidget
{

  @override
  State<maritalStatus>createState()=>MaritalStatusState();
}
class MaritalStatusState extends State<maritalStatus>
{
  Widget build(BuildContext context)
  {
    return Consumer<ProgressProvider>(builder: (context,progressProvider,child)
    {
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
                "What's your marital status?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Consumer<MaritalStatusProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    itemCount: provider.statuses.length,
                    itemBuilder: (context, index) {
                      final status = provider.statuses[index];
                      final isSelected = provider.selectedStatus == status;
                      return ListTile(
                        title: Text(
                          status.status,
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                        ),
                        tileColor: isSelected ? Colors.grey[200] : null,
                        trailing: isSelected ? Icon(Icons.check_circle, color: Colors.red) : null,
                        onTap: ()async {
                          provider.selectStatus(status);
                          final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                          progressProvider.nextScreen();
                          await Future.delayed(Duration(milliseconds: 500));

                          // Check if the selected status is "Never married"
                          if (status.status == 'Never married') {
                            // Skip the children screen and go directly to MoveAbroad screen
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => SiblingsScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); // Start from the right
                                  const end = Offset.zero; // End at the center
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 500), // 0.5 seconds
                              ),
                            );
                          } else {
                            // For all other statuses (Divorced, Widowed, etc.), show the children screen
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => Childrenscreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); // Start from the right
                                  const end = Offset.zero; // End at the center
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 500), // 0.5 seconds
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