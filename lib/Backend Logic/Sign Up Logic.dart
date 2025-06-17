import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SignUp extends ChangeNotifier
{
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  Future<String?>signUp(String Email,String Password)async
  {
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: Email,
        password: Password,
      );
      return null;
    }on FirebaseAuthException catch(e)
    {
      return e.message;
    }catch(e)
    {
      return 'Some thing Wrong';
    }
  }

  // Api call for the Countries

}


class Country {
  final String name;
  final String flag;

  Country({required this.name, required this.flag});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'],
      flag: json['flags']['png'],
    );
  }
}
class countryData extends ChangeNotifier
{
  List<Country> _countries = [];
  final Set<String> _selectedNationalities = {};

  List<Country> get countries => _countries;
  Set<String> get selectedNationalities => _selectedNationalities;

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _countries = data.map((json) => Country.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  void toggleNationality(String name, bool value) {
    if (value) {
      if (_selectedNationalities.length < 10) {
        _selectedNationalities.add(name);
      }
    } else {
      _selectedNationalities.remove(name);
    }
    notifyListeners();
  }}

// Height Screen
class Height {
  final int cm;
  final String inches;

  Height(this.cm, this.inches);
}

class HeightProvider extends ChangeNotifier {
  Height? _selectedHeight;
  final List<Height> _heights = [
    Height(122, "4'0\""),
    Height(124, "4'1\""),
    Height(127, "4'2\""),
    Height(130, "4'3\""),
    Height(132, "4'4\""),
    Height(135, "4'5\""),
    Height(137, "4'6\""),
    Height(140, "4'7\""),
    Height(142, "4'8\""),
    Height(145, "4'9\""),
    Height(147, "4'10\""),
    Height(150, "4'11\""),
    Height(152, "5'0\""),
    Height(155, "5'1\""),
    Height(157, "5'2\""),
    Height(160, "5'3\""),
    Height(163, "5'4\""),
    Height(165, "5'5\""),
    Height(168, "5'6\""),
    Height(170, "5'7\""),
    Height(173, "5'8\""),
    Height(175, "5'9\""),
    Height(178, "5'10\""),
    Height(180, "5'11\""),
    Height(183, "6'0\""),
    Height(185, "6'1\""),
    Height(188, "6'2\""),
    Height(190, "6'3\""),
    Height(193, "6'4\""),
    Height(195, "6'5\""),
    Height(198, "6'6\""),
  ];


  Height? get selectedHeight {
    return _selectedHeight;
  }
  List<Height> get heights {
    return _heights;
  }

  void selectHeight(Height height) {
    _selectedHeight = height;
    notifyListeners();
  }
}
// Marital Status Screen
class MaritalStatus {
  final String status;

  MaritalStatus(this.status);
}

class MaritalStatusProvider extends ChangeNotifier {
  MaritalStatus? _selectedStatus;
  final List<MaritalStatus> _statuses = [
    MaritalStatus('Never married'),
    MaritalStatus('Divorced'),
    MaritalStatus('Separated'),
    MaritalStatus('Annulled'),
    MaritalStatus('Widowed'),
    MaritalStatus('Married'),
  ];

  MaritalStatus? get selectedStatus => _selectedStatus;
  List<MaritalStatus> get statuses => _statuses;

  void selectStatus(MaritalStatus status) {
    _selectedStatus = status;
    notifyListeners();
  }
}

//Relegion Practice Screen
class ReligiousPractice {
  final String status;

  ReligiousPractice(this.status);
}

class ReligiousPracticeProvider with ChangeNotifier {
  ReligiousPractice? _selectedPractice;
  final List<ReligiousPractice> _practices = [
    ReligiousPractice('Very practising'),
    ReligiousPractice('Practising'),
    ReligiousPractice('Moderately practising'),
    ReligiousPractice('Not practising'),
  ];

  ReligiousPractice? get selectedPractice => _selectedPractice;
  List<ReligiousPractice> get practices => _practices;

