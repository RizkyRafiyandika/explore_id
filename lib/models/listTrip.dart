class ListTrip {
  final String imagePath;
  final String name;

  ListTrip({required this.imagePath, required this.name});
}

List<ListTrip> ListTrips = [
  ListTrip(imagePath: "assets/malioboro.jpg", name: "Fruits"),
  ListTrip(imagePath: "assets/malioboro.jpg", name: "Vegetables"),
  ListTrip(imagePath: "assets/malioboro.jpg", name: "Dairy"),
  ListTrip(imagePath: "assets/malioboro.jpg", name: "Meat"),
];
