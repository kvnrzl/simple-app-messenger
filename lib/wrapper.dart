import 'package:app_messanger_by_ker/views/home.dart';
import 'package:app_messanger_by_ker/views/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return user == null ? SignIn() : Home();
  }
}