  void selectPractice(ReligiousPractice practice) {
    _selectedPractice = practice;
    notifyListeners();
  }
}
// Pray Screen how often you pray
class PrayerFrequency {
  final String frequency;

  PrayerFrequency(this.frequency);
}

class PrayerFrequencyProvider extends ChangeNotifier {
  PrayerFrequency? _selectedFrequency;
  final List<PrayerFrequency> _frequencies = [
    PrayerFrequency('Always prays'),
    PrayerFrequency('Usually prays'),
    PrayerFrequency('Sometimes prays'),
    PrayerFrequency('Never prays'),
  ];

  PrayerFrequency? get selectedFrequency => _selectedFrequency;
  List<PrayerFrequency> get frequencies => _frequencies;

  void selectFrequency(PrayerFrequency frequency) {
    _selectedFrequency = frequency;
    notifyListeners();
  }
}

// Halal Food Screen
class HalalFood {
  final String option;

  HalalFood(this.option);
}
class HalalFoodProvider extends ChangeNotifier {
  HalalFood? _selectedOption;
  final List<HalalFood> _options = [
    HalalFood('Yes'),
    HalalFood('No'),
  ];

  HalalFood? get selectedOption => _selectedOption;
  List<HalalFood> get options => _options;

  void selectOption(HalalFood option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Smoke Screen

class Smoking {
  final String option;

  Smoking(this.option);
}
class SmokingProvider extends ChangeNotifier {
  Smoking? _selectedOption;
  final List<Smoking> _options = [
    Smoking('Yes'),
    Smoking('No'),
  ];

  Smoking? get selectedOption => _selectedOption;
  List<Smoking> get options => _options;

  void selectOption(Smoking option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Alchol Screen
class AlcoholConsumption {
  final String option;

  AlcoholConsumption(this.option);
}

class AlcoholConsumptionProvider extends ChangeNotifier {
  AlcoholConsumption? _selectedOption;
  final List<AlcoholConsumption> _options = [
    AlcoholConsumption('Yes'),
    AlcoholConsumption('No'),
  ];

  AlcoholConsumption? get selectedOption => _selectedOption;
  List<AlcoholConsumption> get options => _options;

  void selectOption(AlcoholConsumption option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Children Screen
class Children {
  final String option;

  Children(this.option);
}
class ChildrenProvider extends ChangeNotifier {
  Children? _selectedOption;
  final List<Children> _options = [
    Children('Yes'),
    Children('No'),
  ];

  Children? get selectedOption => _selectedOption;
  List<Children> get options => _options;

  void selectOption(Children option) {
    _selectedOption = option;
    notifyListeners();
  }
}
// Moving Abroad Screen
class MoveAbroad {
  final String option;

  MoveAbroad(this.option);
}
class MoveAbroadProvider with ChangeNotifier {
  MoveAbroad? _selectedOption;
  final List<MoveAbroad> _options = [
    MoveAbroad('Yes'),
    MoveAbroad('No'),
  ];

  MoveAbroad? get selectedOption => _selectedOption;
  List<MoveAbroad> get options => _options;

  void selectOption(MoveAbroad option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Born Muslim
class BornMuslim {
  final String option;

  BornMuslim(this.option);
}

class BornMuslimProvider with ChangeNotifier {
  BornMuslim? _selectedOption;
  final List<BornMuslim> _options = [
    BornMuslim('Yes'),
    BornMuslim('No'),
  ];

  BornMuslim? get selectedOption => _selectedOption;
  List<BornMuslim> get options => _options;

  void selectOption(BornMuslim option) {
    _selectedOption = option;
    notifyListeners();
  }
}


// Intrest Screen
class Interest {
  final String category;
  final String option;
  final String icon;

  Interest(this.category, this.option, this.icon);
}

class InterestProvider extends ChangeNotifier {
  final List<Interest> _interests = [
    Interest('Arts & Culture', 'Acting', '🎭'),
    Interest('Arts & Culture', 'Anime', '🍿'),
    Interest('Arts & Culture', 'Art galleries', '🖼️'),
    Interest('Arts & Culture', 'Board games', '🎲'),
    Interest('Arts & Culture', 'Creative writing', '✍️'),
    Interest('Arts & Culture', 'Design', '🎨'),
    Interest('Arts & Culture', 'DIY', '🔧'),
    Interest('Arts & Culture', 'Fashion', '👗'),
    Interest('Arts & Culture', 'Film & Cinema', '🎬'),
    Interest('Arts & Culture', 'Filmmaking', '📽️'),
    Interest('Arts & Culture', 'Knitting', '🧶'),
    Interest('Arts & Culture', 'Learning languages', '🌐'),
    Interest('Arts & Culture', 'Live music', '🎵'),
    Interest('Arts & Culture', 'Museums', '🏛️'),
    Interest('Arts & Culture', 'Painting', '🎨'),
    Interest('Arts & Culture', 'Photography', '📸'),
    Interest('Politics', 'Politics', '🏛️'),
    Interest('Social', 'Spending time with friends', '👥'),
    Interest('Social', 'Volunteering', '🤲'),
    Interest('Food & Drink', 'Baking', '🧁'),
    Interest('Food & Drink', 'Bubble tea', '🍵'),
    Interest('Food & Drink', 'Cake decorating', '🎂'),
    Interest('Food & Drink', 'Chocolate', '🍫'),
    Interest('Food & Drink', 'Coffee', '☕'),
    Interest('Food & Drink', 'Cooking', '🍳'),
    Interest('Food & Drink', 'Eating out', '🍽️'),
    Interest('Food & Drink', 'Fish & chips', '🐟'),
    Interest('Food & Drink', 'Healthy eating', '🥗'),
    Interest('Food & Drink', 'Junk food', '🍔'),
    Interest('Islamic', 'Arba', '🕌'),
    Interest('Islamic', 'Ashura', '🌙'),
    Interest('Islamic', 'Charity', '🤲'),
    Interest('Islamic', 'Completed Hajj', '🕋'),
    Interest('Islamic', 'Completed Umrah', '🕌'),
    Interest('Islamic', 'Duaa for others', '🙏'),
    Interest('Islamic', 'Fasting', '🍽️'),
    Interest('Islamic', 'Hafith', '📖'),
    Interest('Islamic', 'Islamic events', '🎉'),
    Interest('Islamic', 'Islamic lectures', '🎙️'),
    Interest('Islamic', 'Islamic studies', '📚'),
    Interest('Islamic', 'Khatam', '📜'),
    Interest('Islamic', 'Learning Arabic', '🇦🇪'),
    Interest('Islamic', 'Masjid regularly', '🏟️'),
    Interest('Islamic', 'Mawlid', '🎂'),
    Interest('Islamic', 'Muharram', '🌙'),
    Interest('Islamic', 'Reading Qur\'an', '📖'),
    Interest('Islamic', 'Voluntary prayers', '🙏'),
    Interest('Sports', 'Surfing', '🏄'),
    Interest('Sports', 'Swimming', '🏊'),
    Interest('Sports', 'Tennis', '🎾'),
    Interest('Sports', 'Volleyball', '🏐'),
    Interest('Sports', 'Yoga', '🧘'),
    Interest('Sports', 'Playing', '🎮'), // Added interest
    Interest('Technology', 'Animation', '🎬'),
    Interest('Technology', 'Blogging', '📝'),
    Interest('Technology', 'Coding', '💻'),
    Interest('Technology', 'Content creation', '📹'),
    Interest('Technology', 'Digital art', '🖌️'),
    Interest('Technology', 'Influencer', '⭐'),
    Interest('Technology', 'Live streaming', '📡'),
    Interest('Technology', 'Tech', '🤖'),
    Interest('Technology', 'Video games', '🎮'),
  ];

  final Set<Interest> _selectedInterests = {};
  static const int maxSelections = 15;

  Set<Interest> get selectedInterests {
    return _selectedInterests;
  }
  List<Interest> get interests => _interests;

  void toggleInterest(Interest interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else if (_selectedInterests.length < maxSelections) {
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

  bool isSelected(Interest interest) => _selectedInterests.contains(interest);
}

