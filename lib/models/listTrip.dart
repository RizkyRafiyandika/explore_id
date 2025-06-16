import 'package:cloud_firestore/cloud_firestore.dart';

class ListTrip {
  final String id;
  final String imagePath;
  final String name;
  final String daerah;
  final String label;
  final String desk;
  final double latitude; // tambahan
  final double longitude; // tambahan

  ListTrip({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.daerah,
    required this.label,
    required this.desk,
    required this.latitude, // tambahan
    required this.longitude, // tambahan
  });
  // Factory method untuk parsing dari Firestore
  factory ListTrip.fromMap(Map<String, dynamic> data) {
    return ListTrip(
      id: data['id'] ?? '',
      imagePath: data['imagePath'] ?? '',
      name: data['name'] ?? '',
      daerah: data['daerah'] ?? '',
      label: data['label'] ?? '',
      desk: data['desk'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
    );
  }

  // ✅ Fungsi ambil dari Firestore
  static Future<List<ListTrip>> getDestinations() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("destinations").get();

      return querySnapshot.docs.map((doc) {
        return ListTrip.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print("❌ Error fetching destinations: $e");
      return [];
    }
  }
}

// List<ListTrip> ListTrips = [
//   ListTrip(
//     id: "trip1",
//     imagePath:
//         "https://i.pinimg.com/736x/57/25/33/57253382ab361d1cdd4fc6baf17b4bda.jpg",
//     name: "Gunung Bromo",
//     daerah: "Jawa Timur",
//     label: "Mountain",
//     desk:
//         "Gunung Bromo atau dalam bahasa Tengger dieja 'Brama', juga disebut Kaldera Tengger, adalah sebuah gunung berapi aktif di Jawa Timur, Indonesia. Gunung ini memiliki ketinggian 2.614 meter di atas permukaan laut dan berada dalam empat wilayah kabupaten, yakni Kabupaten Probolinggo, Kabupaten Pasuruan, Kabupaten Lumajang, dan Kabupaten Malang. Gunung Bromo terkenal sebagai objek wisata utama di Jawa Timur. Sebagai sebuah objek wisata, Bromo menjadi menarik karena statusnya sebagai gunung berapi yang masih aktif. Gunung Bromo termasuk dalam kawasan Taman Nasional Bromo Tengger Semeru.",
//     latitude: -7.942493,
//     longitude: 112.953012,
//   ),
//   ListTrip(
//     id: "trip2",
//     imagePath:
//         "https://i.pinimg.com/736x/e5/55/6a/e5556added1608364aa655a94b8aff2b.jpg",
//     name: "Prambanan Temple",
//     daerah: "Yogyakarta",
//     label: "Culture",
//     desk:
//         "Candi Hindu terbesar di Indonesia, warisan budaya yang memiliki ukiran epik Ramayana.",
//     latitude: -7.752020,
//     longitude: 110.491298,
//   ),
//   ListTrip(
//     id: "trip3",
//     imagePath:
//         "https://i.pinimg.com/736x/18/48/0b/18480becc238a16cf1792d96ac26c988.jpg",
//     name: "Pulau Seribu",
//     daerah: "DKI Jakarta",
//     label: "Nature",
//     desk:
//         "Kumpulan pulau cantik dekat Jakarta, cocok untuk snorkeling dan liburan tropis.",
//     latitude: -5.738150,
//     longitude: 106.605942,
//   ),
//   ListTrip(
//     id: "trip4",
//     imagePath:
//         "https://i.pinimg.com/736x/24/91/c8/2491c8d5d81dc677ccf21990c46e75b4.jpg",
//     name: "Rumah Mertua Heritage",
//     daerah: "Yogyakarta",
//     label: "Culinary",
//     desk:
//         "Restoran dengan suasana tradisional Jawa yang menyajikan makanan khas dengan cita rasa otentik.",
//     latitude: -7.748174,
//     longitude: 110.355607,
//   ),
//   ListTrip(
//     id: "trip5",
//     imagePath:
//         "https://i.pinimg.com/736x/82/d0/0c/82d00c413396df8bdc24dd85992685d6.jpg",
//     name: "Ancol",
//     daerah: "DKI Jakarta",
//     label: "Beach",
//     desk:
//         "Kompleks wisata di Jakarta dengan pantai, wahana bermain, dan fasilitas rekreasi keluarga.",
//     latitude: -6.125556,
//     longitude: 106.836389,
//   ),
//   ListTrip(
//     id: "trip6",
//     imagePath:
//         "https://i.pinimg.com/736x/2c/84/4c/2c844c225d884bcdb022d4920af284fd.jpg",
//     name: "Raja Ampat",
//     daerah: "Papua Barat",
//     label: "Nature",
//     desk:
//         "Surga dunia bawah laut dengan terumbu karang dan keanekaragaman hayati laut yang luar biasa.",
//     latitude: -0.233333,
//     longitude: 130.516667,
//   ),
//   ListTrip(
//     id: "trip7",
//     imagePath:
//         "https://i.pinimg.com/736x/8a/dd/03/8add03f69d54914d716023d2dfb17492.jpg",
//     name: "Tana Toraja",
//     daerah: "Sulawesi Selatan",
//     label: "Culture",
//     desk:
//         "Wilayah adat yang terkenal dengan tradisi pemakaman unik dan rumah adat Tongkonan.",
//     latitude: -3.069700,
//     longitude: 119.836500,
//   ),
//   ListTrip(
//     id: "trip8",
//     imagePath:
//         "https://i.pinimg.com/736x/65/f9/b9/65f9b91a4acfe7768ce507f5504a8a68.jpg",
//     name: "Kawah Ijen",
//     daerah: "Jawa Timur",
//     label: "Mountain",
//     desk:
//         "Gunung dengan danau asam dan fenomena api biru langka yang menarik wisatawan dunia.",
//     latitude: -8.058889,
//     longitude: 114.242222,
//   ),
//   ListTrip(
//     id: "trip9",
//     imagePath:
//         "https://i.pinimg.com/736x/65/62/17/656217e98ddcc3482fc7bf4f03fdbd27.jpg",
//     name: "Labuan Bajo",
//     daerah: "NTT",
//     label: "Monument",
//     desk:
//         "Pintu gerbang menuju Taman Nasional Komodo dengan pantai indah dan spot diving terbaik.",
//     latitude: -8.496600,
//     longitude: 119.887700,
//   ),
//   ListTrip(
//     id: "trip10",
//     imagePath:
//         "https://i.pinimg.com/736x/9b/f7/aa/9bf7aa222e1ca7278f43330dda1828ee.jpg",
//     name: "Danau Toba",
//     daerah: "Sumatera Utara",
//     label: "Nature",
//     desk:
//         "Danau vulkanik terbesar di Asia Tenggara yang menyimpan legenda dan budaya Batak.",
//     latitude: 2.684400,
//     longitude: 98.940100,
//   ),
//   ListTrip(
//     id: "trip11",
//     imagePath:
//         "https://i.pinimg.com/736x/3d/06/62/3d0662c11af8566dbf1bce2912c409c6.jpg",
//     name: "Gunung Rinjani",
//     daerah: "NTB",
//     label: "Mountain",
//     desk:
//         "Gunung tertinggi kedua di Indonesia dengan jalur pendakian menantang dan pemandangan spektakuler.",
//     latitude: -8.411400,
//     longitude: 116.457000,
//   ),
//   ListTrip(
//     id: "trip12",
//     imagePath:
//         "https://i.pinimg.com/736x/35/46/48/354648aae7ef1f6bbd2f173cca6b36e5.jpg",
//     name: "Monumen Nasional",
//     daerah: "DKI Jakarta",
//     label: "Historical",
//     desk:
//         "Ikon kebanggaan Indonesia dengan museum sejarah dan pemandangan dari puncaknya.",
//     latitude: -6.175392,
//     longitude: 106.827153,
//   ),

//   ListTrip(
//     id: "trip13",
//     imagePath:
//         "https://i.pinimg.com/736x/77/52/37/77523726d9f4e26fbb1d4981f655e13d.jpg",
//     name: "Taman Mini Indonesia Indah",
//     daerah: "DKI Jakarta",
//     label: "Cultural",
//     desk:
//         "Taman budaya dengan paviliun dari seluruh provinsi, cocok untuk wisata edukatif.",
//     latitude: -6.302979,
//     longitude: 106.895451,
//   ),

//   ListTrip(
//     id: "trip14",
//     imagePath:
//         "https://i.pinimg.com/736x/eb/a5/d1/eba5d10d0e3753be32197385d5cf20f7.jpg",
//     name: "Kota Tua Jakarta",
//     daerah: "DKI Jakarta",
//     label: "Culture",
//     desk:
//         "Area bersejarah dengan bangunan kolonial Belanda, museum, dan tempat foto klasik.",
//     latitude: -6.135200,
//     longitude: 106.813301,
//   ),

//   ListTrip(
//     id: "trip16",
//     imagePath:
//         "https://i.pinimg.com/736x/32/6b/7e/326b7e0fdcb89136af4f02f60747f703.jpg",
//     name: "Museum Macan",
//     daerah: "DKI Jakarta",
//     label: "Culture",
//     desk:
//         "Museum seni kontemporer dengan karya seniman Indonesia dan mancanegara.",
//     latitude: -6.192094,
//     longitude: 106.770634,
//   ),
// ];
