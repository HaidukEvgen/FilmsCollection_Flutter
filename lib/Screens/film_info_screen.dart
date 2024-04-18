import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Film.dart';

class FilmInfoScreen extends StatefulWidget {
  final Film film;
  final Function reloadFilms;
  const FilmInfoScreen({Key? key, required this.film, required this.reloadFilms}) : super(key: key);

  @override
  _FilmInfoScreenState createState() => _FilmInfoScreenState();
}

class _FilmInfoScreenState extends State<FilmInfoScreen> {
  bool isInFavorites = false;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    checkFavorites();
    loadFilmImages();
  }

  void checkFavorites() async {
    String userId = FirebaseAuth.instance.currentUser!.email!;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      List<dynamic> favorites = userSnapshot['favorites'];
      setState(() {
        isInFavorites = favorites.contains(widget.film.id);
      });
    }
  }

  void toggleFavorite() async {
    String userId = FirebaseAuth.instance.currentUser!.email!;

    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    if (isInFavorites) {
      await userRef.update({'favorites': FieldValue.arrayRemove([widget.film.id])});
    } else {
      await userRef.update({'favorites': FieldValue.arrayUnion([widget.film.id])});
    }

    widget.reloadFilms();

    setState(() {
      isInFavorites = !isInFavorites;
    });
  }

  void loadFilmImages() async {
    Reference storageRef =
    FirebaseStorage.instance.ref().child('images/${widget.film.id}');

    try {
      ListResult result = await storageRef.listAll();
      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        setState(() {
          imageUrls.add(url);
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.film.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 400,
            child: PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(imageUrls[index]);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: ${widget.film.title}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Director: ${widget.film.director}'),
                  SizedBox(height: 8),
                  Text('Year: ${widget.film.year}'),
                  SizedBox(height: 8),
                  Text('Description: ${widget.film.description}'),
                  SizedBox(height: 16),
                  Center( // Center the button horizontally
                    child: ElevatedButton(
                      onPressed: toggleFavorite,
                      child: Text(isInFavorites ? 'Remove from favorites' : 'Add to favorites'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
