import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import 'package:group_project/models/db_utils.dart';
import 'package:group_project/models/saved.dart';
import 'package:group_project/models/post.dart';

class SavedModel {
  //
  //  Insert a saved post
  //
  Future<int> _insertSaved(Database? db, SavedPost saved) async {
    db ??= await DBUtils.init(); //Init database if null.

    return await db!.insert(
        DBUtils.savedPostTable,
        saved.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //
  //  Update an already saved post
  //
  Future<int> _updateSaved(Database? db, SavedPost saved) async {
    db ??= await DBUtils.init(); //Init database if null.
    
    return await db!.update(
      DBUtils.savedPostTable,
      saved.toMap(),
      where: 'id = ?',
      whereArgs: [saved.id],
    );
  }

  //
  //  Remove a saved post by id
  //
  Future<int> _deleteSaved(Database? db, int id) async {
    db ??= await DBUtils.init(); //Init database if null.

    return await db!.delete(
      DBUtils.savedPostTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //
  //  Convert list of maps to a list of saved posts
  //
  List<SavedPost> _mapsToSaved(List<Map<String, Object?>> maps) {
    List<SavedPost> savedPosts = [];
    for (int i = 0; i < maps.length; i++){
      savedPosts.add(SavedPost.fromMap(maps[i]));
    }
    return savedPosts;
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

    return _mapsToSaved(maps);
  }

  //
  //  Returns only hidden posts
  //
  Future<List<SavedPost>> getAllHidden(Database? db) async {
    db ??= await DBUtils.init(); //Init database if null.

    final List<Map<String, Object?>> maps = await db!.query(
      DBUtils.savedPostTable,
      where: 'hidden = ?',
      whereArgs: [true],
    );
    
    return _mapsToSaved(maps);
  }

  //
  //  Check if a post is saved
  //
  Future<bool> isPostSaved(Database? db, String documentID) async {
    db ??= await DBUtils.init(); //Init database if null.

    //Get all saved posts with a matching reference (Should only be one).
    final List<Map<String, Object?>> maps = await db!.query(
      DBUtils.savedPostTable,
      where: 'documentID = ?',
      whereArgs: [documentID],
    );

    //Warning print for if there are multiple results (Just in case, to help debug)
    if (maps.length>1) {
      print("Warning: Multiple saved posts found with matching documentID!");
    }

    //Did we find a matching saved post?
    return maps.isNotEmpty;
  }

  //
  //  Check if a post is hidden
  //
  Future<bool> isPostHidden(Database? db, String documentID) async {
    db ??= await DBUtils.init(); //Init database if null.

    //Get all saved posts with a matching reference (Should only be one).
    final List<Map<String, Object?>> maps = await db!.query(
        DBUtils.savedPostTable,
        where: 'documentID = ?',
        whereArgs: [documentID],
    );

    //Warning print for if there are multiple results (Just in case, to help debug)
    if (maps.length>1) {
      print("Warning: Multiple saved posts found with matching documentID!");
    }

    //Loop through them and check if it's hidden (Should only ever iterate once)
    for (Map<String, Object?> map in maps) {
      SavedPost saved = SavedPost.fromMap(map);
      if (saved.hidden!) {
        return true;
      }
    }
    return false;
  }

  //
  //  Saves a post
  //
  Future<void> savePost(Database? db, Post post) async {
    db ??= await DBUtils.init(); //Init database if null.

    //Check to make sure it's only saved once
    if (!await isPostSaved(db, post.reference!.id)) {
      SavedPost saved = SavedPost(
        documentID: post.reference!.id,
        hidden: false,
      );
      _insertSaved(db, saved);
    }
  }

  //
  //  Unsaves and unhides a post
  //
  Future<void> unsavePost(Database? db, Post post) async {
    db ??= await DBUtils.init(); //Init database if null.
    if (post.reference==null) {
      db!.delete(DBUtils.savedPostTable, where: 'documentID = ?',
          whereArgs: [post.documentID!]);
    } else {
      db!.delete(DBUtils.savedPostTable, where: 'documentID = ?',
          whereArgs: [post.reference!.id]);
    }
  }

  //
  //  Hides a post
  //
  Future<void> hidePost(Database? db, Post post) async {
    db ??= await DBUtils.init(); //Init database if null.

    //Get all saved posts with a matching reference (Should only be one).
    final List<Map<String, Object?>> maps = await db!.query(
      DBUtils.savedPostTable,
      where: 'documentID = ?',
      whereArgs: [post.reference!.id],
    );

    //Warning print for if there are multiple results (Just in case, to help debug)
    if (maps.length>1) {
      print("Warning: Multiple saved posts found with matching documentID!");
    }

    if (maps.isEmpty) {
      SavedPost saved = SavedPost(
        documentID: post.reference!.id,
        hidden: true,
      );
      _insertSaved(db, saved);
    } else {
      for (var map in maps) {
        SavedPost saved = SavedPost.fromMap(map);
        saved.hidden = true;
        _updateSaved(db, saved);
      }
    }
  }

}