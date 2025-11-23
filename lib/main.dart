import 'package:flutter/material.dart';
import 'screens/categories_screen.dart';

void main() {
  runApp(const MealApp());
}

class MealApp extends StatelessWidget {
  const MealApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheMeal Recipes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const CategoriesScreen(),
    );
  }
}
