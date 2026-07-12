// ============================================================
// [Session 4] Dart Class — model data untuk tugas kuliah
// isDone adalah mutable field yang akan di-update via setState
// ============================================================

// [Session 4] Class dengan mutable field (bukan final) karena state berubah
class Task {
  final String id;
  final String courseId;
  final String title;
  bool isDone; // [Session 4] Mutable — diubah saat user mencentang

  Task({
    required this.id,
    required this.courseId,
    required this.title,
    this.isDone = false, // [Session 4] Default parameter value
  });
}

// [Session 4] Top-level mutable list — state global sederhana
// Di app nyata ini akan dikelola oleh state management seperti Provider/Riverpod
List<Task> sampleTasks = [
  Task(id: 't1', courseId: 'c1', title: 'Baca materi Widget Flutter'),
  Task(id: 't2', courseId: 'c1', title: 'Kerjakan latihan StatefulWidget'),
  Task(id: 't3', courseId: 'c1', title: 'Submit tugas layout'),
  Task(id: 't4', courseId: 'c2', title: 'Buat diagram ER untuk tugas 1'),
  Task(id: 't5', courseId: 'c2', title: 'Latihan soal SQL JOIN'),
  Task(id: 't6', courseId: 'c3', title: 'Review slide UML diagram'),
  Task(id: 't7', courseId: 'c3', title: 'Buat use case diagram'),
  Task(id: 't8', courseId: 'c4', title: 'Pelajari model OSI Layer'),
  Task(id: 't9', courseId: 'c5', title: 'Coba implementasi decision tree'),
];
