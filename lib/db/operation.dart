import 'package:path/path.dart';
import 'package:salvavidas/models/Contact.dart';
import 'package:sqflite/sqflite.dart';

class Operation {
  static Future<Database> openDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(join(dbPath, 'contacts.db'), version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE contact (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT
          )
          ''');
    });
  }

  static Future<Contact> insertContact(Contact contact) async {
    final Database db = await openDB();
    contact.id = await db.insert('contact', contact.toMap());

    return contact;
  }

  static Future<List<Contact>> getContacts() async {
    final Database db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('contact');
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phone: maps[i]['phone'],
      );
    });
  }

  static Future<void> updateContact(Contact contact) async {
    final Database db = await openDB();
    await db.update('contact', contact.toMap(),
        where: 'id = ?', whereArgs: [contact.id]);
  }

  static Future<void> deleteContact(int id) async {
    final Database db = await openDB();
    await db.delete('contact', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllContacts() async {
    final Database db = await openDB();
    await db.delete('contact');
  }

  static Future<int> countContacts() async {
    final Database db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query('contact');
    return maps.length;
  }
}
