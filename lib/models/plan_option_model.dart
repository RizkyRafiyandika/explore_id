import 'package:cloud_firestore/cloud_firestore.dart';

class PlanOption {
  final String id;
  final String title;
  final String key;
  final String type; // 'category' atau 'price'
  final int order;
  final String? imageUrl;

  PlanOption({
    required this.id,
    required this.title,
    required this.key,
    required this.type,
    required this.order,
    this.imageUrl,
  });

  // Factory untuk membuat model dari Firestore Snapshot
  factory PlanOption.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PlanOption(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      key: data['key']?.toString() ?? '',
      type: data['type']?.toString() ?? 'category',
      // Mengonversi field 'order' secara aman (bisa berupa num atau string di Firestore)
      order: num.tryParse(data['order']?.toString() ?? '0')?.toInt() ?? 0,
      imageUrl: data['image_url']?.toString(),
    );
  }

  // Method untuk konversi model kembali ke Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'key': key,
      'type': type,
      'order': order,
      'image_url': imageUrl,
    };
  }
}
