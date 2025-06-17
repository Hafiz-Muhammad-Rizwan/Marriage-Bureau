import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SmokeScreen.dart';
import 'package:provider/provider.dart';
class Halalfood extends StatefulWidget {
  const Halalfood({super.key});

  @override
  State<Halalfood> createState() => _HalalfoodState();
}

class _HalalfoodState extends State<Halalfood> {
  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Do you only eat Halal food?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Consumer<HalalFoodProvider>(
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
                      onTap: ()async {
                        provider.selectOption(option);
                        await Future.delayed(Duration(milliseconds: 500));
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => Smokescreen(),
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
  }
}
