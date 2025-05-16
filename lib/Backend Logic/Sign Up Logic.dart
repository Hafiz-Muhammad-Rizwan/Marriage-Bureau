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
}