import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Note>> watchNotes() {
    return _db
        .collection('note')
        .where('status', isEqualTo: 'active')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList(),
    );
  }

  Future<void> addNote({
    required String content,
    required int pageNumber,
    required String bookId,
    String userId = 'test_user_001',
  }) async {
    // dùng Timestamp.now để tránh null (và orderBy chạy ổn ngay)
    final now = Timestamp.now();

    await _db.collection('note').add({
      'bookId': bookId,
      'content': content,
      'createdAt': now,
      'deletedAt': null,
      'isConverted': false,
      'pageNumber': pageNumber,
      'status': 'active',
      'updatedAt': now,
      'userId': userId,
    });
  }
}
