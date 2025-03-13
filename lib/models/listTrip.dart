class ListTrip {
  final String imagePath;
  final String name;

  ListTrip({required this.imagePath, required this.name});
}

List<ListTrip> ListTrips = [
  ListTrip(imagePath: "assets/malioboro.jpg", name: "Malioboro Moutain"),
  ListTrip(imagePath: "assets/prambanan.jpg", name: "prambanan temple"),
  ListTrip(imagePath: "assets/pulau seribu.jpg", name: "beach"),
  ListTrip(imagePath: "assets/rumah mertua heritage.png", name: "restaurant"),
];
