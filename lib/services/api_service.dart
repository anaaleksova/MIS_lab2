import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Category> categories = (data['categories'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return [];

      List<Meal> meals = (data['meals'] as List)
          .map((json) => Meal.fromJson(json))
          .toList();
      return meals;
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<MealDetail> getMealDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return [];

      List<Meal> meals = (data['meals'] as List)
          .map((json) => Meal.fromJson(json))
          .toList();
      return meals;
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<MealDetail> getRandomMeal() async {
    final response = await http.get(Uri.parse('$baseUrl/random.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
