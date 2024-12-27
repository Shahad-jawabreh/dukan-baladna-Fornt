import 'dart:async';
import 'package:dukan_baladna/customer/navbar.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

// Updated FoodItem class to include additional information
class FoodItem {
  final String imageUrl;
  final String name;
  final String price;
  final String description;
  final List<String> ingredients;

  FoodItem({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.description,
    required this.ingredients,
  });
}

// Define the list of best-selling items
final List<FoodItem> bestSellerItems = [
  FoodItem(
    imageUrl: 'assets/back4.png',
    name: 'Dawali',
    price: '\$20.00',
    description: 'Delicious traditional grape leaves stuffed with rice.',
    ingredients: ['Grape Leaves', 'Rice', 'Spices', 'Olive Oil'],
  ),
  FoodItem(
    imageUrl: 'assets/back.png',
    name: 'Humus',
    price: '\$25.00',
    description: 'Creamy chickpea dip served with olive oil and pita bread.',
    ingredients: ['Chickpeas', 'Tahini', 'Lemon', 'Garlic', 'Olive Oil'],
  ),
  FoodItem(
    imageUrl: 'assets/mm.png',
    name: 'Mkhlal',
    price: '\$25.00',
    description: 'Traditional pickles with a zesty flavor.',
    ingredients: ['Cucumber', 'Carrots', 'Vinegar', 'Spices'],
  ),
];

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late Timer _timer;

  @override
  void initState() {

    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % bestSellerItems.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    });

  
  }




  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {

    return Scaffold(
      appBar: Navbar(), // Using the Navbar as the AppBar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarousel(),
            _buildSectionTitle("Best Chefs"),
            _buildChefList(),
            _buildSectionTitle("Best Sellers"),
            _buildBestSellerGrid(),
          ],
        ),
      ),
    );
  }


  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: bestSellerItems.length,
              itemBuilder: (context, index) {
                return _buildCarouselSlide(
                  imagePath: bestSellerItems[index].imageUrl,
                  title: bestSellerItems[index].name,
                  description: bestSellerItems[index].description,
                );
              },
            ),
          ),
          _buildCarouselArrow(Icons.arrow_back_ios, Alignment.centerLeft, () {
            setState(() {
              _currentPage = (_currentPage - 1 + bestSellerItems.length) % bestSellerItems.length;
              _pageController.jumpToPage(_currentPage);
            });
          }),
          _buildCarouselArrow(Icons.arrow_forward_ios, Alignment.centerRight, () {
            setState(() {
              _currentPage = (_currentPage + 1) % bestSellerItems.length;
              _pageController.jumpToPage(_currentPage);
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChefList() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          _buildChefCard("assets/chef1.jpg", "Chef Fatima"),
          _buildChefCard("assets/chef2.jpg", "Chef Eman"),
          _buildChefCard("assets/chef3.jpg", "Chef C"),
          _buildChefCard("assets/chef4.jpg", "Chef A"),
        ],
      ),
    );
  }

  Widget _buildBestSellerGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: bestSellerItems.length,
      itemBuilder: (context, index) {
        final item = bestSellerItems[index];
        return FoodItemCard(
          title: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          description: item.description,
          ingredients: item.ingredients,
          onTap: () => _showFoodDetails(context, item),
        );
      },
    );
  }

  Widget _buildCarouselSlide({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.5)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselArrow(IconData icon, Alignment alignment, VoidCallback onPressed) {
    return Align(
      alignment: alignment,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildChefCard(String imagePath, String chefName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 30,
        ),
        const SizedBox(height: 8),
        Text(chefName),
      ],
    );
  }

  void _showFoodDetails(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(item.imageUrl, height: 150, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(item.description),
              const SizedBox(height: 10),
              Text("Ingredients: ${item.ingredients.join(', ')}"),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final VoidCallback onTap;

  const FoodItemCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Image.asset(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(price, style: const TextStyle(fontSize: 16, color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}
