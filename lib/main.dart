import 'package:flutter/material.dart';
import 'package:omnimuse/home_page.dart';
import 'package:omnimuse/loading.dart';
import 'package:omnimuse/pallete.dart';

void main() {
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
        '/home': (context)=> HomePage()
      },
    );
  }
}
