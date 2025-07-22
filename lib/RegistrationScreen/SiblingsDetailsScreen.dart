import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/ChildrenScreen.dart';
import 'package:marriage_bereau_app/RegistrationScreen/MoveAbroad.dart';
import 'package:provider/provider.dart';

class SiblingsDetailsScreen extends StatefulWidget {
  const SiblingsDetailsScreen({super.key});

  @override
  State<SiblingsDetailsScreen> createState() => _SiblingsDetailsScreenState();
}

class _SiblingsDetailsScreenState extends State<SiblingsDetailsScreen> {
  int _totalSiblings = 1;
  int _brothers = 0;
  int _sisters = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with values from provider
    final siblingsProvider = Provider.of<SiblingsProvider>(context, listen: false);
    _totalSiblings = siblingsProvider.totalSiblings > 0 ? siblingsProvider.totalSiblings : 1;
    _brothers = siblingsProvider.brothers;
    _sisters = siblingsProvider.sisters;
  }

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
                    'How many siblings do you have?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  // Total siblings selection
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
                          'Total Number of Siblings',
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
                              onPressed: _totalSiblings > 1
                                ? () => setState(() {
                                    _totalSiblings--;
                                    _updateSiblingsDistribution();
                                  })
                                : null,
                              icon: Icon(Icons.remove_circle),
                              color: _totalSiblings > 1 ? Colors.pink : Colors.grey,
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
                                '$_totalSiblings',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              onPressed: _totalSiblings < 10
                                ? () => setState(() {
                                    _totalSiblings++;
                                    _updateSiblingsDistribution();
                                  })
                                : null,
                              icon: Icon(Icons.add_circle),
                              color: _totalSiblings < 10 ? Colors.pink : Colors.grey,
                              iconSize: 36,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Brothers and sisters selection
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
                          'How many brothers and sisters?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Brothers selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Brothers:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _brothers > 0
                                    ? () => setState(() {
                                        _brothers--;
                                        _updateTotalSiblings();
                                      })
                                    : null,
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: _brothers > 0 ? Colors.blue : Colors.grey,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.blue.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    '$_brothers',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _brothers < _totalSiblings
                                    ? () => setState(() {
                                        _brothers++;
                                        _updateTotalSiblings();
                                      })
                                    : null,
                                  icon: Icon(Icons.add_circle_outline),
                                  color: _brothers < _totalSiblings ? Colors.blue : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Sisters selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sisters:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _sisters > 0
                                    ? () => setState(() {
                                        _sisters--;
                                        _updateTotalSiblings();
                                      })
                                    : null,
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: _sisters > 0 ? Colors.pink : Colors.grey,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.pink.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    '$_sisters',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _sisters < _totalSiblings
                                    ? () => setState(() {
                                        _sisters++;
                                        _updateTotalSiblings();
                                      })
                                    : null,
                                  icon: Icon(Icons.add_circle_outline),
                                  color: _sisters < _totalSiblings ? Colors.pink : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Error message if brothers + sisters doesn't match total
                  if (_brothers + _sisters != _totalSiblings)
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
                              'The sum of brothers and sisters should equal your total number of siblings.',
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
                      onPressed: (_brothers + _sisters == _totalSiblings)
                          ? () async {
                              // Update the siblings provider with detailed information
                              final siblingsProvider = Provider.of<SiblingsProvider>(context, listen: false);
                              siblingsProvider.setSiblingsDetails(_totalSiblings, _brothers, _sisters);

                              // Proceed to next screen
                              final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                              progressProvider.nextScreen();
                              await Future.delayed(Duration(milliseconds: 500));
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => Moveabroad(),
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

  // Update the total number of siblings based on brothers and sisters
  void _updateTotalSiblings() {
    if (_brothers + _sisters > _totalSiblings) {
      setState(() {
        _totalSiblings = _brothers + _sisters;
      });
    }
  }

  // Update brothers and sisters when total changes
  void _updateSiblingsDistribution() {
    if (_brothers + _sisters > _totalSiblings) {
      int diff = (_brothers + _sisters) - _totalSiblings;

      // First reduce sisters, then brothers if needed
      if (_sisters >= diff) {
        setState(() {
          _sisters -= diff;
        });
      } else {
        setState(() {
          diff -= _sisters;
          _sisters = 0;
          _brothers -= diff;
        });
      }
    }
  }
}
