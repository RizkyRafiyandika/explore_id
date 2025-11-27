import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/admin/location_picker_screen.dart';
import 'package:explore_id/provider/admin_provider.dart';
import 'package:explore_id/widget/admin/custom_text_field.dart';
import 'package:explore_id/widget/admin/category_selector.dart';
import 'package:explore_id/widget/admin/location_picker_field.dart';
import 'package:explore_id/widget/admin/submit_button.dart';

class AdminAddDestinationScreen extends StatefulWidget {
  const AdminAddDestinationScreen({super.key});

  @override
  State<AdminAddDestinationScreen> createState() =>
      _AdminAddDestinationScreenState();
}

class _AdminAddDestinationScreenState extends State<AdminAddDestinationScreen> {
  late AdminProvider _adminProvider;

  @override
  void initState() {
    super.initState();
    _adminProvider = Provider.of<AdminProvider>(context, listen: false);
  }

  Future<void> _pickLocation(AdminProvider provider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null) {
      provider.setLocation(result);
    }
  }

  Future<void> _submitForm(AdminProvider provider) async {
    if (provider.formKey.currentState!.validate()) {
      try {
        final success = await provider.submitDestination();

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destinasi berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan destinasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Destinasi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: adminProvider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Trip
                  CustomTextField(
                    controller: adminProvider.idController,
                    label: 'ID Trip',
                    hint: 'Contoh: trip1',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'ID tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 15),

                  // Nama Destinasi
                  CustomTextField(
                    controller: adminProvider.nameController,
                    label: 'Nama Destinasi',
                    hint: 'Contoh: Gunung Bromo',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 15),

                  // Daerah
                  CustomTextField(
                    controller: adminProvider.daerahController,
                    label: 'Daerah',
                    hint: 'Contoh: Jawa Timur',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Daerah tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 15),

                  // Category Selector
                  CategorySelector(
                    selectedCategory: adminProvider.labelController.text,
                    categories: adminProvider.categories,
                    onCategorySelected: (category) {
                      adminProvider.setCategory(category);
                    },
                  ),
                  // Hidden validator for category
                  TextFormField(
                    controller: adminProvider.labelController,
                    style: const TextStyle(height: 0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Pilih salah satu kategori' : null,
                  ),
                  const SizedBox(height: 15),

                  // Harga
                  CustomTextField(
                    controller: adminProvider.priceController,
                    label: 'Harga (Rp)',
                    hint: 'Contoh: 75000',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Harga tidak boleh kosong';
                      if (double.tryParse(value) == null)
                        return 'Harga harus berupa angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Location Picker
                  LocationPickerField(
                    latitudeController: adminProvider.latitudeController,
                    longitudeController: adminProvider.longitudeController,
                    onMapButtonPressed: () => _pickLocation(adminProvider),
                  ),
                  const SizedBox(height: 15),

                  // URL Gambar
                  CustomTextField(
                    controller: adminProvider.imagePathController,
                    label: 'URL Gambar',
                    hint: 'https://...',
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'URL Gambar tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 15),

                  // Deskripsi
                  CustomTextField(
                    controller: adminProvider.descriptionController,
                    label: 'Deskripsi',
                    hint: 'Jelaskan tentang destinasi ini...',
                    maxLines: 5,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Deskripsi tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  SubmitButton(
                    onPressed: () => _submitForm(adminProvider),
                    isLoading: adminProvider.isLoading,
                    label: 'Simpan Destinasi',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
