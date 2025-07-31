import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ProfileCompletionScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SmokeScreen.dart';
import 'package:provider/provider.dart';

class Intetrestscreen extends StatefulWidget {
  const Intetrestscreen({super.key});

  @override
  State<Intetrestscreen> createState() => _IntetrestscreenState();
}

class _IntetrestscreenState extends State<Intetrestscreen> {
  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What are your interests?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select up to 15 interests to make your profile stand out!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<InterestProvider>(
                builder: (context, provider, child) {

                  // Group interests by category
                  Map<String, List<Interest>> groupedInterests = {};
                  for (var interest in provider.interests) {
                    if (!groupedInterests.containsKey(interest.category)) {
                      groupedInterests[interest.category] = [];
                    }
                    groupedInterests[interest.category]!.add(interest);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(8.0),
                          children: groupedInterests.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(

                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(11)
                                    ),
                                    // Change this color as needed
                                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                ...entry.value.map((interest) {
                                  final isSelected = provider.isSelected(interest);
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    title: Row(
                                      children: [
                                        Text(
                                          interest.icon,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            interest.option,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    tileColor: isSelected ? Colors.black : Colors.white,
                                    textColor: isSelected ? Colors.white : Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    onTap: (){
                                      provider.toggleInterest(interest);

                                    },
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          onPressed: provider.selectedInterests.isNotEmpty
                              ? () => _submitInterests()
                              : null,
                          child: Text(
                            'Select (${provider.selectedInterests.length})',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // Submit interests and navigate to the next screen
  void _submitInterests() {
    final interestProvider = Provider.of<InterestProvider>(context, listen: false);

    if (interestProvider.selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print("Selected Interests: ${interestProvider.selectedInterests.map((i) => i.option).toList()}");



    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.nextScreen();

    // Get name, date of birth, and profile image path from the provider
    final nameAgeProvider = Provider.of<NameAgeProvider>(context, listen: false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProfileCompletionScreen(
          fullName: nameAgeProvider.fullName,
          dateOfBirth: nameAgeProvider.dateOfBirth,
          imagePath: nameAgeProvider.profileImagePath,
        ),
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
}
