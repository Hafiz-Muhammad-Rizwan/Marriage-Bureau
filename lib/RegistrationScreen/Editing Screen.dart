// filepath: d:\Clone Repository\Marriage-Bureau\lib\RegistrationScreen\Editing Screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marriage_bereau_app/Screens/signUpScreen.dart';
import 'package:marriage_bereau_app/Services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  File? _image;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _guardianControler=TextEditingController();
  final TextEditingController _guardianNumberControler=TextEditingController();
  final TextEditingController _addressControler=TextEditingController();
  final TextEditingController _cityControler=TextEditingController();
  final TextEditingController _countryControler=TextEditingController();
  DateTime? _selectedDate;
  String? _selectedEducation;
  String? _selectedAlcoholOption;
  String? _selectedChildren;
  int _totalChildren = 1;
  int _sons = 0;
  int _daughters = 0;
  bool _showChildrenDetails = false;
  String? _selectedHeight;
  String? _selectedMaritalStatus;
  String? _selectedMoveAbroad;
  String? _selectedProfession;
  String? _selectedSect;
  String? _selectedSmoke;
  String? _selectedCaste; // Added for caste selection
  String? _homeType;


  // Siblings state variables
  bool? _hasSiblings;
  int _totalSiblings = 1;
  int _brothers = 0;
  int _sisters = 0;
  bool _showSiblingsDetails = false;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasImageLoadError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _educationLevels = [
    "High School",
    "Diploma",
    "Undergraduate (Bachelor's)",
    "Postgraduate (Master's)",
    "Doctorate (PhD)",
    "Vocational Training",
    "Other",
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

  final List<String> _sectOptions = [
    "Sunni",
    "Shia",
    "Deobandi",
    "Wahabi",
    "Other"
  ];

  final List<String> _casteOptions = [
    "Sayyid",
    "Sheikh",
    "Mughal",
    "Pathan",
    "Ansari",
    "Qureshi",
    "Julaha",
    "Jat",
    "Arain",
    "Rajput",
    "Gujjar",
    "Awan",
    "Mussali",
    "Mochi",
    "Kumhar",
    "Mirasi",
    "Khokhar",
    "Malik",
    "Chaudhry",
    "Other",
    "Prefer not to say"
  ];

  final List<String> _smokeOptions = [
    "Yes, I smoke",
    "No, I don't smoke",
    "Used to, but quit",
    "Occasionally"
  ];

  final List<String> _homeTypes=['Rent','Own Home','Lease'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasImageLoadError = false;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        Navigator.pop(context);
        return;
      }

      // Get profile data from Firestore
      final DocumentSnapshot profileDoc = await _firestore
          .collection('profiles')
          .doc(currentUser.uid)
          .get();

      if (profileDoc.exists && profileDoc.data() != null) {
        final data = profileDoc.data() as Map<String, dynamic>;

        setState(() {
          // Set basic info
          _nameController.text = data['fullName'] ?? '';
          _existingImageUrl = data['profileImage'];
          _guardianControler.text=data['guardianType'];
          _guardianNumberControler.text=data['guardianNumber'];
          _addressControler.text=data['address'];
          _cityControler.text=data['city'];
          _countryControler.text=data['country'];

          // Debug profile image URL
          print("Profile image URL loaded: $_existingImageUrl");

          // Parse date of birth
          if (data['dateOfBirth'] != null) {
            final Timestamp dob = data['dateOfBirth'];
            _selectedDate = dob.toDate();
            _dobController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
          }

          // Set other fields
          _selectedEducation = data['educationLevel'];
          _selectedAlcoholOption = data['alcohol'];
          _selectedChildren = data['children'];
          _selectedHeight = data['height'];
          _selectedMaritalStatus = data['maritalStatus'];
          _selectedMoveAbroad = data['moveAbroad'];
          _selectedProfession = data['profession'];
          _selectedSect = data['sect'];
          _selectedSmoke = data['smoking'];
          _selectedCaste = data['caste']; // Load caste from profile data
          _homeType=data['homeType'];

          // Set children details if available
          if (data['totalChildren'] != null) {
            _totalChildren = data['totalChildren'];
            _sons = data['sons'] ?? 0;
            _daughters = data['daughters'] ?? 0;
            _showChildrenDetails = _selectedChildren == "Yes, I have children";
          }

          // Set siblings details if available
          _hasSiblings = data['hasSiblings'];
          if (data['totalSiblings'] != null) {
            _totalSiblings = data['totalSiblings'];
            _brothers = data['brothers'] ?? 0;
            _sisters = data['sisters'] ?? 0;
          }
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile data', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _hasImageLoadError = false; // Reset error state when new image is selected
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      builder: (context, child) {
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
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

  // Options pickers
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

  // Show caste picker
  void _showCastePicker() {
    _showOptionsBottomSheet(
      title: "Select Your Caste",
      options: _casteOptions,
      selectedValue: _selectedCaste,
      onSelect: (value) {
        _selectedCaste = value;
      },
      prefixIcon: Icons.people,
    );
  }

  void _showHomeTypes(){
    _showOptionsBottomSheet(title: "Select Home Type", options: _homeTypes, selectedValue: _homeType, onSelect: (value){
      _homeType=value;
    },prefixIcon: Icons.home);
  }

  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    try {

      // Reference to storage location - make sure the path exists
      final Reference storageRef = _storage.ref().child('profile_images/$userId.jpg');

      try {
        await storageRef.delete();
      } catch (e) {
        print('No previous image found or delete failed: $e');
      }

      print("Attempting to upload to: ${storageRef.fullPath}");

      // Start upload with metadata
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_by': userId,
            'date': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      }, onError: (e) {
        print('Upload error: $e');
      });

      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("Upload successful. Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      // Show more detailed error for debugging
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }
      return null;
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.red,),
              const SizedBox(width: 20),
              const Text("Deleting Account...",),
            ],
          ),
        );
      },
    );
  }
  Future<String?> _promptForPassword() async {

    TextEditingController _passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Your Password"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Enter your password"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkColor,
                foregroundColor: Colors.white,
              ),
              child: Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkColor,
                foregroundColor: Colors.white,
              ),
              child: Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(_passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUserAccount() async {
    try{
      Navigator.of(context).pop();
      showLoadingDialog();
      final user=FirebaseAuth.instance.currentUser;
      if(user==null) return;
        //Delete from Authentication
        final password=await _promptForPassword();
        if(password==null || password.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passwrod Required', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final credential=EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
        //Delete from FireStore
      final userId=user.uid;
      //Delete from firestore
      final firestore=FirebaseFirestore.instance;
      await firestore.collection("profiles").doc(userId).delete();
      await firestore.collection("users").doc(userId).delete();
      final sendConnections=await firestore.collection("connectionRequests").where("senderId",isEqualTo: userId).get();
      for(var doc in sendConnections.docs){
        await doc.reference.delete();
      }
      final receiveConnections=await firestore.collection("connectionRequests").where("recipientId",isEqualTo: userId).get();
      for(var doc in receiveConnections.docs){
        await doc.reference.delete();
      }

      final Reference storageRef = _storage.ref().child('profile_images/$userId.jpg');
      await storageRef.delete();

      await user.delete();
      Navigator.of(context).pop();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
    }
    catch(e){
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to Delete Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

    }
  }

  void _showDeleteDialog() {
    showDialog(context: context, builder: (ctx)=>AlertDialog(
      title: Text("Delete Account?", style: TextStyle(color: pinkColor)),
      content: Text(
        "Are you sure to delete account?",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            _deleteUserAccount();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkColor,
            foregroundColor: Colors.white,
          ),
          child: Text("DELETE"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkColor,
            foregroundColor: Colors.white,
          ),
          child: Text("CANCEL"),
        ),
      ],
    ));
  }

  Future<void> _saveChanges() async {
    // Validate inputs
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

    // Validate children counts match
    if (_selectedChildren == "Yes, I have children" && _sons + _daughters != _totalChildren) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The sum of boys and girls must equal the total number of children!',
                        style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate siblings counts match
    if (_hasSiblings == true && _brothers + _sisters != _totalSiblings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The sum of brothers and sisters must equal the total number of siblings!',
                        style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        Navigator.pop(context);
        return;
      }

      // Check if we need to upload a new image
      String? profileImageUrl = _existingImageUrl;
      if (_image != null) {
        profileImageUrl = await _uploadProfileImage(_image!, currentUser.uid);
        if (profileImageUrl == null) {
          // Show error but continue with other updates
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image, but other changes will be saved.',
                           style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'fullName': _nameController.text,
        'profileImage': profileImageUrl,
        'educationLevel': _selectedEducation,
        'alcohol': _selectedAlcoholOption,
        'children': _selectedChildren,
        'height': _selectedHeight,
        'maritalStatus': _selectedMaritalStatus,
        'moveAbroad': _selectedMoveAbroad,
        'profession': _selectedProfession,
        'sect': _selectedSect,
        'caste': _selectedCaste, // Include caste in the data to save
        'smoking': _selectedSmoke,
        'homeType':_homeType,
        'guardianNumber':_guardianNumberControler.text,
        'guardianType':_guardianControler.text,
        'city':_cityControler.text,
        'country':_countryControler.text,
        'address':_addressControler.text
      };

      // Add age calculation if date of birth is provided
      if (_selectedDate != null) {
        final int age = DateTime.now().year - _selectedDate!.year -
            (DateTime.now().month < _selectedDate!.month ||
                (DateTime.now().month == _selectedDate!.month && DateTime.now().day < _selectedDate!.day)
                ? 1
                : 0);
        updateData['age'] = age;
        updateData['dateOfBirth'] = Timestamp.fromDate(_selectedDate!);
      }

      // Add children details if applicable
      if (_selectedChildren == "Yes, I have children") {
        updateData['totalChildren'] = _totalChildren;
        updateData['sons'] = _sons;
        updateData['daughters'] = _daughters;
      } else {
        // Clear children details if user selects "No, I don't have children"
        updateData['totalChildren'] = null;
        updateData['sons'] = null;
        updateData['daughters'] = null;
      }

      // Add siblings details
      updateData['hasSiblings'] = _hasSiblings;
      if (_hasSiblings == true) {
        updateData['totalSiblings'] = _totalSiblings;
        updateData['brothers'] = _brothers;
        updateData['sisters'] = _sisters;
      } else {
        // Clear siblings details if user selects "No siblings"
        updateData['totalSiblings'] = null;
        updateData['brothers'] = null;
        updateData['sisters'] = null;
      }

      // Add update timestamp
      updateData['profileUpdatedAt'] = FieldValue.serverTimestamp();

      // Update profile in Firestore
      await _firestore
          .collection('profiles')
          .doc(currentUser.uid)
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate successful update
    } catch (e) {
      print('Error saving profile changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.pink,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.pink))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _image != null
                                  ? Image.file(
                                      _image!,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : _existingImageUrl != null && !_hasImageLoadError
                                      ? Image.network(
                                          _existingImageUrl!,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Handle image loading errors
                                            print("Error loading image: $error");
                                            setState(() {
                                              _hasImageLoadError = true;
                                            });
                                            return const Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 80,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        (loadingProgress.expectedTotalBytes ?? 1)
                                                    : null,
                                                color: Colors.pink,
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceOptions,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Full Name",
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Enter your full name",
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address",
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _addressControler,
                            decoration: InputDecoration(
                              hintText: "Enter your street address",
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Date of Birth field
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "City",
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _cityControler,
                            decoration: InputDecoration(
                              hintText: "Enter your city",
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Country",
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _countryControler,
                            decoration: InputDecoration(
                              hintText: "Enter your country",
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.pink),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                        : "Select your date of birth",
                                    style: TextStyle(
                                      color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
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
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Guardian Type",
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _guardianControler,
                            decoration: InputDecoration(
                              hintText: "Enter your guardian",
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Guardian Number",
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _guardianNumberControler,
                            decoration: InputDecoration(
                              hintText: "Enter your guardian number",
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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
                            _selectedHeight = value;
                          },
                          prefixIcon: Icons.height,
                        );
                      },
                      prefixIcon: Icons.height,
                    ),
                    const SizedBox(height: 20),

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
                            _selectedMaritalStatus = value;
                          },
                          prefixIcon: Icons.favorite,
                        );
                      },
                      prefixIcon: Icons.favorite,
                    ),
                    const SizedBox(height: 20),
                    _buildSelectionField(
                      label: "Home Type",
                      selectedValue: _homeType,
                      placeholder: "Select your home type",
                      onTap: _showHomeTypes,
                      prefixIcon: Icons.home,
                    ),
                    const SizedBox(height: 20),
                    // Education Level field
                    _buildSelectionField(
                      label: "Education Level",
                      selectedValue: _selectedEducation,
                      placeholder: "Select your education level",
                      onTap: _showEducationLevelPicker,
                      prefixIcon: Icons.school,
                    ),
                    const SizedBox(height: 20),

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
                            _selectedProfession = value;
                          },
                          prefixIcon: Icons.work,
                        );
                      },
                      prefixIcon: Icons.work,
                    ),
                    const SizedBox(height: 20),

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
                            _selectedSect = value;
                          },
                          prefixIcon: Icons.mosque,
                        );
                      },
                      prefixIcon: Icons.mosque,
                    ),
                    const SizedBox(height: 20),

                    // Caste field
                    _buildSelectionField(
                      label: "Caste",
                      selectedValue: _selectedCaste,
                      placeholder: "Select your caste",
                      onTap: _showCastePicker,
                      prefixIcon: Icons.people,
                    ),
                    const SizedBox(height: 20),

                    // Smoking field
                    _buildSelectionField(
                      label: "Do you smoke?",
                      selectedValue: _selectedSmoke,
                      placeholder: "Select an option",
                      onTap: () {
                        _showOptionsBottomSheet(
                          title: "Do you smoke?",
                          options: _smokeOptions,
                          selectedValue: _selectedSmoke,
                          onSelect: (value) {
                            _selectedSmoke = value;
                          },
                          prefixIcon: Icons.smoking_rooms,
                        );
                      },
                      prefixIcon: Icons.smoking_rooms,
                    ),
                    const SizedBox(height: 20),

                    // Alcohol field
                    _buildSelectionField(
                      label: "Do you drink alcohol?",
                      selectedValue: _selectedAlcoholOption,
                      placeholder: "Select an option",
                      onTap: _showAlcoholOptionsSheet,
                      prefixIcon: Icons.local_bar,
                    ),
                    const SizedBox(height: 20),

                    // Children field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Do you have children?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _showOptionsBottomSheet(
                              title: "Do you have children?",
                              options: ["Yes, I have children", "No, I don't have children"],
                              selectedValue: _selectedChildren,
                              onSelect: (value) {
                                setState(() {
                                  _selectedChildren = value;
                                  _showChildrenDetails = value == "Yes, I have children";
                                });
                              },
                              prefixIcon: Icons.child_care,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.child_care, color: Colors.pink),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedChildren ?? "Select an option",
                                    style: TextStyle(
                                      color: _selectedChildren != null ? Colors.black87 : Colors.grey[600],
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
                    ),

                    // Children details section
                    if (_showChildrenDetails) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.pink.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Children Details",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Total Children",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.pink),
                                              onPressed: _totalChildren > 1
                                                  ? () {
                                                      setState(() {
                                                        _totalChildren--;
                                                        // Adjust sons/daughters if needed
                                                        if (_sons + _daughters > _totalChildren) {
                                                          if (_daughters > 0) {
                                                            _daughters--;
                                                          } else if (_sons > 0) {
                                                            _sons--;
                                                          }
                                                        }
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              "$_totalChildren",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.pink),
                                              onPressed: () {
                                                setState(() {
                                                  _totalChildren++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Boys",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.pink),
                                              onPressed: _sons > 0
                                                  ? () {
                                                      setState(() {
                                                        _sons--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              "$_sons",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.pink),
                                              onPressed: _sons + _daughters < _totalChildren
                                                  ? () {
                                                      setState(() {
                                                        _sons++;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Girls",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.pink),
                                              onPressed: _daughters > 0
                                                  ? () {
                                                      setState(() {
                                                        _daughters--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              "$_daughters",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.pink),
                                              onPressed: _sons + _daughters < _totalChildren
                                                  ? () {
                                                      setState(() {
                                                        _daughters++;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_sons + _daughters != _totalChildren)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "The sum of boys and girls should equal the total number of children",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Siblings field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Do you have siblings?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _showOptionsBottomSheet(
                              title: "Do you have siblings?",
                              options: ["Yes", "No"],
                              selectedValue: _hasSiblings == true ? "Yes" : (_hasSiblings == false ? "No" : null),
                              onSelect: (value) {
                                setState(() {
                                  _hasSiblings = value == "Yes";
                                  _showSiblingsDetails = value == "Yes";
                                });
                              },
                              prefixIcon: Icons.family_restroom,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.family_restroom, color: Colors.pink),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _hasSiblings == true
                                        ? "Yes"
                                        : (_hasSiblings == false ? "No" : "Select an option"),
                                    style: TextStyle(
                                      color: _hasSiblings != null ? Colors.black87 : Colors.grey[600],
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
                    ),

                    // Siblings details section
                    if (_showSiblingsDetails) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.pink.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Siblings Details",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Total Siblings",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.pink),
                                              onPressed: _totalSiblings > 1
                                                  ? () {
                                                      setState(() {
                                                        _totalSiblings--;
                                                        // Adjust brothers/sisters if needed
                                                        if (_brothers + _sisters > _totalSiblings) {
                                                          if (_sisters > 0) {
                                                            _sisters--;
                                                          } else if (_brothers > 0) {
                                                            _brothers--;
                                                          }
                                                        }
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              "$_totalSiblings",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.pink),
                                              onPressed: () {
                                                setState(() {
                                                  _totalSiblings++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Brothers",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.pink),
                                              onPressed: _brothers > 0
                                                  ? () {
                                                      setState(() {
                                                        _brothers--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              "$_brothers",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.pink),
                                              onPressed: _brothers + _sisters < _totalSiblings
                                                  ? () {
                                                      setState(() {
                                                        _brothers++;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Sisters",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, color: Colors.pink),
                                              onPressed: _sisters > 0
                                                  ? () {
                                                      setState(() {
                                                        _sisters--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              "$_sisters",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, color: Colors.pink),
                                              onPressed: _brothers + _sisters < _totalSiblings
                                                  ? () {
                                                      setState(() {
                                                        _sisters++;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_brothers + _sisters != _totalSiblings)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "The sum of brothers and sisters should equal the total number of siblings",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Move Abroad field
                    _buildSelectionField(
                      label: "Would you move abroad?",
                      selectedValue: _selectedMoveAbroad,
                      placeholder: "Select an option",
                      onTap: () {
                        _showOptionsBottomSheet(
                          title: "Would you move abroad?",
                          options: _moveAbroadOptions,
                          selectedValue: _selectedMoveAbroad,
                          onSelect: (value) {
                            _selectedMoveAbroad = value;
                          },
                          prefixIcon: Icons.flight_takeoff,
                        );
                      },
                      prefixIcon: Icons.flight_takeoff,
                    ),
                    const SizedBox(height: 40),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.pink.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: _isSaving
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Saving...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: (){
                        _showDeleteDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Delete Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
