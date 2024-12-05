import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  ///Singleton
  DbHelper._();

  static final DbHelper getInstance = DbHelper._();
  //table note

  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "sl_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "description";

  Database? myDB;

  ///DB open (path -> if exist then open else create db)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;

    // if (myDB != null) {
    //   return myDB;
    // } else {
    //   await openDB();
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(dbPath, onCreate: (db, version) {
      ///create all your tables here
      ///
      db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");
    }, version: 1);
  }

  /// All queries
  Future<bool> addNote({required String title, required String desc}) async {
    var db = await getDB();
    int rowsEfected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc,
    });
    return rowsEfected > 0;
  }

//Reading All data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

  ///update date
  Future<bool> updateNote(
      {required String title, required String desc, required int sno}) async {
    var db = await getDB();

    int rowsEffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: title,
          COLUMN_NOTE_DESC: desc,
        },
        where: "$COLUMN_NOTE_SNO = $sno");

    return rowsEffected > 0;
  }

  ///delete data
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$sno']);
    return rowsEffected > 0;
  }
}
