class CategoryModel {
  final String id;
  final String name;
  final String imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}

final List<CategoryModel> categories = [
  CategoryModel(id: "1", name: "Culture", imagePath: "assets/Candi.png"),
  CategoryModel(id: "2", name: "Mountain", imagePath: "assets/mountain.png"),
  CategoryModel(
    id: "3",
    name: "Beach",
    imagePath: "assets/parasol_5127031.png",
  ),
  CategoryModel(
    id: "4",
    name: "Waterfall",
    imagePath: "assets/waterfall_10436179.png",
  ),
  CategoryModel(
    id: "5",
    name: "More",
    imagePath: "",
  ), // kosongkan untuk icon bawaan
];
final List<CategoryModel> moreCategories = [
CategoryModel(id: '6', name: 'History', imagePath: 'assets/food_16224908.png'),
CategoryModel(id: '7', name: 'Museum', imagePath: 'assets/museum_3936783.png'),
CategoryModel(id: '8', name: 'Zoo', imagePath: 'assets/zoo_1326392.png'),
];
