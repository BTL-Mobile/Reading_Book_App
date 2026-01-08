import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= ACTIVE NOTES =================
  Stream<List<Note>> watchNotes() {
    return _db
        .collection('note')
        .where('status', isEqualTo: 'active')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Note.fromFirestore(d)).toList());
  }

  // ================= TRASH NOTES =================
  Stream<List<Note>> watchTrashNotes() {
    return _db
        .collection('note')
        .where('status', isEqualTo: 'trash')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Note.fromFirestore(d)).toList());
  }

  // ================= SINGLE NOTE =================
  Stream<Note?> watchNoteById(String noteId) {
    return _db.collection('note').doc(noteId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Note.fromFirestore(doc);
    });
  }

  // ================= ADD NOTE =================
  Future<void> addNote({
    required String content,
    required int pageNumber,
    required String bookId,
    required String bookTitle,
    String? userId,
    bool createFlashcardFlag = false, // ✅ đổi tên biến để không đè hàm
  }) async {
    final now = Timestamp.now();

    // ✅ add() trả về DocumentReference
    final DocumentReference<Map<String, dynamic>> noteRef =
    await _db.collection('note').add({
      'content': content,
      'pageNumber': pageNumber,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'status': 'active',
      'isConverted': createFlashcardFlag, // ✅ QUAN TRỌNG: để hiện nhãn Flashcard
      'createdAt': now,
      'updatedAt': now,
      'deletedAt': null,
      if (userId != null) 'userId': userId,
    });

    // ✅ chỉ tạo flashcard khi bật switch
    if (createFlashcardFlag) {
      await createFlashcard(
        noteId: noteRef.id,
        question: 'Câu hỏi/Tiêu đề về: $bookTitle',
        answer: content,
      );
    }
  }

  // ================= UPDATE NOTE =================
  Future<void> updateNote({
    required String noteId,
    required String content,
    required int pageNumber,
    required String bookId,
    required String bookTitle,
  }) async {
    await _db.collection('note').doc(noteId).update({
      'content': content,
      'pageNumber': pageNumber,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'updatedAt': Timestamp.now(),
    });
  }

  // ================= TRASH =================
  Future<void> moveToTrash(String noteId) async {
    await _db.collection('note').doc(noteId).update({
      'status': 'trash',
      'deletedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> restoreFromTrash(String noteId) async {
    await _db.collection('note').doc(noteId).update({
      'status': 'active',
      'deletedAt': null,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deletePermanently(String noteId) async {
    await _db.collection('note').doc(noteId).delete();
  }

  // ================= FLASHCARD =================
  Future<void> createFlashcard({
    required String noteId,
    required String question,
    required String answer,
  }) async {
    await _db.collection('flashcards').add({
      'noteId': noteId,
      'question': question,
      'answer': answer,
      'createdAt': Timestamp.now(),
      'reviewCount': 0,
      'dueAt': Timestamp.now(),
      'lastReviewedAt': null,
    });

    await _db.collection('note').doc(noteId).update({
      'isConverted': true,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> createFlashcardFromNote({
    required String noteId,
    required String frontText,
    required String backText,
  }) async {
    return createFlashcard(
      noteId: noteId,
      question: frontText,
      answer: backText,
    );
  }

  Future<void> createFlashcardFromNoteWithNote({
    required Note note,
    required String frontText,
    required String backText,
  }) async {
    return createFlashcard(
      noteId: note.id,
      question: frontText,
      answer: backText,
    );
  }

  // ================= READ LATEST FLASHCARD =================
  Stream<Map<String, String>?> watchLatestFlashcardForNote(String noteId) {
    return _db
        .collection('flashcards')
        .where('noteId', isEqualTo: noteId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((s) {
      if (s.docs.isEmpty) return null;
      final d = s.docs.first.data();
      return {
        'question': (d['question'] ?? '').toString(),
        'answer': (d['answer'] ?? '').toString(),
      };
    });
  }
}
