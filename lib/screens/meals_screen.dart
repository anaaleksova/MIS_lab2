import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService _apiService = ApiService();
  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await _apiService.getMealsByCategory(widget.category);
      setState(() {
        _meals = meals;
        _filteredMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading the meals');
    }
  }

  Future<void> _searchMeals(String query) async {
    setState(() => _searchQuery = query);

    if (query.isEmpty) {
      setState(() => _filteredMeals = _meals);
      return;
    }

    try {
      final searchResults = await _apiService.searchMeals(query);
      final mealIds = _meals.map((m) => m.idMeal).toSet();
      final filtered = searchResults.where((m) => mealIds.contains(m.idMeal)).toList();

      setState(() => _filteredMeals = filtered);
    } catch (e) {
      _showError('Search error');
    }
  }

  Future<void> _showRandomMeal() async {
    try {
      final meal = await _apiService.getRandomMeal();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailScreen(mealId: meal.idMeal),
        ),
      );
    } catch (e) {
      _showError('Error loading the random recipe');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: _showRandomMeal,
              tooltip: 'Random recipe',
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange.shade400,
          strokeWidth: 3,
        ),
      )
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: TextField(
              onChanged: _searchMeals,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.orange.shade400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _searchMeals(''),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredMeals.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No meals found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredMeals.length,
              itemBuilder: (context, index) {
                return MealCard(
                  meal: _filteredMeals[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(
                          mealId: _filteredMeals[index].idMeal,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}