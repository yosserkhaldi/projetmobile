import 'package:flutter/material.dart';
import 'package:flutter_workshops_5sae1_2627/FilmCardItem.dart';
import 'package:flutter_workshops_5sae1_2627/ProfileSettingsPage.dart';

class Gstore extends StatefulWidget {
  const Gstore({super.key});

  @override
  State<Gstore> createState() => _GstoreState();
}

class _GstoreState extends State<Gstore> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  final Color _orange = const Color(0xFFE8623A);

  final List<Map<String, String>> _films = [
    {'title': 'House Of Dead', 'image': 'HouseOfDead.jpg'},
    {'title': 'Ice Road', 'image': 'iceroad.jpg'},
    {'title': 'The Grudge', 'image': 'thegrudge.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFilmList() {
    return SingleChildScrollView(
      child: Column(
        children: _films
            .map((f) => FilmCardItem(title: f['title']!, imagepath: f['image']!))
            .toList(),
      ),
    );
  }

  Widget _buildBibliotheque() {
    return SingleChildScrollView(
      child: Column(
        children: _films
            .map((f) => FilmCardItem(title: f['title']!, imagepath: f['image']!))
            .toList(),
      ),
    );
  }

  Widget _buildBasket() {
    return const Center(
      child: Text(
        'Your basket is empty',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            const Icon(Icons.movie, size: 36, color: Colors.black87),
            // Basket icon
            Column(
              children: [
                Icon(Icons.shopping_basket, color: Colors.black87, size: 26),
                const Text('Basket', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _orange,
          tabs: const [
            Tab(
              icon: Icon(Icons.grid_view),
              text: 'My Films',
            ),
            Tab(
              icon: Icon(Icons.video_library),
              text: 'Bibliothèque',
            ),
            Tab(
              icon: Icon(Icons.shopping_basket),
              text: 'Basket',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFilmList(),
          _buildBibliotheque(),
          _buildBasket(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _tabController.animateTo(index);
          });
        },
        selectedItemColor: _orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Bibliothèque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Basket',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.movie, size: 60, color: Colors.black87),
            ),
            const Divider(),

            // Update Profile
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black54),
              title: const Text('Update Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileSettingsPage()),
                );
              },
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black54),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),

            // Go to Nav Bar
            ListTile(
              leading: const Icon(Icons.chevron_right, color: Colors.black54),
              title: const Text('Go to Nav Bar'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
