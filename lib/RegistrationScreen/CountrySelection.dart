
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/HeightScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/photoUploadScreen.dart';
import 'package:provider/provider.dart';

class countrySelection extends StatefulWidget
{
  @override
  const countrySelection({super.key});
  State<countrySelection>createState()=>countrySelectionState();
}
class countrySelectionState extends State<countrySelection>
{
  @override
  Widget build(BuildContext context) {
        return Consumer2<countryData,ProgressProvider>(
          builder: (context, provider,progressProvider, child) {
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
                      'Please choose countries you hold citizenship with.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        if (provider.selectedNationalities.isNotEmpty)
                          Container(
                            color: Colors.grey[200],
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text(
                              'Suggested',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (provider.selectedNationalities.contains('Pakistani'))
                          CheckboxListTile(
                            title: Text('🇵🇰 Pakistani'),
                            value: provider.selectedNationalities.contains('Pakistani'),
                            onChanged: (value) => provider.toggleNationality('Pakistani', value!),
                            secondary: provider.selectedNationalities.contains('Pakistani')
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                        Divider(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('All', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...provider.countries.map((country) {
                          return CheckboxListTile(
                            title: Row(
                              children: [
                                Image.network(
                                  country.flag,
                                  width: 30,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                ),
                                SizedBox(width: 10),
                                Expanded(child: Text(country.name)),
                              ],
                            ),
                            value: provider.selectedNationalities.contains(country.name),
                            onChanged: (value) => provider.toggleNationality(country.name, value!),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(270, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: Colors.pink.withOpacity(0.5),
                      ),
                      onPressed: provider.selectedNationalities.isNotEmpty
                          ? (){
                        final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                        progressProvider.nextScreen();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => HeightScreen(),
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
                          : null,
                      child:  Text(
                        'Confirm (${provider.selectedNationalities.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),

                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }