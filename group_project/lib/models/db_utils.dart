import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils {
  static const String savedPostTable = "saved";

  static Future init() async {
    return openDatabase(
      path.join(await getDatabasesPath(), "group_project_nofriends.db"),
      onCreate: (db, version) {
        db.execute('CREATE TABLE $savedPostTable(id INTEGER PRIMARY KEY, documentID STRING, hidden BOOL)');
      },
      version: 1,
    );
  }
}