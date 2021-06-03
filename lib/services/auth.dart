import 'package:app_messanger_by_ker/helpers/shared_pref.dart';
import 'package:app_messanger_by_ker/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> getCurrentUser() {
    return _auth.authStateChanges();
  }

  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = userCredential.user;
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signInWithGoogleAccount() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();

    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    GoogleAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential =
        await firebaseAuth.signInWithCredential(googleAuthCredential);
    User user = userCredential.user;

    if (userCredential != null) {
      // 1. save ke shared pref
      SharedPrefHelper().saveUserId(user.uid);
      SharedPrefHelper().saveUsername(user.email.replaceAll("@gmail.com", ""));
      SharedPrefHelper().saveUserDisplayName(user.displayName);
      SharedPrefHelper().saveUserEmail(user.email);
      SharedPrefHelper().saveUserProfilePic(user.photoURL);
      // SharedPrefHelper().saveUserPhoneNumber(user.phoneNumber);

      // 2. upload ke database kemudian kirim ke homescreen
      Map<String, dynamic> userInfoMap = {
        // "userid": user.uid,
        "username": user.email.replaceAll("@gmail.com", ""),
        "userDisplayName": user.displayName,
        "userEmail": user.email,
        "userProfilePic": user.photoURL,
        // "userPhoneNumber": user.phoneNumber
      };

      DatabaseService().addUserIntoDatabase(user.uid, userInfoMap);
    }
  }

  Future<void> signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    await _auth.signOut();
  }
}
