class IndividualBar {
  final int x;
  final double y;

  IndividualBar({required this.x, required this.y});
}

class BarData {
  final List<double> monthlyValues;

  List<IndividualBar> barData = [];

  BarData({required this.monthlyValues});

  void initializeBarData() {
    barData = List.generate(
      12,
      (index) => IndividualBar(x: index, y: monthlyValues[index]),
    );
  }
}
