class Film {
  final int id;
  final String title;
  final String description;
  final String director;
  final int year;
  final List<String> images;

  Film({
    required this.images,
    required this.year,
    required this.director,
    required this.title,
    required this.description,
    required this.id,
  });
}