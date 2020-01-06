import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test1/views/db/essay-mode.dart';

import './essay-mode.dart';

final String dbName = 'essay_database.db';
final String tatleName = 'essay';

Future<void> insert(Essay essagy, Database db) async {
  db.insert(
    tatleName,
    essagy.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<List<Essay>> selectAll(Database db) async {
  //  (查询数据表，获取所有的数据)
  final List<Map<String, dynamic>> maps = await db.query(tatleName);

  print('$tatleName数据库数据数量：${maps.length}');
  return List.generate(maps.length, (i) {
    return Essay(
      id: maps[i]['id'],
      text: maps[i]['text'],
      directory: maps[i]['directory'],
      time: maps[i]['time'],
    );
  });
}

Future<Database> createDB() async {
  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    // 设置数据库的路径。注意：使用 `path` 包中的 `join` 方法是
    // 确保在多平台上路径都正确的最佳实践。
    join(await getDatabasesPath(), dbName),
    // 当数据库第一次被创建的时候，创建一个数据表，用以存储数据。(只运行一次，卸载软件后才重新启动)
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE IF NOT EXISTS $tatleName(id INTEGER PRIMARY KEY, text TEXT, directory INTEGER, time TEXT)",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    // 设置版本。它将执行 onCreate 方法，同时提供数据库升级和降级的路径。
    version: 1,
  );
}
