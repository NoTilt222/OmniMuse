import 'package:flutter/material.dart';
import 'package:omnimuse/home_page.dart';
import 'package:omnimuse/loading.dart';
import 'package:omnimuse/login.dart';
import 'package:omnimuse/pallete.dart';
import 'package:omnimuse/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OmniMuse',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.whiteColor,
        )
      ),
      initialRoute: '/',
      routes: {
        '/' :(context)=> Loading(),
        '/login':(context)=> LoginPage(),
        '/home': (context)=> HomePage(),
        '/settings': (context) => Settings()
      },
    );
  }
}
