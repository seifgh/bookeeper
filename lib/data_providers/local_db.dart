import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

// handle guest user db operations
class DataBaseProvider {
  Database db;
  Future open() async {
    db = await openDatabase(join(await getDatabasesPath(), databaseName),
        version: 1, onCreate: (Database db, int v) async {
      await db.execute('''
          CREATE TABLE $tableBookmarksList(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL
          );
          ''');
      await db.execute('''
        CREATE TABLE $tableBookmark(
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTitle TEXT NOT NULL,
          $columnContent TEXT,
          $columnListId INTEGER,
          FOREIGN KEY ($columnListId) 
            REFERENCES contacts ($columnId) 
              ON DELETE CASCADE 
              ON UPDATE NO ACTION
        );
        ''');
      // testing data
      // await db.execute('''INSERT INTO $tableBookmarksList ( $columnTitle )
      //     VALUES
      //     ('Links'),
      //     ('Notes'),
      //     ('Articles'),
      //     ('Movies')''');
    });
  }

  Future close() async {
    await db.close();
  }

  // Bookmarks lists

  Future<BookmarksList> insertBookmarksList(BookmarksList bookmarksList) async {
    await open();
    bookmarksList.id =
        (await db.insert(tableBookmarksList, bookmarksList.toMap())).toString();
    await close();
    return bookmarksList;
  }

  Future<List<BookmarksList>> getBookmarksLists() async {
    await open();
    List<Map<String, dynamic>> data = await db.rawQuery('''
    SELECT $columnId, $columnTitle, ( 
      SELECT COUNT(*) FROM $tableBookmark WHERE ($tableBookmark.$columnListId = $tableBookmarksList.$columnId)
     ) as bookmarks_length
     FROM $tableBookmarksList
     ORDER BY $columnId DESC;
    ''');
    await close();
    return data.map((e) => BookmarksList.fromMap(e)).toList();
  }

  Future deleteBookmarksList(String id) async {
    await open();
    await db
        .delete(tableBookmarksList, where: '$columnId = ?', whereArgs: [id]);
    await close();
  }

  Future updateBookmarksList(BookmarksList bookmarksList) async {
    await open();
    await db.update(tableBookmarksList, bookmarksList.toMap(),
        where: '$columnId = ?', whereArgs: [bookmarksList.id]);
    await close();
  }

  // Bookmarks

  Future<List<Bookmark>> getBookmarks(String listId) async {
    await open();
    List<Map<String, dynamic>> data = await db.query(
      tableBookmark,
      columns: [columnId, columnTitle, columnContent],
      where: '$columnListId = ?',
      whereArgs: [listId],
      orderBy: '$columnId DESC',
    );
    await close();
    return data.map((e) => Bookmark.fromMap(e)).toList();
  }

  Future<Bookmark> insertBookmark(Bookmark bookmark, String listId) async {
    await open();
    bookmark.id =
        (await db.insert(tableBookmark, bookmark.toMap(listId))).toString();
    await close();
    return bookmark;
  }

  Future deleteBookmark(String id) async {
    await open();
    await db.delete(tableBookmark, where: '$columnId = ?', whereArgs: [id]);
    await close();
  }

  Future updateBookmark(Bookmark bookmark) async {
    await open();
    await db.update(tableBookmark, bookmark.toMap(),
        where: '$columnId = ?', whereArgs: [bookmark.id]);
    await close();
  }
}

final provider = DataBaseProvider();
