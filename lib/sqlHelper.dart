
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper{
  // static createNote(String text,String text2)
  ///create table with items notes and column name as title and note
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        note TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  /// Create Database
  static Future<sql.Database> myData() async {
    return sql.openDatabase(
        'myNotes.db',
        version: 1,
        onCreate: (sql.Database database, int version) async {
          await createTables(database);
        });
  }
  //add notes to the db
  static Future <int> createNote(String title,String note) async{
    final db = await SQLHelper.myData(); ///to open data base
    final data = {'title':title,'note':note};
    final id = await db.insert("notes", data,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
  /// Read all data from the table
  static Future <List<Map<String,dynamic>>> readNotes()  async{
    final db = await SQLHelper.myData();
    return db.query('notes',orderBy: 'id');

  }

  static Future <List<Map<String,dynamic>>> readSinglevalue(int id)  async{
    final db = await SQLHelper.myData();
    return db.query('notes',where: 'id = ?',whereArgs: [id],limit:1);

  }
  static Future<int>updateNote(int id,String titlenew,String notenew) async{
    final db = await SQLHelper.myData();
    final newdata ={
      'title' : titlenew,
      'note' : notenew,
      ///DateTime.now is build function for update time
      'createdAt' : DateTime.now().toString()
    };
    final result = await db.update('notes',newdata,where: "id = ?",whereArgs: [id]);
    return result;

  }

  static Future <void> deletenote(int id) async {
    final db = await SQLHelper.myData();
    try{
      await db.delete("notes", where: "id = ?",whereArgs: [id]);

    }catch(err){
      debugPrint("Something Went Wrong");
    }
  }
}