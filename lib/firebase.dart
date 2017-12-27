import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
final googleSignIn = new GoogleSignIn();

Future<FirebaseUser> ensureLoggedIn() async {
  FirebaseUser firebaseUser = await auth.currentUser();
  if (firebaseUser != null) return firebaseUser;

  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null)
    user = await googleSignIn.signInSilently();
  if (user == null) {
    user = await googleSignIn.signIn();
    analytics.logLogin();
  }

  if (await auth.currentUser() == null && googleSignIn.currentUser != null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    return auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  } else {
    return null;
  }
}
