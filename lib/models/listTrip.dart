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
}

List<ListTrip> ListTrips = [
  ListTrip(
    id: "trip1",
    imagePath: "assets/bromo.jpg",
    name: "Gunung Bromo",
    daerah: "Jawa Timur",
    label: "Mountain",
    desk:
        "Gunung Bromo atau dalam bahasa Tengger dieja {Brama}, juga disebut Kaldera Tengger adalah sebuah gunung berapi aktif di Jawa Timur, Indonesia...",
    latitude: -7.942493,
    longitude: 112.953012,
  ),
  ListTrip(
    id: "trip2",
    imagePath: "assets/prambanan.jpg",
    name: "Prambanan Temple",
    daerah: "Yogyakarta",
    label: "Culture",
    desk:
        "Candi Hindu terbesar di Indonesia, warisan budaya yang memiliki ukiran epik Ramayana.",
    latitude: -7.752020,
    longitude: 110.491298,
  ),
  ListTrip(
    id: "trip3",
    imagePath: "assets/pulau seribu.jpg",
    name: "Pulau Seribu",
    daerah: "DKI Jakarta",
    label: "Nature",
    desk:
        "Kumpulan pulau cantik dekat Jakarta, cocok untuk snorkeling dan liburan tropis.",
    latitude: -5.738150,
    longitude: 106.605942,
  ),
  ListTrip(
    id: "trip4",
    imagePath: "assets/rumah mertua heritage.png",
    name: "Rumah Mertua Heritage",
    daerah: "Yogyakarta",
    label: "Culinary",
    desk:
        "Restoran dengan suasana tradisional Jawa yang menyajikan makanan khas dengan cita rasa otentik.",
    latitude: -7.748174,
    longitude: 110.355607,
  ),
  ListTrip(
    id: "trip5",
    imagePath: "assets/ancol.jpeg",
    name: "Ancol",
    daerah: "DKI Jakarta",
    label: "Beach",
    desk:
        "Kompleks wisata di Jakarta dengan pantai, wahana bermain, dan fasilitas rekreasi keluarga.",
    latitude: -6.125556,
    longitude: 106.836389,
  ),
  ListTrip(
    id: "trip6",
    imagePath: "assets/raja_ampat.jpeg",
    name: "Raja Ampat",
    daerah: "Papua Barat",
    label: "Nature",
    desk:
        "Surga dunia bawah laut dengan terumbu karang dan keanekaragaman hayati laut yang luar biasa.",
    latitude: -0.233333,
    longitude: 130.516667,
  ),
  ListTrip(
    id: "trip7",
    imagePath: "assets/tana_toraja.jpeg",
    name: "Tana Toraja",
    daerah: "Sulawesi Selatan",
    label: "Culture",
    desk:
        "Wilayah adat yang terkenal dengan tradisi pemakaman unik dan rumah adat Tongkonan.",
    latitude: -3.069700,
    longitude: 119.836500,
  ),
  ListTrip(
    id: "trip8",
    imagePath: "assets/kawah_ijen.jpeg",
    name: "Kawah Ijen",
    daerah: "Jawa Timur",
    label: "Mountain",
    desk:
        "Gunung dengan danau asam dan fenomena api biru langka yang menarik wisatawan dunia.",
    latitude: -8.058889,
    longitude: 114.242222,
  ),
  ListTrip(
    id: "trip9",
    imagePath: "assets/labuhan_bajo.jpg",
    name: "Labuan Bajo",
    daerah: "NTT",
    label: "Monument",
    desk:
        "Pintu gerbang menuju Taman Nasional Komodo dengan pantai indah dan spot diving terbaik.",
    latitude: -8.496600,
    longitude: 119.887700,
  ),
  ListTrip(
    id: "trip10",
    imagePath: "assets/danau_toba.jpeg",
    name: "Danau Toba",
    daerah: "Sumatera Utara",
    label: "Nature",
    desk:
        "Danau vulkanik terbesar di Asia Tenggara yang menyimpan legenda dan budaya Batak.",
    latitude: 2.684400,
    longitude: 98.940100,
  ),
  ListTrip(
    id: "trip11",
    imagePath: "assets/rinjani.jpeg",
    name: "Gunung Rinjani",
    daerah: "NTB",
    label: "Mountain",
    desk:
        "Gunung tertinggi kedua di Indonesia dengan jalur pendakian menantang dan pemandangan spektakuler.",
    latitude: -8.411400,
    longitude: 116.457000,
  ),
];
