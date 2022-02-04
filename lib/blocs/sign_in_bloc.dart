import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInBloc extends ChangeNotifier {
  SignInBloc() {
    checkSignIn();
  }

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _isVeryfy = false;
  bool get isVeryfy => _isVeryfy;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _name;
  String? get name => _name;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  // String? _hp;
  // String? get HP => _hp;

  // final GoogleSignIn _googlSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed_in') ?? false;
    notifyListeners();
  }

  Future signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final newUser = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await newUser.user!.sendEmailVerification().then((value) => {
            if (newUser != null)
              {
                _uid = newUser.user!.uid,
                _email = email,
                _name = name,
                _hasError = false,
                notifyListeners()
              }
          });
    } on FirebaseAuthException catch (e) {
      _errorCode = e.code.toString();
      _hasError = true;
      notifyListeners();
    }
  }

  Future signIn({required String email, required String password}) async {
    try {
      final newUser = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (newUser.user!.emailVerified) {
        _hasError = false;
        _isVeryfy = true;
        notifyListeners();
      } else {
        _isVeryfy = false;
        _hasError = false;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      // print(e.code);
      // print(e.message);
      _errorCode = e.code.toString();
      _hasError = true;
      notifyListeners();
    }
  }
  //SIGN IN METHOD

  //SIGN IN METHOD
  Future forgetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _hasError = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorCode = e.message.toString();
      _hasError = true;
      notifyListeners();
    }
  }

  Future saveToFirebase() async {
    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(_uid);
    var userData = {
      'name': _name,
      'email': _email,
      'uid': _uid,
    };
    await ref.set(userData);
  }

  Future saveDataToSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('name', _name!);
    await sp.setString('email', _email!);
    // await sp.setString('image_url', _imageUrl!);
    await sp.setString('uid', _uid!);
    // await sp.setString('hp', _hp!);
  }

  Future getDataFromSp() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _name = sp.getString('name');
    _uid = sp.getString('uid');
    _email = sp.getString('email');
    // _imageUrl = sp.getString('image_url');

    // _hp = sp.getString('hp');
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  Future userSignout() async {
    await _firebaseAuth.signOut();

    await clearAllData();
    _isSignedIn = false;
    notifyListeners();
  }

  Future getUserDatafromFirebase(uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snap) {
      _uid = snap.get("uid");
      _name = snap.get("name");
      _email = snap.get("email");
    });
    notifyListeners();
  }
}
