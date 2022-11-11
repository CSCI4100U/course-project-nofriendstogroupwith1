import 'package:sqflite/sqflite.dart';

import 'package:group_project/models/db_utils.dart';
import 'package:group_project/models/saved.dart';

class SavedModel {
  //
  //  Insert a saved post
  //
  Future<void> insertSaved(Database? db, SavedPost saved) async {
    db ??= await DBUtils.init(); //Init database if null.

    await db!.insert(
        DBUtils.savedPostTable,
        saved.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //
  //  Update an already saved post
  //
  Future<void> updateSaved(Database? db, SavedPost saved) async {
    db ??= await DBUtils.init(); //Init database if null.
    
    await db!.update(
      DBUtils.savedPostTable,
      saved.toMap(),
      where: 'id = ?',
      whereArgs: [saved.id],
    );
  }

  //
  //  Remove a saved post
  //
  Future<void> deleteSaved(Database? db, int id) async {
    db ??= await DBUtils.init(); //Init database if null.

    await db!.delete(
      DBUtils.savedPostTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //
  //  Returns all saved posts (excludes hidden posts)
  //
  Future<List<SavedPost>> getAllSaved(Database? db) async {
    db ??= await DBUtils.init(); //Init database if null.

    //Populate a list of maps (Query for only visible posts here)
    final List<Map<String, Object?>> maps = await db!.query(
        DBUtils.savedPostTable,
        where: 'hidden = ?',
        whereArgs: [false],
    );

    return mapsToSaved(maps);
  }

  //
  //  Returns only hidden posts
  //
  Future<List<SavedPost>> getAllHidden(Database? db) async {
    db ??= await DBUtils.init(); //Init database if null.

    final List<Map<String, Object?>> maps = await db!.query(
      DBUtils.savedPostTable,
      where: 'hidden = ?',
      whereArgs: [false],
    );
    
    return mapsToSaved(maps);
  }

  //Convert list of maps to a list of saved posts
  List<SavedPost> mapsToSaved(List<Map<String, Object?>> maps) {
    List<SavedPost> savedPosts = [];
    for (int i = 0; i < maps.length; i++){
      savedPosts.add(SavedPost.fromMap(maps[i]));
    }
    return savedPosts;
  }
}