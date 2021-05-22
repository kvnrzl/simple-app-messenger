import 'package:app_messanger_by_ker/services/auth.dart';
import 'package:app_messanger_by_ker/views/home.dart';
import 'package:app_messanger_by_ker/views/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: AuthService().getCurrentUser(),
        builder: (context, snapshot) {
          return snapshot.hasData ? Home() : SignIn();
        },
      ),
    );
  }
}
