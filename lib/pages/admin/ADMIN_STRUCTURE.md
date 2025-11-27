# 📁 Admin Module Structure

## Overview
Struktur terpisah untuk modul Admin dengan pemisahan concerns antara Model, Provider, Widget, dan Screen.

## 📂 Folder Structure

```
lib/
├── models/
│   └── destination_model.dart          # Model untuk Destinasi
├── provider/
│   └── admin_provider.dart              # Provider untuk state management Admin
├── pages/admin/
│   ├── admin_dashboard.dart             # Dashboard Admin (Main)
│   ├── admin_add_destination_screen.dart # Screen untuk menambah destinasi (NEW)
│   └── location_picker_screen.dart      # Screen untuk memilih lokasi dari map
└── widget/admin/
    ├── custom_text_field.dart           # Widget input text field
    ├── category_selector.dart           # Widget selector kategori dengan modal
    ├── location_picker_field.dart       # Widget untuk koordinat lokasi
    └── submit_button.dart               # Widget tombol submit
```

## 🔧 Component Details

### 1. **Model - `destination_model.dart`**
Menyimpan data struktur destinasi dengan konversi ke/dari ListTrip.

**Features:**
- `toListTrip()` - Konversi ke ListTrip untuk API
- `toJson()` - Konversi ke JSON
- `fromJson()` - Create dari JSON
- `fromListTrip()` - Create dari ListTrip
- `copyWith()` - Copy dengan update

### 2. **Provider - `admin_provider.dart`**
Mengelola state dan logika bisnis untuk Admin.

**State Management:**
- Form controllers untuk semua fields
- Loading state management
- Category list
- Form validation & submission

**Methods:**
- `setLoading()` - Set loading status
- `setLocation()` - Set lokasi dari map picker
- `setCategory()` - Set kategori yang dipilih
- `getFormData()` - Get data form sebagai DestinationModel
- `submitDestination()` - Submit ke Firebase
- `resetForm()` - Reset semua fields

### 3. **Widgets - `widget/admin/`**

#### CustomTextField
Input text field yang reusable dengan label dan validator.

```dart
CustomTextField(
  controller: controller,
  label: 'Label',
  hint: 'Hint text',
  keyboardType: TextInputType.text,
  validator: (value) => value!.isEmpty ? 'Required' : null,
)
```

#### CategorySelector
Modal bottom sheet untuk memilih kategori.

```dart
CategorySelector(
  selectedCategory: provider.labelController.text,
  categories: provider.categories,
  onCategorySelected: (category) => provider.setCategory(category),
)
```

#### LocationPickerField
Field untuk menampilkan & edit koordinat dengan tombol map picker.

```dart
LocationPickerField(
  latitudeController: controller,
  longitudeController: controller,
  onMapButtonPressed: () => _pickLocation(),
)
```

#### SubmitButton
Button submit dengan loading indicator.

```dart
SubmitButton(
  onPressed: () => _submit(),
  isLoading: provider.isLoading,
  label: 'Simpan Destinasi',
)
```

### 4. **Screen - `admin_add_destination_screen.dart`**
Screen utama yang menggunakan semua komponen di atas.

**Features:**
- Consumer pattern dengan Provider
- Form validation
- Location picker integration
- Error handling dengan SnackBar

## 🚀 Usage

### Di AdminDashboard atau tempat lain:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AdminAddDestinationScreen()),
)
```

### Untuk mengakses provider:
```dart
final adminProvider = Provider.of<AdminProvider>(context);
// atau dengan Consumer
Consumer<AdminProvider>(
  builder: (context, adminProvider, _) {
    // Widget tree
  },
)
```

## ✅ Best Practices

1. **Separation of Concerns**: Model, Provider, Widget, dan Screen terpisah
2. **Reusability**: Widgets dapat digunakan di screen lain
3. **State Management**: Menggunakan Provider untuk centralized state
4. **Validation**: Form validation di level Provider
5. **Error Handling**: Try-catch di Provider untuk error handling
6. **Resource Management**: Controllers di-dispose di Provider

## 📝 Migration Notes

Jika mengganti dari `add_destination_screen.dart` ke `admin_add_destination_screen.dart`:

1. Update import di `admin_dashboard.dart`:
   ```dart
   // OLD
   import 'package:explore_id/pages/admin/add_destination_screen.dart';
   
   // NEW
   import 'package:explore_id/pages/admin/admin_add_destination_screen.dart';
   ```

2. Update navigation:
   ```dart
   // OLD
   Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDestinationScreen()))
   
   // NEW
   Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddDestinationScreen()))
   ```

3. Pastikan AdminProvider sudah di-register di main.dart MultiProvider

## 🔗 Dependencies Required

- `provider: ^6.x.x` (untuk state management)
- `google_maps_flutter: ^2.x.x` (untuk location picker)
- `geolocator: ^x.x.x` (untuk current location)

---

**Struktur ini memudahkan:**
- Maintenance & debugging
- Testing individual components
- Reuse widgets di screens lain
- Scaling untuk features tambahan
