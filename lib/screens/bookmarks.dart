import 'package:bookeeper/data_providers/models.dart';
import 'package:bookeeper/data_providers/user.dart';
import 'package:bookeeper/data_providers/web_api.dart';
import 'package:bookeeper/widgets/network_error.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/empty_list.dart';
import '../widgets/bookmark.dart';

import '../data_providers/local_db.dart';

class BookmarksScreen extends StatefulWidget {
  BookmarksList list;
  Function updateListLength;
  BookmarksScreen(this.list, this.updateListLength, {Key key})
      : super(key: key);
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Bookmark> _bookmarks = [];
  bool _bookmarksFetchIsLoading = false,
      _bookmarksFetchHasServerError = false,
      _bookmarksFetchHasNetworkError = false;

  bool _bookmarksFetchedSuccessfuly() => !(_bookmarksFetchIsLoading ||
      _bookmarksFetchHasServerError ||
      _bookmarksFetchHasNetworkError);

  bool _actionsBlocked = false;

  final _newBookmarkTitleController = TextEditingController();
  final _newBookmarkContentController = TextEditingController();
  void initState() {
    _fetchBookmarks();
    super.initState();
  }

  @override
  void dispose() {
    _newBookmarkContentController.dispose();
    _newBookmarkTitleController.dispose();
    super.dispose();
  }

  final _scrollController = ScrollController();

