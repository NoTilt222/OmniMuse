import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnimuse/home_page.dart';
import 'package:omnimuse/login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator if the connection is still in progress
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // User is logged in, navigate to HomePage
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              // Use addPostFrameCallback to navigate after the widget is built
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            });
            // Return an empty container while navigating
            return Container();
          } else {
            // User is not logged in, navigate to LoginPage
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              // Use addPostFrameCallback to navigate after the widget is built
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            });
            // Return an empty container while navigating
            return Container();
          }
        },
      ),
    );
  }
}
