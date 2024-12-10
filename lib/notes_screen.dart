import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: androidInitialization);

  await localNotifications.initialize(initializationSettings);

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const NotesScreen(),  // Ganti dengan NotesScreen
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Map<String, dynamic>> _notes = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'Penting';
  String _selectedColor = 'Blue';
  DateTime? _reminderTime;

  // Fungsi untuk menjadwalkan notifikasi pengingat
  Future<void> _scheduleReminder(DateTime dateTime, String title) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel', 'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
    );
    await localNotifications.schedule(
      0, // ID notifikasi
      'Reminder: $title',
      'Waktunya mengingat catatan!',
      dateTime,
      NotificationDetails(android: androidDetails),
    );
  }

  void _addOrEditNote({int? index}) {
    if (index == null) {
      // Tambah Catatan Baru
      setState(() {
        _notes.add({
          'title': _titleController.text,
          'content': _contentController.text,
          'category': _selectedCategory,
          'color': _selectedColor,
          'reminderAt': _reminderTime?.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Jadwalkan notifikasi pengingat jika waktu pengingat ditentukan
        if (_reminderTime != null) {
          _scheduleReminder(_reminderTime!, _titleController.text);
        }
      });
    } else {
      // Edit Catatan
      setState(() {
        _notes[index] = {
          'title': _titleController.text,
          'content': _contentController.text,
          'category': _selectedCategory,
          'color': _selectedColor,
          'reminderAt': _reminderTime?.toIso8601String(),
          'createdAt': _notes[index]['createdAt'], // Tetap gunakan waktu yang sama
        };
        
        // Jadwalkan ulang notifikasi pengingat
        if (_reminderTime != null) {
          _scheduleReminder(_reminderTime!, _titleController.text);
        }
      });
    }
    _clearForm();
    Navigator.pop(context);
  }

  void _showNoteDialog({int? index}) {
    if (index != null) {
      // Jika mengedit, isi form dengan data catatan
      final note = _notes[index];
      _titleController.text = note['title'];
      _contentController.text = note['content'];
      _selectedCategory = note['category'];
      _selectedColor = note['color'];
      _reminderTime = note['reminderAt'] != null
          ? DateTime.parse(note['reminderAt'])
          : null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Tambah Catatan' : 'Edit Catatan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Isi Catatan'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ['Penting', 'Sedang', 'Rendah']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedColor,
                  items: ['Blue', 'Red', 'Green', 'Yellow']
                      .map((color) => DropdownMenuItem(
                            value: color,
                            child: Text(color),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedColor = value!),
                  decoration: const InputDecoration(labelText: 'Warna'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final pickedTime = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedTime != null) {
                      setState(() => _reminderTime = pickedTime);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pilih Tanggal Pengingat'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearForm();
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => _addOrEditNote(index: index),
              child: Text(index == null ? 'Simpan' : 'Perbarui'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = 'Penting';
    _selectedColor = 'Blue';
    _reminderTime = null;
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColor(note['color']),
                        child: const Icon(Icons.note, color: Colors.white),
                      ),
                      title: Text(note['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note['content']),
                          const SizedBox(height: 4), // sedikit jarak antara konten dan tanggal
                          Text(
                            'Dibuat pada: ${_formatDate(note['createdAt'])}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showNoteDialog(index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showNoteDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Catatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Yellow':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  // Fungsi untuk memformat tanggal
  String _formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    final String formattedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    return formattedDate;
  }
}
