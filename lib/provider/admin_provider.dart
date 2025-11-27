import 'package:flutter/material.dart';
import 'package:explore_id/models/destination_model.dart';
import 'package:explore_id/services/destination_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvider extends ChangeNotifier {
  // Form controllers
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController daerahController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imagePathController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DestinationModel> _myDestinations = [];
  List<DestinationModel> get myDestinations => _myDestinations;

  // Categories
  final List<String> categories = [
    'Mountain',
    'Nature',
    'Historical',
    'Cultural',
    'Culinary',
    'Beach',
    'Monument',
  ];

  // Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set location from map picker
  void setLocation(LatLng location) {
    latitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
    notifyListeners();
  }

  // Set selected category
  void setCategory(String category) {
    labelController.text = category;
    notifyListeners();
  }

  // Get current form data as model
  DestinationModel getFormData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw Exception('User must be logged in to add destination');
    }
    return DestinationModel(
      id: idController.text.trim(),
      name: nameController.text.trim(),
      daerah: daerahController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.parse(priceController.text.trim()),
      imagePath: imagePathController.text.trim(),
      label: labelController.text.trim(),
      latitude: double.parse(latitudeController.text.trim()),
      longitude: double.parse(longitudeController.text.trim()),
      userId: user.uid,
    );
  }

  // Submit destination
  Future<bool> submitDestination() async {
    try {
      setLoading(true);

      final destination = getFormData();
      final listTrip = destination.toListTrip();

      await addDestination(listTrip);

      resetForm();
      return true;
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Fetch destinations created by current admin
  Future<void> fetchMyDestinations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      setLoading(true);
      final snapshot =
          await FirebaseFirestore.instance
              .collection('destinations')
              .where('userId', isEqualTo: user.uid)
              .get();

      _myDestinations =
          snapshot.docs.map((doc) {
            return DestinationModel.fromJson(doc.data());
          }).toList();

      notifyListeners();
    } catch (e) {
      print("Error fetching my destinations: $e");
    } finally {
      setLoading(false);
    }
  }

  // Delete destination
  Future<void> deleteDestination(String id) async {
    try {
      setLoading(true);
      await FirebaseFirestore.instance
          .collection('destinations')
          .doc(id)
          .delete();
      _myDestinations.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting destination: $e");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Check if user is owner
  bool isOwner(String? destinationUserId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || destinationUserId == null) return false;
    return user.uid == destinationUserId;
  }

  // Reset form
  void resetForm() {
    idController.clear();
    nameController.clear();
    daerahController.clear();
    descriptionController.clear();
    priceController.clear();
    imagePathController.clear();
    labelController.clear();
    latitudeController.clear();
    longitudeController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    daerahController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imagePathController.dispose();
    labelController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }
}
