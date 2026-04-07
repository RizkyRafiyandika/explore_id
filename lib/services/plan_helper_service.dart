import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/models/plan_option_model.dart';

class PlanHelperService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance
  static final PlanHelperService _instance = PlanHelperService._internal();
  factory PlanHelperService() => _instance;
  PlanHelperService._internal();

  /// Mengambil data kartu swipe (Plan Options) dari koleksi 'suggestion'
  /// Data diurutkan berdasarkan field 'order' untuk konsistensi UI.
  Future<List<PlanOption>> getPlanOptions() async {
    try {
      final querySnapshot = await _firestore
          .collection('suggestion')
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => PlanOption.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error fetching plan options: $e");
      // Return empty list jika terjadi error agar UI tidak crash
      return [];
    }
  }

  /// Menambah data baru ke koleksi suggestion (jika dibutuhkan di masa depan)
  Future<void> addPlanOption(PlanOption option) async {
    try {
      await _firestore.collection('suggestion').add(option.toFirestore());
    } catch (e) {
      print("❌ Error adding plan option: $e");
      rethrow;
    }
  }
}
