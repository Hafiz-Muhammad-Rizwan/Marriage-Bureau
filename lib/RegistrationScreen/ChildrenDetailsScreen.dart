import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/MoveAbroad.dart';
import 'package:marriage_bereau_app/RegistrationScreen/SiblingsScreen.dart';
import 'package:provider/provider.dart';

class ChildrenDetailsScreen extends StatefulWidget {
  const ChildrenDetailsScreen({super.key});

  @override
  State<ChildrenDetailsScreen> createState() => _ChildrenDetailsScreenState();
}

class _ChildrenDetailsScreenState extends State<ChildrenDetailsScreen> {
  int _totalChildren = 1;
  int _sons = 0;
  int _daughters = 0;

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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many children do you have?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  // Total children selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Number of Children',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _totalChildren > 1
                                ? () => setState(() {
                                    _totalChildren--;
                                    _updateSonsAndDaughters();
                                  })
                                : null,
                              icon: Icon(Icons.remove_circle),
                              color: _totalChildren > 1 ? Colors.pink : Colors.grey,
                              iconSize: 36,
                            ),
                            SizedBox(width: 20),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.pink.withOpacity(0.1),
                              ),
                              child: Text(
                                '$_totalChildren',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              onPressed: _totalChildren < 10
                                ? () => setState(() {
                                    _totalChildren++;
                                    _updateSonsAndDaughters();
                                  })
                                : null,
                              icon: Icon(Icons.add_circle),
                              color: _totalChildren < 10 ? Colors.pink : Colors.grey,
                              iconSize: 36,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Sons and daughters selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How many sons and daughters?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Sons selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sons:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _sons > 0
                                    ? () => setState(() {
                                        _sons--;
                                        _updateTotalChildren();
                                      })
                                    : null,
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: _sons > 0 ? Colors.blue : Colors.grey,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.blue.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    '$_sons',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _sons < _totalChildren
                                    ? () => setState(() {
                                        _sons++;
                                        _updateTotalChildren();
                                      })
                                    : null,
                                  icon: Icon(Icons.add_circle_outline),
                                  color: _sons < _totalChildren ? Colors.blue : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Daughters selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daughters:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _daughters > 0
                                    ? () => setState(() {
                                        _daughters--;
                                        _updateTotalChildren();
                                      })
                                    : null,
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: _daughters > 0 ? Colors.pink : Colors.grey,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.pink.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    '$_daughters',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _daughters < _totalChildren
                                    ? () => setState(() {
                                        _daughters++;
                                        _updateTotalChildren();
                                      })
                                    : null,
                                  icon: Icon(Icons.add_circle_outline),
                                  color: _daughters < _totalChildren ? Colors.pink : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Error message if sons + daughters doesn't match total
                  if (_sons + _daughters != _totalChildren)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'The sum of sons and daughters should equal your total number of children.',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 40),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_sons + _daughters == _totalChildren)
                          ? () async {
                              // Update the children provider with detailed information
                              final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
                              childrenProvider.setChildrenDetails(_totalChildren, _sons, _daughters);

                              // Proceed to next screen
                              final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                              progressProvider.nextScreen();
                              await Future.delayed(Duration(milliseconds: 500));
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
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Update the total number of children based on sons and daughters
  void _updateTotalChildren() {
    if (_sons + _daughters > _totalChildren) {
      setState(() {
        _totalChildren = _sons + _daughters;
      });
    }
  }

  // Update sons and daughters when total changes
  void _updateSonsAndDaughters() {
    if (_sons + _daughters > _totalChildren) {
      int diff = (_sons + _daughters) - _totalChildren;

      // First reduce daughters, then sons if needed
      if (_daughters >= diff) {
        setState(() {
          _daughters -= diff;
        });
      } else {
        setState(() {
          diff -= _daughters;
          _daughters = 0;
          _sons -= diff;
        });
      }
    }
  }
}
