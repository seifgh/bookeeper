// shared names between models and db
const databaseName = "bookeeper.db",
    tableBookmarksList = "bookmarks_list",
    tableBookmark = "bookmark",
    columnId = "id",
    columnListId = "list_id",
    columnTitle = "title",
    columnContent = "content";

// data Models
class BookmarksList {
  String id, title;
  int bookmarksLength = 0;
  BookmarksList(this.title);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      columnTitle: title,
    };
    if (id != null) map[columnId] = id;
    return map;
  }

  BookmarksList.fromMap(Map<String, dynamic> map) {
    id = map[columnId].toString();
    title = map[columnTitle];
    bookmarksLength = map['bookmarks_length'];
  }

  BookmarksList.fromWebApi(Map<String, dynamic> map) {
    id = map['_id'].toString();
    title = map['title'];
    bookmarksLength = map['bookmarksLength'];
  }
}

class Bookmark {
  String id, title, content;
  Bookmark(this.title, this.content);

  Map<String, dynamic> toMap([String listId]) {
    Map<String, dynamic> map = {
      columnTitle: title,
      columnContent: content,
    };
    if (id != null) map[columnId] = id;
    if (listId != null) map[columnListId] = listId;
    return map;
  }

  Bookmark.fromMap(Map<String, dynamic> map) {
    id = map[columnId].toString();
    title = map[columnTitle];
    content = map[columnContent];
  }

  Bookmark.fromWebApi(Map<String, dynamic> map) {
    id = map['_id'].toString();
    title = map['title'];
    content = map['content'];
  }
}
