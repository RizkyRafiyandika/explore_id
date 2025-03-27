class ExploreModel {
  final String picturePath;
  final String buttonText;

  ExploreModel({required this.picturePath, this.buttonText = "Explore"});
}

final List<ExploreModel> exploreItems = [
  ExploreModel(picturePath: "assets/bromo.jpg"),
  ExploreModel(picturePath: "assets/prambanan.jpg"),
  ExploreModel(picturePath: "assets/pulau seribu.jpg"),
];
