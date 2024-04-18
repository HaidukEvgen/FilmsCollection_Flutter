import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:films_collection/Models/Film.dart';
import 'package:films_collection/Screens/favorites_screen.dart';
import 'package:films_collection/Screens/film_info_screen.dart';
import 'package:films_collection/Screens/profile_screen.dart';
import 'package:films_collection/Screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Film> films = [];
  String searchText = '';
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    loadFilms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadFilms() async {
    try {

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('films').get();

      List<Film> items = [];
      querySnapshot.docs.forEach((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        items.add(Film(
          id: data['id'] as int,
          title: data['title'],
          description: data['description'],
          director: data['director'],
          year: data['year'] as int,
          images: []
        ));
      });

      setState(() {
        films = items;
      });
    } catch (e) {
      print('Error loading card items: $e');
    }
  }

  void reloadFilms() {
    setState(() {
      loadFilms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FilmsCollection'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(reloadFilms: reloadFilms),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.favorite_outlined,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                    (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by film title...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          Film film = films[index];
          // Filter films based on search text
          if (film.title.toLowerCase().contains(searchText.toLowerCase())) {
            return FutureBuilder<bool>(
              future: isInFavorites(film.id),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  bool isInFavorites = snapshot.data ?? false;
                  return ListTile(
                    title: Text(film.title),
                    subtitle: Text(film.director),
                    trailing: isInFavorites ? Icon(Icons.favorite, color: Colors.red) : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilmInfoScreen(
                            film: film,
                            reloadFilms: reloadFilms,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          } else {
            return SizedBox(); // Return an empty container if the film doesn't match the search text
          }
        },
      ),
    );
  }

  Future<bool> isInFavorites(int id) async {
    String userId = FirebaseAuth.instance.currentUser!.email!;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      List<dynamic> favorites = userSnapshot['favorites'];
      return favorites.contains(id);
    }

    return false;
  }

}