import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SiblingsDetailsScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ChildrenScreen.dart';
import 'package:provider/provider.dart';

class SiblingsScreen extends StatefulWidget {
  const SiblingsScreen({super.key});

  @override
  State<SiblingsScreen> createState() => _SiblingsScreenState();
}

class _SiblingsScreenState extends State<SiblingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Marriage Bureau",
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
                  'Do you have siblings?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Please tell us about your brothers and sisters',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Consumer<SiblingsProvider>(
                  builder: (context, provider, child) {
                    return ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        _buildOptionCard(
                          context: context,
                          title: 'Yes',
                          subtitle: 'I have brothers and/or sisters',
                          icon: Icons.people_alt,
                          isSelected: provider.hasSiblings == true,
                          onTap: () async {
                            provider.setHasSiblings(true);

                            final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                            progressProvider.nextScreen();

                            await Future.delayed(Duration(milliseconds: 300));
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => SiblingsDetailsScreen(),
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
                        ),
                        SizedBox(height: 16),
                        _buildOptionCard(
                          context: context,
                          title: 'No',
                          subtitle: 'I don\'t have any siblings',
                          icon: Icons.person,
                          isSelected: provider.hasSiblings == false,
                          onTap: () async {
                            provider.setHasSiblings(false);

                            final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                            progressProvider.nextScreen();

                            await Future.delayed(Duration(milliseconds: 300));
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => Childrenscreen(),
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
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.pink : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink.shade100 : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.pink : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.pink : Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.pink,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
