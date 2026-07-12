// ============================================================
// [Session 4] Dart Class — prinsip OOP di Dart
// Setiap Course punya data tetap (final) dan list tugas
// ============================================================

// [Session 4] Typed variables & null safety
class Course {
  final String id;
  final String name;
  final String lecturer;
  final String schedule;
  final String emoji;
  final String description;

  // [Session 4] Named constructor dengan positional & named params
  const Course({
    required this.id,
    required this.name,
    required this.lecturer,
    required this.schedule,
    required this.emoji,
    required this.description,
  });
}

// [Session 4] Top-level list — data statis sebagai contoh state awal
// Ini menunjukkan bahwa Dart mendukung typed List<T>
final List<Course> sampleCourses = [
  const Course(
    id: 'c1',
    name: 'Pemrograman Mobile',
    lecturer: 'Dr. Alek Pertamax',
    schedule: 'Senin, 08.00–10.00',
    emoji: '📱',
    description:
        'Membahas pengembangan aplikasi mobile menggunakan Flutter dan Dart. '
        'Mulai dari dasar widget, layout, hingga manajemen state.',
  ),
  const Course(
    id: 'c2',
    name: 'Basis Data',
    lecturer: 'Dr. Sari Dewi',
    schedule: 'Selasa, 10.00–12.00',
    emoji: '🗄️',
    description:
        'Konsep relasional, SQL, normalisasi, dan desain skema database '
        'untuk aplikasi nyata.',
  ),
  const Course(
    id: 'c3',
    name: 'Rekayasa Perangkat Lunak',
    lecturer: 'Prof. Budi Santoso',
    schedule: 'Rabu, 13.00–15.00',
    emoji: '⚙️',
    description:
        'Metodologi pengembangan perangkat lunak, desain arsitektur, '
        'dan praktik clean code.',
  ),
  const Course(
    id: 'c4',
    name: 'Jaringan Komputer',
    lecturer: 'Dr. Maya Indah',
    schedule: 'Kamis, 08.00–10.00',
    emoji: '🌐',
    description:
        'Protokol jaringan, model OSI, TCP/IP, dan keamanan jaringan dasar.',
  ),
  const Course(
    id: 'c5',
    name: 'Kecerdasan Buatan',
    lecturer: 'Prof. Rizky Fauzan',
    schedule: 'Jumat, 10.00–12.00',
    emoji: '🤖',
    description:
        'Pengantar AI, machine learning, dan penerapannya dalam kehidupan nyata.',
  ),
];