  _runAsAction(Function action, {bool isAsync = true}) async {
    if (!_actionsBlocked) {
      _actionsBlocked = true;
      if (isAsync) {
        await action();

        _actionsBlocked = false;
      } else {
        action();
      }
    } else {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please wait until the end of the last action!",
            textAlign: TextAlign.center),
      ));
    }
  }

  _addNewBookmark(BuildContext context) {
    Navigator.pop(context);

    _runAsAction(() async {
      if (_newBookmarkTitleController.text.isNotEmpty) {
        final bookmark = Bookmark(_newBookmarkTitleController.text,
            _newBookmarkContentController.text);
        setState(() {
          _bookmarks.insert(0, bookmark);
          widget.updateListLength(widget.list.bookmarksLength + 1);
        });

        if (user.isAuthenticated()) {
          final res = await webApi.addBookmark(
              widget.list.id,
              _newBookmarkTitleController.text,
              _newBookmarkContentController.text);

          if (res.isSuccessful) {
            bookmark.id = res.body['_id'];
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              content: Text(
                  "Your ${bookmark.title} bookmark has been saved successfuly",
                  textAlign: TextAlign.center),
            ));
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                    res.hasNetworkError
                        ? "Some thing went wrong, please check your network!"
                        : "We have a technical problem, please try later!",
                    textAlign: TextAlign.center),
                action: SnackBarAction(
                  label: "ClOSE",
                  onPressed: () {
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                  },
                )));

            setState(() {
              _bookmarks.removeAt(0);
              widget.updateListLength(widget.list.bookmarksLength - 1);
            });
          }
        } else {
          await provider.insertBookmark(bookmark, widget.list.id);
        }

        _newBookmarkContentController.clear();
        _newBookmarkTitleController.clear();
        _scrollController.animateTo(
          0,
          curve: Curves.easeOut,
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  _removeBookmark(BuildContext context, int index) {
    Navigator.pop(context);

    _runAsAction(() {
      final bookmark = _bookmarks[index];

      setState(() {
        _bookmarks.removeAt(index);
        widget.updateListLength(widget.list.bookmarksLength - 1);
      });

      final timer = Timer(Duration(seconds: 3), () async {
        if (user.isAuthenticated()) {
          final res = await webApi.deleteBookmark(bookmark.id);
          if (res.isSuccessful) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              content: Text(
                  "Your ${bookmark.title} bookmark has been deleted successfuly",
                  textAlign: TextAlign.center),
            ));
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                    res.hasNetworkError
                        ? "Some thing went wrong, please check your network!"
                        : "We have a technical problem, please try later!",
                    textAlign: TextAlign.center),
                action: SnackBarAction(
                  label: "ClOSE",
                  onPressed: () {
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                  },
                )));

            setState(() {
              _bookmarks.insert(index, bookmark);
              widget.updateListLength(widget.list.bookmarksLength + 1);
            });
          }
        } else {
          await provider.deleteBookmark(bookmark.id);
        }
        _actionsBlocked = false;
      });

      _scaffoldKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 3),
          content: Text("${bookmark.title} bookmark removed"),
          action: SnackBarAction(
            label: "UNDO",
            onPressed: () {
              timer.cancel();
              setState(() {
                _bookmarks.insert(index, bookmark);
                widget.updateListLength(widget.list.bookmarksLength + 1);
                _actionsBlocked = false;
              });
            },
          )));
    }, isAsync: false);
  }

  _updateBookmark(
      BuildContext context, int index, String newTitle, String newContent) {
    Navigator.pop(context);

    _runAsAction(() async {
      final bookmark = _bookmarks[index],
          oldTitle = bookmark.title,
          oldContent = bookmark.content;
      setState(() {
        bookmark.title = newTitle;
        bookmark.content = newContent;
      });
      if (user.isAuthenticated()) {
        final res =
            await webApi.updateBookmark(bookmark.id, newTitle, newContent);
        if (res.isSuccessful) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            content: Text(
                "Your ${bookmark.title} bookmark has been updated successfuly",
                textAlign: TextAlign.center),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  res.hasNetworkError
                      ? "Some thing went wrong, please check your network!"
                      : "We have a technical problem, please try later!",
                  textAlign: TextAlign.center),
              action: SnackBarAction(
                label: "ClOSE",
                onPressed: () {},
              )));
          setState(() {
            bookmark.title = oldTitle;
            bookmark.content = oldContent;
          });
        }
      } else {
        await provider.updateBookmark(bookmark);
      }
    });
  }

  _showAddNewBookmarkDialogue(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(16))),
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Add a new bookmark',
                                  style: theme.textTheme.headline2
                                      .apply(color: theme.primaryColor)),
                              const SizedBox(
                                height: 24,
                              ),
                              TextField(
                                controller: _newBookmarkTitleController,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Title',
                                    hintText: 'Enter your new list title',
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        16.0, 20.0, 16.0, 20.0),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 0))),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextField(
                                controller: _newBookmarkContentController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Content',
                                    hintText: 'Enter your new list title',
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        16.0, 20.0, 16.0, 20.0),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 0))),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              RaisedButton(
                                onPressed: () => _addNewBookmark(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                color: theme.primaryColor,
                                textColor: theme.accentColor,
                                child: Text(
                                  'Add',
                                ),
                              ),
                            ],
                          )))));
        });
  }

  _fetchBookmarks() async {
    setState(() {
      _bookmarksFetchIsLoading = true;
    });
    if (user.isAuthenticated()) {
      final res = await webApi.getBookmarks(widget.list.id);
      setState(() {
        _bookmarksFetchHasServerError = res.hasServerError;
        _bookmarksFetchHasNetworkError = res.hasNetworkError;
        if (res.isSuccessful) {
          _bookmarks =
              List<Bookmark>.from(res.body.map((e) => Bookmark.fromWebApi(e)));
        }
        _bookmarksFetchIsLoading = false;
      });
    } else {
      _bookmarks = await provider.getBookmarks(widget.list.id);
      setState(() {
        _bookmarksFetchIsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Function _bookmarksWidget;

    if (user.isAuthenticated()) {
      _bookmarksWidget = () {
        if (_bookmarksFetchIsLoading)
          return ListView.separated(
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return BookmarkSkeltonWidget();
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12));
        if (_bookmarksFetchHasNetworkError)
          return NetworkErrorWidget(
              "Some thing went wrong, Please try later.",
              "Looks like we have a technical problem, you will see your bookmarks lists when you try later",
              _fetchBookmarks);

        if (_bookmarksFetchHasServerError)
          return NetworkErrorWidget(
            "Some thing went wrong, Please try later.",
            "Looks like we have a technical problem, you will see your bookmarks lists when you try later",
          );
        return ListView.separated(
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _bookmarks.length,
            itemBuilder: (BuildContext context, int index) {
              return BookmarkWidget(
                  _bookmarks[index],
                  () => _removeBookmark(context, index),
                  (String newTitle, String newContent) =>
                      _updateBookmark(context, index, newTitle, newContent),
                  key: Key(_bookmarks[index].id));
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 12));
      };
    } else {
      _bookmarksWidget = () {
        if (_bookmarksFetchIsLoading)
          return ListView.separated(
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return BookmarkSkeltonWidget();
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12));
        return ListView.separated(
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _bookmarks.length,
            itemBuilder: (BuildContext context, int index) {
              return BookmarkWidget(
                  _bookmarks[index],
                  () => _removeBookmark(context, index),
                  (String newTitle, String newContent) =>
                      _updateBookmark(context, index, newTitle, newContent),
                  key: Key(_bookmarks[index].id));
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 12));
      };
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.list.title,
              style: theme.textTheme.headline3.apply(color: Colors.white)),
          // actions: [DropdownButtonHideUnderline(child: )],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
            visible: _bookmarksFetchedSuccessfuly(),
            child: FloatingActionButton(
              backgroundColor: theme.primaryColor,
              tooltip: 'Add a bookmark',
              child: Icon(
                Icons.add,
                color: theme.accentColor,
              ),
              onPressed: () => _showAddNewBookmarkDialogue(context),
            )),
        body: ListView(
          controller: _scrollController,
          children: [
            Container(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.list.bookmarksLength > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.list.bookmarksLength} Bookmark${widget.list.bookmarksLength > 1 ? 's' : ''}',
                                style: theme.textTheme.headline2
                                    .apply(color: Colors.black),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Tap to manage your bookmark.',
                                style: theme.textTheme.headline6
                                    .apply(color: Colors.black),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              _bookmarksWidget(),
                            ],
                          )
                        : EmptyListWidget('No bookmarks yet!',
                            'once you add some bookmarks you will see them here.')))
          ],
        ));
  }
}
