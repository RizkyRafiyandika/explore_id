class CategoryModel {
  final String id;
  final String name;
  final String imagePath; // Path atau URL gambar

  CategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}

List<CategoryModel> categories = [
  CategoryModel(id: "1", name: "Culture", imagePath: "assets/prambanan.jpg"),
  CategoryModel(id: "2", name: "Beach", imagePath: "assets/pulau seribu.jpg"),
  CategoryModel(id: "3", name: "Mountain", imagePath: "assets/bromo.jpg"),
  CategoryModel(
    id: "4",
    name: "Restaurant",
    imagePath: "assets/rumah mertua heritage.png",
  ),
  CategoryModel(
    id: "5",
    name: "Restaurant",
    imagePath: "assets/rumah mertua heritage.png",
  ),
  CategoryModel(
    id: "6",
    name: "Restaurant",
    imagePath: "assets/rumah mertua heritage.png",
  ),
];
