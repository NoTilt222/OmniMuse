import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omnimuse/components/square_tile.dart';
import 'package:omnimuse/pallete.dart';
import 'package:omnimuse/utils/login_data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';
import 'utils/custom_theme.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool _loadingButton = false;

  Map<String, String> data = {};

  _LoginPageState(){
    data = LoginData.signIn;
  }
  void switchLogin() {
    setState(() {
      if(mapEquals(data, LoginData.signUp)){
        data = LoginData.signIn;
      }
      else{
        data = LoginData.signUp;
      }
    });
  }

  Future<void> loginUser() async {
    setState(() {
      _loadingButton = true; // Show the loading indicator
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } finally {
      setState(() {
        _loadingButton = false; // Hide the loading indicator
      });
    }
  }

  Future<void> signUpUser() async{
    String _password = password.text.trim();
    String _confirmPassword = confirmPassword.text.trim();
    try{
      if(_password == _confirmPassword) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim());
        setState(() {
          data = LoginData.signIn;
        });
      }
      else{
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text('Wrong password'),
            content: Text('Please check if the password has been correctly entered'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
            ],
          );
        });
      }
    } on FirebaseException catch(e) {
      print(e);
    }
  }
  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with the credential
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the sign-in was successful
    if (userCredential.user != null) {
      // Navigate to the home page
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Future<void> signOutGoogle() async {
  //   await _googleSignIn.signOut();
  //   print("User signed out");
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 100,
                      ),
                      Padding(padding: const EdgeInsets.only(bottom: 8),
                        child: Text(data["heading"] as String, style:  TextStyle( color: Pallete.mainFontColor,
                          fontFamily: 'Cera Pro',fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(data["subHeading"] as String, style: TextStyle( color: Pallete.mainFontColor,
                          fontFamily: 'Cera Pro',fontSize: 16,)),
                    ],
                  ),
                ),
              ),
              model(data, email, password),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      child: Text(data["footer"] as String, style: TextStyle( color: Pallete.mainFontColor,
                        fontFamily: 'Cera Pro',fontSize: 16,)),
                      onPressed: switchLogin,
                    ),
                  ),
                ],
              ),
              Text('Or continue with:',
                style: TextStyle( color: Colors.grey,
                  fontFamily: 'Cera Pro',fontSize: 16,),),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(imagePath: 'assets/images/google.png', onPressed: (){signInWithGoogle();},),
                  SizedBox(width: 5,),
                  SquareTile(imagePath: 'assets/images/apple.png', onPressed: (){
                  },),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget model(
      Map<String, String> data,
      TextEditingController emailController,
      TextEditingController passwordController,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 20),
      decoration: CustomTheme.getCardDecoration(),
      child: Column(
        children: [
          CustomTextInput(
            label: "Email",
            placeholder: "abcd@address.com",
            icon: Icons.person_outline,
            textEditingController: email,
          ),
          CustomTextInput(
            label: "Password",
            placeholder: "password",
            icon: Icons.lock_outlined,
            password: true,
            textEditingController: password,
          ),
          Visibility(
            visible: data == LoginData.signUp,
            child: CustomTextInput(
              label: "Confirm password",
              placeholder: "Confirm password",
              icon: Icons.lock_outlined,
              password: true,
              textEditingController: confirmPassword,
            ),
          ),
          if (_loadingButton) // Show CircularProgressIndicator if loading
            CircularProgressIndicator()
          else // Show the regular button
            CustomButton(
              text: data["label"] as String,
              onPress: mapEquals(data, LoginData.signUp)? signUpUser : loginUser,
              loading: _loadingButton,
            ),
        ],
      ),
    );
  }

}
