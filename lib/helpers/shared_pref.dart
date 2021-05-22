import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static String userid = "USERIDKEY";
  static String username = "USERNAMEKEY";
  static String userDisplayName = "USERDISPLAYNAMEKEY";
  static String userEmail = "USEREMAILKEY";
  static String userProfilePic = "USERPROFILEPICKEY";
  static String userPhoneNumber = "USERPHONENUMBERKEY";

  // Save Data
  saveUserId(String getUserId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userid, getUserId);
  }

  Future<bool> saveUsername(String getUsername) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(username, getUsername);
  }

  Future<bool> saveUserDisplayName(String getUserDisplayName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userDisplayName, getUserDisplayName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userEmail, getUserEmail);
  }

  Future<bool> saveUserProfilePic(String getUserProfilePic) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userProfilePic, getUserProfilePic);
  }

  Future<bool> saveUserPhoneNumber(String getUserPhoneNumber) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userPhoneNumber, getUserPhoneNumber);
  }

  // Load Data
  Future<String> loadUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userid);
  }

  Future<String> loadUsername() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(username);
  }

  Future<String> loadUserDisplayName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userDisplayName);
  }

  Future<String> loadUserEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userEmail);
  }

  Future<String> loadUserProfilePic() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userProfilePic);
  }

  Future<String> loadUserPhoneNumber() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userPhoneNumber);
  }
}
