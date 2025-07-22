import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/RegistrationScreen/GuardianScreen.dart';
import 'package:provider/provider.dart';

import '../Backend Logic/Sign Up Logic.dart';
import '../Essentials/colors.dart';



class HomeDetailsScreen extends StatefulWidget {
  HomeDetailsScreen({super.key});

  @override
  State<HomeDetailsScreen> createState() => _HomeDetailsScreenState();
}

class _HomeDetailsScreenState extends State<HomeDetailsScreen> {
  List<String> homeOptions = ["Rent", "Own Home", "Lease"];
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitHomeDetails() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    print(homeProvider.address);
    print(homeProvider.city);
    print(homeProvider.country);
    print(homeProvider.selectedHome);
    if (!homeProvider.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    progressProvider.nextScreen();
    Navigator.push(context, MaterialPageRoute(builder: (context) => GuardianScreen()));
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;
    final homeProvider = Provider.of<HomeProvider>(context);
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
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[100]!],
              ),
            ),
            child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Select Home Status",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: homeOptions.map((option) {
                        final isSelected = homeProvider.selectedHome == option;
                        return ChoiceChip(
                          label: Text(option,style: TextStyle(fontSize: 16),),
                          selected: isSelected,
                          selectedColor: pinkColor,
                          onSelected: (_) => homeProvider.setHome(option),
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black),
                          backgroundColor: Colors.grey.shade200,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text("Country",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _countryController,
                      onChanged: (value){
                        homeProvider.setCountry(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Enter country",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: pinkColor)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("City",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _cityController,
                      onChanged: (value){
                        homeProvider.setCity(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Enter City",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: pinkColor)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Street Address",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
                      onChanged: (value){
                        print(value);
                        homeProvider.setAddress(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Enter street address",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: pinkColor)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitHomeDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: pinkColor.withOpacity(0.5),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                )
            )
        ));
    });
  }
}
