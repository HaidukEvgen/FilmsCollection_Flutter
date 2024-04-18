import 'package:films_collection/Screens/home_screen.dart';
import 'package:films_collection/Screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:films_collection/Models/Film.dart';
import 'package:films_collection/Screens/film_info_screen.dart';
import 'package:films_collection/Screens/signin_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final Function reloadFilms;
  const FavoritesScreen({Key? key, required this.reloadFilms}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Film> favoriteFilms = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteFilms();
  }

  Future<void> loadFavoriteFilms() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.email!;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        List<dynamic> favorites = userSnapshot['favorites'];

        List<Film> favoriteFilmsList = [];

        for (int id in favorites) {
          DocumentSnapshot filmSnapshot = await FirebaseFirestore.instance
              .collection('films')
              .doc('film$id')
              .get();
          if (filmSnapshot.exists) {
            Map<String, dynamic> data = filmSnapshot.data() as Map<String, dynamic>;
            favoriteFilmsList.add(Film(
              id: data['id'] as int,
              title: data['title'],
              description: data['description'],
              director: data['director'],
              year: data['year'] as int,
              images: [],
            ));
          }
        }

        setState(() {
          favoriteFilms = favoriteFilmsList;
        });
      }
    } catch (e) {
      print('Error loading favorite films: $e');
    }
  }

  void reloadFilms() {
    loadFavoriteFilms();
    widget.reloadFilms();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signin',
                      (route) => false, // Remove all routes until the signin screen
                );
              } else {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/home'),
                );
              }
            },
            icon: const Icon(
              Icons.home,
              color: Colors.black,
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
      ),
      body: ListView.builder(
        itemCount: favoriteFilms.length,
        itemBuilder: (context, index) {
          Film film = favoriteFilms[index];
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.director),
            trailing: Icon(Icons.favorite, color: Colors.red),
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
        },
      ),
    );
  }
}
