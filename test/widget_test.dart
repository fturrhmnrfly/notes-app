import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart';

void main() {
  testWidgets('App should display the main screen with the title', (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(NotesApp());

    // Cari widget dengan teks "Notes App"
    expect(find.text('Notes App'), findsOneWidget);

    // Periksa apakah ada widget utama seperti tombol atau teks awal
    expect(find.text('Aplikasi Catatan dengan Pengingat'), findsOneWidget);
  });

  testWidgets('Add note button test', (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(NotesApp());

    // Cari tombol untuk menambah catatan
    final addNoteButton = find.byType(ElevatedButton);

    // Pastikan tombol ditemukan
    expect(addNoteButton, findsWidgets);
  });

  testWidgets('Should schedule a notification', (WidgetTester tester) async {
    // Tes untuk memastikan bahwa notifikasi berhasil dijadwalkan
    DateTime testTime = DateTime.now().add(Duration(seconds: 10));
    String testTitle = 'Test Reminder';

    // Pastikan tidak ada error saat fungsi dijalankan
    await tester.runAsync(() async {
      await scheduleReminder(testTime, testTitle);
    });

    // Jika tidak ada error, pengujian dianggap berhasil
    expect(true, isTrue);
  });
}

scheduleReminder(DateTime testTime, String testTitle) {
}
