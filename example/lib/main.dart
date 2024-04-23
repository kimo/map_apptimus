import 'package:example/screen/map_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MapScreen(
        showRoute: false,
        searchfunction: true,
        saveLocation: true,
        // TODO 
        userkey: 'AIzaSyCL6eBWD1JSonqmNROBZFtsI5Ekj0yl9l4',
      ),
    );
  }
}
