import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController=TextEditingController();
  final TextEditingController _dobController=TextEditingController();
  DateTime?_selectedDate;
  String? _selectedEducation;
  String? _selectedAlcoholOption;
  String?_selectBornMuslim;
  String? _selectedChildren;
  String? _selectedHeight;
  String? _selectedMaritalStatus;
  String? _selectedMoveAbroad;
  String? _selectedPrayFrequency;
  String? _selectedProfession;
  String? _selectedReligiousPractice;
  String? _selectedSect;
  String? _selectedSmoke;
  String? _selectedHalalFood;

  final List<String> _educationLevels = [
    "High School",
    "Diploma",
    "Undergraduate (Bachelor's)",
    "Postgraduate (Master's)",
    "Doctorate (PhD)",
    "Vocational Training",
    "Other",
  ];
  final List<String> _childrenOptions = [
    "No children",
    "1 child",
    "2 children",
    "3 children",
    "4 or more children",
    "Prefer not to say"
  ];

  final List<String> _heightOptions = [
    "4'7\" - 140cm",
    "4'8\" - 142cm",
    "4'9\" - 145cm",
    "4'10\" - 147cm",
    "4'11\" - 150cm",
    "5'0\" - 152cm",
    "5'1\" - 155cm",
    "5'2\" - 157cm",
    "5'3\" - 160cm",
    "5'4\" - 163cm",
    "5'5\" - 165cm",
    "5'6\" - 168cm",
    "5'7\" - 170cm",
    "5'8\" - 173cm",
    "5'9\" - 175cm",
    "5'10\" - 178cm",
    "5'11\" - 180cm",
    "6'0\" - 183cm",
    "6'1\" - 185cm",
    "6'2\" - 188cm",
    "6'3\" - 190cm",
    "6'4\" or taller - 193cm+"
  ];

  final List<String> _maritalStatusOptions = [
    "Never Married",
    "Divorced",
    "Widowed",
    "Separated"
  ];

  final List<String> _moveAbroadOptions = [
    "Yes, willing to move abroad",
    "No, not willing to move abroad",
    "Maybe, depending on circumstances"
  ];

  final List<String> _prayFrequencyOptions = [
    "Five times a day",
    "Most of the five prayers",
    "Some of the five prayers",
    "Jummah only",
    "Occasionally",
    "Rarely",
    "Never pray"
  ];

  final List<String> _professionOptions = [
    "Engineer",
    "Doctor",
    "Teacher",
    "Software Developer",
    "Accountant",
    "Artist",
    "Lawyer",
    "Nurse",
    "Architect",
    "Businessman/woman",
    "Student",
    "Homemaker",
    "Government Employee",
    "Marketing Professional",
    "Sales Professional",
    "Journalist",
    "Designer",
    "Chef",
    "Electrician",
    "Plumber",
    "Mechanic",
    "Farmer",
    "Photographer",
    "Writer",
    "Consultant",
    "Entrepreneur",
    "Scientist",
    "Researcher",
    "Pilot",
    "Dentist",
    "Pharmacist",
    "Other"
  ];

  final List<String> _religiousPracticeOptions = [
    "Very religious",
    "Moderately religious",
    "Somewhat religious",
    "Not very religious",
    "Not religious at all"
  ];

  final List<String> _sectOptions = [
    "Sunni",
    "Shia",
    "Deobandi",
    "Wahabi",
    "Other"
  ];

  final List<String> _smokeOptions = [
    "Yes, I smoke",
    "No, I don't smoke",
    "Used to, but quit",
    "Occasionally"
  ];

  final List<String> _halalFoodOptions = [
    "Yes, strictly",
    "Most of the time",
    "Not always",
    "No"
  ];

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void>_selectDate(BuildContext context)async{
    final DateTime?picked=await showDatePicker(
        context: context,
        initialDate: _selectedDate??DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      builder: (context,child){
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.pink,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.pink,
                ),
              ),
            ),
            child: child!,
          );

      }
    );
    if(picked!=null && picked!=_selectedDate){
      setState(() {
        _selectedDate=picked;
        _dobController.text="${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Generic bottom sheet for options selection
  void _showOptionsBottomSheet({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
    IconData? prefixIcon,
  }) {
    String? tempSelected = selectedValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String option = options[index];
                        bool isSelected = tempSelected == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              option,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            tileColor: isSelected ? Colors.pink[50] : null,
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.pink) : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? Colors.pink : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            onTap: () {
                              setModalState(() {
                                tempSelected = option;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (tempSelected != null) {
                        setState(() {
                          onSelect(tempSelected!);
                        });
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Confirm Selection",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for selection fields
  Widget _buildSelectionField({
    required String label,
    required String? selectedValue,
    required String placeholder,
    required VoidCallback onTap,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                Icon(prefixIcon, color: Colors.pink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedValue ?? placeholder,
                    style: TextStyle(
                      color: selectedValue != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Replace individual pickers with generic bottom sheet
  void _showEducationLevelPicker() {
    _showOptionsBottomSheet(
      title: "Select Your Education Level",
      options: _educationLevels,
      selectedValue: _selectedEducation,
      onSelect: (value) {
        _selectedEducation = value;
      },
      prefixIcon: Icons.school,
    );
  }

  void _showAlcoholOptionsSheet() {
    _showOptionsBottomSheet(
      title: "Do you drink alcohol?",
      options: ["Never", "Occasionally", "Socially", "Regularly", "Prefer not to say"],
      selectedValue: _selectedAlcoholOption,
      onSelect: (value) {
        _selectedAlcoholOption = value;
      },
      prefixIcon: Icons.local_bar,
    );
  }

  void showBornMuslim() {
    _showOptionsBottomSheet(
      title: "Are you born Muslim?",
      options: ["Yes", "No", "Prefer not to say"],
      selectedValue: _selectBornMuslim,
      onSelect: (value) {
        setState(() {
          _selectBornMuslim = value;
        });
      },
      prefixIcon: Icons.person,
    );
  }
  void _saveChanges() {
    // Validate age
    if (_selectedDate != null) {
      final int age = DateTime.now().year - _selectedDate!.year;
      if (age < 18 || (age == 18 && (DateTime.now().month < _selectedDate!.month ||
          (DateTime.now().month == _selectedDate!.month && DateTime.now().day < _selectedDate!.day)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be 18 years or older!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // This will be where you save data to Firebase later
    // For now, just show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully!', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void initState(){
    super.initState();
    // Initialize any necessary data or state here and Firebase
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editing Profile",
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
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/Images/man.jpeg') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _showImageSourceOptions,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Tap the camera icon to update your profile picture",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Edit Your Profile Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
                ],
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  labelText: "Full Name",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.person, color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Date of Birth",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
                    ],
                  ),
                  child: TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: "Select your date of birth",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.pink),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSelectionField(
              label: "Education Level",
              selectedValue: _selectedEducation,
              placeholder: "Select your education level",
              onTap: _showEducationLevelPicker,
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: 30),
            // Alcohol Consumption field
            _buildSelectionField(
              label: "Alcohol Consumption",
              selectedValue: _selectedAlcoholOption,
              placeholder: "Select your alcohol preference",
              onTap: _showAlcoholOptionsSheet,
              prefixIcon: Icons.local_bar,
            ),
            const SizedBox(height: 30),
            // Born Muslim field
            _buildSelectionField(
              label: "Born Muslim",
              selectedValue: _selectBornMuslim,
              placeholder: "Select born Muslim status",
              onTap: showBornMuslim,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 30),
            // Children field
            _buildSelectionField(
              label: "Children",
              selectedValue: _selectedChildren,
              placeholder: "Select your children status",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Children Status",
                  options: _childrenOptions,
                  selectedValue: _selectedChildren,
                  onSelect: (value) {
                    setState(() {
                      _selectedChildren = value;
                    });
                  },
                  prefixIcon: Icons.child_care,
                );
              },
              prefixIcon: Icons.child_care,
            ),
            const SizedBox(height: 30),
            // Height field
            _buildSelectionField(
              label: "Height",
              selectedValue: _selectedHeight,
              placeholder: "Select your height",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Height",
                  options: _heightOptions,
                  selectedValue: _selectedHeight,
                  onSelect: (value) {
                    setState(() {
                      _selectedHeight = value;
                    });
                  },
                  prefixIcon: Icons.height,
                );
              },
              prefixIcon: Icons.height,
            ),
            const SizedBox(height: 30),
            // Marital Status field
            _buildSelectionField(
              label: "Marital Status",
              selectedValue: _selectedMaritalStatus,
              placeholder: "Select your marital status",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Marital Status",
                  options: _maritalStatusOptions,
                  selectedValue: _selectedMaritalStatus,
                  onSelect: (value) {
                    setState(() {
                      _selectedMaritalStatus = value;
                    });
                  },
                  prefixIcon: Icons.favorite, // Changed from Icons.wedding
                );
              },
              prefixIcon: Icons.favorite, // Changed from Icons.wedding
            ),
            const SizedBox(height: 30),
            // Move Abroad field
            _buildSelectionField(
              label: "Move Abroad",
              selectedValue: _selectedMoveAbroad,
              placeholder: "Select your preference about moving abroad",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Preference About Moving Abroad",
                  options: _moveAbroadOptions,
                  selectedValue: _selectedMoveAbroad,
                  onSelect: (value) {
                    setState(() {
                      _selectedMoveAbroad = value;
                    });
                  },
                  prefixIcon: Icons.public,
                );
              },
              prefixIcon: Icons.public,
            ),
            const SizedBox(height: 30),
            // Prayer Frequency field
            _buildSelectionField(
              label: "Prayer Frequency",
              selectedValue: _selectedPrayFrequency,
              placeholder: "Select your prayer frequency",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Prayer Frequency",
                  options: _prayFrequencyOptions,
                  selectedValue: _selectedPrayFrequency,
                  onSelect: (value) {
                    setState(() {
                      _selectedPrayFrequency = value;
                    });
                  },
                  prefixIcon: Icons.access_time,
                );
              },
              prefixIcon: Icons.access_time,
            ),
            const SizedBox(height: 30),
            // Profession field
            _buildSelectionField(
              label: "Profession",
              selectedValue: _selectedProfession,
              placeholder: "Select your profession",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Profession",
                  options: _professionOptions,
                  selectedValue: _selectedProfession,
                  onSelect: (value) {
                    setState(() {
                      _selectedProfession = value;
                    });
                  },
                  prefixIcon: Icons.work,
                );
              },
              prefixIcon: Icons.work,
            ),
            const SizedBox(height: 30),
            // Religious Practice field
            _buildSelectionField(
              label: "Religious Practice",
              selectedValue: _selectedReligiousPractice,
              placeholder: "Select your religious practice level",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Religious Practice Level",
                  options: _religiousPracticeOptions,
                  selectedValue: _selectedReligiousPractice,
                  onSelect: (value) {
                    setState(() {
                      _selectedReligiousPractice = value;
                    });
                  },
                  prefixIcon: Icons.mosque, // Changed from Icons.religion
                );
              },
              prefixIcon: Icons.mosque, // Changed from Icons.religion
            ),
            const SizedBox(height: 30),
            // Sect field
            _buildSelectionField(
              label: "Sect",
              selectedValue: _selectedSect,
              placeholder: "Select your sect",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Sect",
                  options: _sectOptions,
                  selectedValue: _selectedSect,
                  onSelect: (value) {
                    setState(() {
                      _selectedSect = value;
                    });
                  },
                  prefixIcon: Icons.group,
                );
              },
              prefixIcon: Icons.group,
            ),
            const SizedBox(height: 30),
            // Smoke field
            _buildSelectionField(
              label: "Smoke",
              selectedValue: _selectedSmoke,
              placeholder: "Select your smoking status",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Smoking Status",
                  options: _smokeOptions,
                  selectedValue: _selectedSmoke,
                  onSelect: (value) {
                    setState(() {
                      _selectedSmoke = value;
                    });
                  },
                  prefixIcon: Icons.smoke_free,
                );
              },
              prefixIcon: Icons.smoke_free,
            ),
            const SizedBox(height: 30),
            // Halal Food field
            _buildSelectionField(
              label: "Halal Food",
              selectedValue: _selectedHalalFood,
              placeholder: "Select your halal food preference",
              onTap: () {
                _showOptionsBottomSheet(
                  title: "Select Your Halal Food Preference",
                  options: _halalFoodOptions,
                  selectedValue: _selectedHalalFood,
                  onSelect: (value) {
                    setState(() {
                      _selectedHalalFood = value;
                    });
                  },
                  prefixIcon: Icons.food_bank,
                );
              },
              prefixIcon: Icons.food_bank,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {

                Navigator.pop(context, _image);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}