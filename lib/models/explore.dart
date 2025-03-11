class ExploreModel {
  final String picturePath;
  final String buttonText;

  ExploreModel({
    required this.picturePath,
    this.buttonText = "Explore", // Default "Explore"
  });
}

final List<ExploreModel> exploreItems = [
  ExploreModel(picturePath: "assets/maliomoro.jpg"),
  ExploreModel(picturePath: "assets/prambanan.jpg"),
  ExploreModel(picturePath: "assets/pulau seribu.jpg"),
];
