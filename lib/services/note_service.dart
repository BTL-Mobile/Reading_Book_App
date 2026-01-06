import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pht_04/models/note_model.dart';

class NoteService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Lấy Collection Reference của user hiện tại
  CollectionReference get _notesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  // 1. LẤY DANH SÁCH GHI CHÚ (Real-time)
  Stream<List<NoteModel>> getNotesStream() {
    return _notesRef
        .where('isDeleted', isEqualTo: false) // Chỉ lấy ghi chú chưa xóa
        .orderBy('createdAt', descending: true) // Mới nhất lên đầu
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NoteModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // 2. THÊM GHI CHÚ
  Future<void> addNote(NoteModel note) async {
    await _notesRef.add(note.toMap());
  }

  // 3. CHUYỂN VÀO THÙNG RÁC (Xóa mềm)
  Future<void> moveToTrash(String noteId) async {
    await _notesRef.doc(noteId).update({'isDeleted': true});
  }

  // 4. ĐẾM SỐ LƯỢNG (Cho phần Header)
  Stream<int> getNotesCount() {
    return _notesRef
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.size);
  }

  Future<void> updateNote(NoteModel note) async {
    if (note.id == null) return; // Không có ID thì không sửa được

    // Cập nhật lại thông tin (trừ ngày tạo createdAt giữ nguyên)
    await _notesRef.doc(note.id).update({
      'bookTitle': note.bookTitle,
      'content': note.content,
      'pageNumber': note.pageNumber,
      'hasFlashcard': note.hasFlashcard,
      // Không update 'createdAt'
    });
  }

  // 6. LẤY DANH SÁCH TRONG THÙNG RÁC (isDeleted = true)
  Stream<List<NoteModel>> getTrashNotesStream() {
    return _notesRef
        .where('isDeleted', isEqualTo: true) // Chỉ lấy cái đã xóa
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NoteModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // 7. KHÔI PHỤC GHI CHÚ (Sửa isDeleted thành false)
  Future<void> restoreNote(String noteId) async {
    await _notesRef.doc(noteId).update({'isDeleted': false});
  }

  // 8. XÓA VĨNH VIỄN (Xóa thật khỏi Database)
  Future<void> deleteNotePermanently(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }
}
