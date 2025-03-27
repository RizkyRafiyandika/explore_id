class Event {
  final String title;
  final String desk;
  final String start;
  final String end;

  Event({
    required this.title,
    required this.desk,
    required this.start,
    required this.end,
  });
}

Map<DateTime, List<Event>> eventDescriptions = {
  DateTime(2025, 3, 17): [
    Event(
      title: "Eksplorasi Candi Prambanan",
      desk:
          "Menjelajahi kompleks Candi Prambanan, menikmati arsitektur dan sejarah.",
      start: "08:00",
      end: "10:00",
    ),
    Event(
      title: "Foto & Dokumentasi",
      desk: "Mengabadikan momen di berbagai spot terbaik di Candi Prambanan.",
      start: "10:00",
      end: "10:30",
    ),
    Event(
      title: "Mengunjungi Candi Sewu",
      desk:
          "Melihat keindahan Candi Sewu, candi Buddha yang masih berada di kompleks Prambanan.",
      start: "10:30",
      end: "11:30",
    ),
    Event(
      title: "Makan Siang di Bale Roso Resto",
      desk:
          "Menikmati makanan khas Jogja seperti Gudeg dan Ayam Ingkung di Bale Roso Resto.",
      start: "11:30",
      end: "12:30",
    ),
    Event(
      title: "Berkunjung ke Tebing Breksi",
      desk:
          "Menikmati pemandangan indah dan tebing batu yang eksotis di Tebing Breksi.",
      start: "12:30",
      end: "14:00",
    ),
    Event(
      title: "Santai di Obelix Hills",
      desk: "Menikmati sunset dan pemandangan kota Jogja dari atas bukit.",
      start: "14:30",
      end: "16:30",
    ),
    Event(
      title: "Makan Malam di Abhayagiri Resto",
      desk:
          "Makan malam sambil menikmati pemandangan Gunung Merapi di Abhayagiri Resto.",
      start: "17:00",
      end: "18:30",
    ),
    Event(
      title: "Kembali ke Hotel",
      desk: "Perjalanan kembali ke hotel setelah seharian menikmati wisata.",
      start: "19:00",
      end: "20:30",
    ),
  ],
  DateTime(2024, 3, 18): [
    Event(
      title: "Meeting Tim",
      desk: "Meeting dengan tim proyek.",
      start: "13:00",
      end: "14:00",
    ),
  ],
  DateTime(2024, 3, 19): [
    Event(
      title: "Hari Libur Nasional",
      desk: "Libur bersama, tidak ada pekerjaan.",
      start: "00:00",
      end: "23:59",
    ),
  ],
};

// Fungsi untuk mendapatkan event berdasarkan tanggal
List<Event> getEventsForDay(DateTime day) {
  DateTime normalizedDate = DateTime(day.year, day.month, day.day);
  return eventDescriptions[normalizedDate] ?? [];
}
