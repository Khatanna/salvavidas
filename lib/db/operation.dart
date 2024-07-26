import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:salvavidas/models/Contact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salvavidas/models/Button.dart';

class Operation {
  static Future<Database> openDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(join(dbPath, 'data.db'), version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
        '''
          CREATE TABLE contact (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            buttonColor TEXT
          )
          ''',
      );
    });
  }

  static Future<Contact> insertContact(Contact contact) async {
    final Database db = await openDB();
    contact.id = await db.insert('contact', contact.toMap());

    return contact;
  }

  static Future<List<Contact>> getContacts({Button? button}) async {
    final Database db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'contact',
      where: button == null
          ? null
          : button == Button.red
              ? 'buttonColor = ${Colors.red.value.toString()}'
              : button == Button.yellow
                  ? 'buttonColor = ${Colors.yellow.value.toString()}'
                  : button == Button.green
                      ? 'buttonColor = ${Colors.green.value.toString()}'
                      : 'buttonColor = ${Colors.blue.value.toString()}',
    );
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phone: maps[i]['phone'],
        buttonColor: Color(int.parse(maps[i]['buttonColor'])),
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
