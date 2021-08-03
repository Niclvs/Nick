
import 'dart:math';

import 'package:SpidrApp/helper/functions.dart';
import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/model/chatUser.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatUser _userFromFirebaseUser(User user) {
    return user != null ? ChatUser(uid: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e);
      throw(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User firebaseUser = result.user;

      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInSharedPreference(false);
      await HelperFunctions.saveUserNameSharedPreference('');
      await HelperFunctions.saveUserEmailSharedPreference('');
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

 Future googleSignIn(firebaseUser) async {
    try {

      if (firebaseUser != null) {
        // Checking if email and name is null
        assert(firebaseUser.email != null);
        assert(firebaseUser.displayName != null);

        assert(!firebaseUser.isAnonymous);
        assert(await firebaseUser.getIdToken() != null);

        final User currentUser = _auth.currentUser;
        assert(firebaseUser.uid == currentUser.uid);
      }

      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      throw(e.toString());
    }
  }


  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _auth.signInWithCredential(credential);
        final firebaseUser = authResult.user;

        if (scopes.contains(Scope.fullName)) {
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(displayName: displayName);
        }

        return firebaseUser;

        case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future appleSignIn(firebaseUser) async {
    try {
      if (firebaseUser != null) {
        // Checking if email and name is null
        assert(firebaseUser.email != null);
        assert(firebaseUser.displayName != null);

        assert(!firebaseUser.isAnonymous);
        assert(await firebaseUser.getIdToken() != null);

        final User currentUser = _auth.currentUser;
        assert(firebaseUser.uid == currentUser.uid);
      }

      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      throw(e.toString());
    }
  }

  Map<String, dynamic> genUserInfo(name, email){
    Random random = new Random();
    int randNum = random.nextInt(33);
    String imgPath = "assets/images/userPic/SpidrProfImg.png";

    Map<String, dynamic> userInfoMap = {
      'name': name,
      'email': email,
      'profileImg': imgPath,
      'anonImg':randNum,
      'pushToken': '',
      'quote':'',
      'tags':[],
      'blockList':[],
      'getStarted':true
    };

    HelperFunctions.saveUserEmailSharedPreference(email);
    HelperFunctions.saveUserNameSharedPreference(name);

    return userInfoMap;
  }

  Future verifyEmail() async {
    final User user = _auth.currentUser;
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

}















