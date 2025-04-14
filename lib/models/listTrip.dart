class ListTrip {
  final String id;
  final String imagePath;
  final String name;
  final String daerah;
  final String label;
  final String desk;

  ListTrip({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.daerah,
    required this.label,
    required this.desk,
  });
}

List<ListTrip> ListTrips = [
  ListTrip(
    id: "trip1",
    imagePath: "assets/bromo.jpg",
    name: "Bromo Mountain",
    daerah: "Jawa Timur",
    label: "Mountain",
    desk:
        "Gunung Bromo atau dalam bahasa Tengger dieja {Brama}, juga disebut Kaldera Tengger adalah sebuah gunung berapi aktif di Jawa Timur, Indonesia. Gunung ini memiliki ketinggian 2.614 meter di atas permukaan laut dan berada dalam empat wilayah kabupaten, yakni Kabupaten Probolinggo, Kabupaten Pasuruan, Kabupaten Lumajang, dan Kabupaten Malang. Gunung Bromo terkenal sebagai objek wisata utama di Jawa Timur. Sebagai sebuah objek wisata, Bromo menjadi menarik karena statusnya sebagai gunung berapi yang masih aktif. Gunung Bromo termasuk dalam kawasan Taman Nasional Bromo Tengger Semeru.",
  ),
  ListTrip(
    id: "trip2",
    imagePath: "assets/prambanan.jpg",
    name: "Prambanan Temple",
    daerah: "Yogyakarta",
    label: "Culture",
    desk:
        "Candi Hindu terbesar di Indonesia, warisan budaya yang memiliki ukiran epik Ramayana.",
  ),
  ListTrip(
    id: "trip3",
    imagePath: "assets/pulau seribu.jpg",
    name: "Pulau Seribu",
    daerah: "DKI Jakarta",
    label: "Nature",
    desk:
        "Kumpulan pulau cantik dekat Jakarta, cocok untuk snorkeling dan liburan tropis.",
  ),
  ListTrip(
    id: "trip4",
    imagePath: "assets/rumah mertua heritage.png",
    name: "Rumah Mertua Heritage",
    daerah: "Yogyakarta",
    label: "Culinary",
    desk:
        "Restoran dengan suasana tradisional Jawa yang menyajikan makanan khas dengan cita rasa otentik.",
  ),
  ListTrip(
    id: "trip5",
    imagePath: "assets/quest mark.jpeg",
    name: "Ancol",
    daerah: "DKI Jakarta",
    label: "Beach",
    desk:
        "Kompleks wisata di Jakarta dengan pantai, wahana bermain, dan fasilitas rekreasi keluarga.",
  ),
  ListTrip(
    id: "trip6",
    imagePath: "assets/quest mark.jpeg",
    name: "Raja Ampat",
    daerah: "Papua Barat",
    label: "Nature",
    desk:
        "Surga dunia bawah laut dengan terumbu karang dan keanekaragaman hayati laut yang luar biasa.",
  ),
  ListTrip(
    id: "trip7",
    imagePath: "assets/quest mark.jpeg",
    name: "Tana Toraja",
    daerah: "Sulawesi Selatan",
    label: "Culture",
    desk:
        "Wilayah adat yang terkenal dengan tradisi pemakaman unik dan rumah adat Tongkonan.",
  ),
  ListTrip(
    id: "trip8",
    imagePath: "assets/quest mark.jpeg",
    name: "Kawah Ijen",
    daerah: "Jawa Timur",
    label: "Mountain",
    desk:
        "Gunung dengan danau asam dan fenomena api biru langka yang menarik wisatawan dunia.",
  ),
  ListTrip(
    id: "trip9",
    imagePath: "assets/quest mark.jpeg",
    name: "Labuan Bajo",
    daerah: "NTT",
    label: "Monument",
    desk:
        "Pintu gerbang menuju Taman Nasional Komodo dengan pantai indah dan spot diving terbaik.",
  ),
  ListTrip(
    id: "trip10",
    imagePath: "assets/quest mark.jpeg",
    name: "Danau Toba",
    daerah: "Sumatera Utara",
    label: "Nautre",
    desk:
        "Danau vulkanik terbesar di Asia Tenggara yang menyimpan legenda dan budaya Batak.",
  ),
  ListTrip(
    id: "trip11",
    imagePath: "assets/quest mark.jpeg",
    name: "Gunung Rinjani",
    daerah: "NTB",
    label: "Mountain",
    desk:
        "Gunung tertinggi kedua di Indonesia dengan jalur pendakian menantang dan pemandangan spektakuler.",
  ),
];
