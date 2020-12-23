import 'package:bookeeper/data_providers/models.dart';
import 'package:bookeeper/data_providers/user.dart';
import 'package:bookeeper/data_providers/web_api.dart';
import 'package:bookeeper/screens/sign_in.dart';
import 'package:bookeeper/screens/sign_up.dart';
import 'package:bookeeper/widgets/network_error.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import '../widgets/bookmarks_list.dart';
import '../widgets/empty_list.dart';
import '../data_providers/local_db.dart' show provider, BookmarksList;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<BookmarksList> _bookmarksLists = [];

  // used to fetch data only one time from db or api
  bool _bookmarksListsFetchIsLoading = false,
      _bookmarksListsFetchHasServerError = false,
      _bookmarksListsFetchHasNetworkError = false;
  bool _bookmarksListsFetchedSuccessfuly() => !(_bookmarksListsFetchIsLoading ||
      _bookmarksListsFetchHasServerError ||
      _bookmarksListsFetchHasNetworkError);

  // used for stopping multiple action( delete, insert, ...) in the same time
  bool _actionsBlocked = false;
  final _newBookmarksListController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    _fetchBookmarksLists();
    super.initState();
  }

  @override
  void dispose() {
    _newBookmarksListController.dispose();
    super.dispose();
  }

  // prevent running multiple tasks
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

  _addNewList(BuildContext context) {
    _runAsAction(() async {
      if (_newBookmarksListController.text.isNotEmpty) {
        Navigator.of(context).pop();
        final bookmarksList = BookmarksList(_newBookmarksListController.text);
        setState(() {
          _bookmarksLists.insert(0, bookmarksList);
        });
        if (user.isAuthenticated()) {
          final res =
              await webApi.addBookmarksList(_newBookmarksListController.text);
          if (res.isSuccessful) {
            bookmarksList.id = res.body['_id'];
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              content: Text(
                  "Your ${bookmarksList.title} list has been saved successfuly",
                  textAlign: TextAlign.center),
            ));
          } else {
            setState(() {
              _bookmarksLists.removeAt(0);
            });
            _scaffoldKey.currentState.showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  res.hasNetworkError
                      ? "Some thing went wrong, please check your network!"
                      : "We have a technical problem, please try later!",
                ),
                action: SnackBarAction(
                  label: "ClOSE",
                  onPressed: () {
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                  },
                )));
          }
        } else {
          await provider.insertBookmarksList(bookmarksList);
        }

        _newBookmarksListController.clear();
        // scroll To top
        _scrollController.animateTo(
          0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 2000),
        );
      }
    });
  }

  _removeListItem(int index) {
    _runAsAction(() {
      final bookmarksList = _bookmarksLists[index];
      setState(() {
        _bookmarksLists.removeAt(index);
      });

      final timer = Timer(Duration(seconds: 3), () async {
        if (user.isAuthenticated()) {
          final res = await webApi.deleteBookmarksList(bookmarksList.id);

          if (res.isSuccessful) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              content: Text(
                  "Your ${bookmarksList.title} list has been deleted successfuly",
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
              _bookmarksLists.insert(index, bookmarksList);
            });
          }
        } else {
          await provider.deleteBookmarksList(bookmarksList.id);
        }
        _actionsBlocked = false;
      });

      _scaffoldKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 3),
          content: Text("${bookmarksList.title} list removed"),
          action: SnackBarAction(
            label: "UNDO",
            onPressed: () {
              timer.cancel();
              setState(() {
                _bookmarksLists.insert(index, bookmarksList);
              });
              _actionsBlocked = false;
            },
          )));
    }, isAsync: false);
  }

  _updateListItem(int index, String newTitle) {
    _runAsAction(() async {
      final bookmarksList = _bookmarksLists[index],
          oldTitle = bookmarksList.title;

      setState(() {
        bookmarksList.title = newTitle;
      });
      if (user.isAuthenticated()) {
        final res =
            await webApi.updateBookmarksList(bookmarksList.id, newTitle);
        if (res.isSuccessful) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            content: Text(
                "Your ${bookmarksList.title} list has been updated successfuly",
                textAlign: TextAlign.center),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                res.hasNetworkError
                    ? "Some thing went wrong, please check your network!"
                    : "We have a technical problem, please try later!",
              ),
              action: SnackBarAction(
                label: "ClOSE",
                onPressed: () {},
              )));
          setState(() {
            bookmarksList.title = oldTitle;
          });
        }
      } else {
        await provider.updateBookmarksList(bookmarksList);
      }
    });
  }

  _showAddBookmarksListDialogue(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                  height: 250,
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
                              Text('Add a new list',
                                  style: theme.textTheme.headline2
                                      .apply(color: theme.primaryColor)),
                              const SizedBox(
                                height: 24,
                              ),
                              TextField(
                                controller: _newBookmarksListController,
                                onSubmitted: (_) => _addNewList(context),
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'List title',
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
                                onPressed: () => _addNewList(context),
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

  _fetchBookmarksLists() async {
    setState(() {
      _bookmarksListsFetchIsLoading = true;
    });
    if (user.isAuthenticated()) {
      final res = await webApi.getBookmarksLists();
      setState(() {
        _bookmarksListsFetchHasServerError = res.hasServerError;
        _bookmarksListsFetchHasNetworkError = res.hasNetworkError;
        if (res.isSuccessful) {
          _bookmarksLists = List<BookmarksList>.from(
              res.body.map((e) => BookmarksList.fromWebApi(e)));
        }
        _bookmarksListsFetchIsLoading = false;
      });
    } else {
      _bookmarksLists = await provider.getBookmarksLists();

      setState(() {
        _bookmarksListsFetchIsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var profileImage;
    String fullName, email;
    ListTile drawerLogout;

    Function _bookmarksListsWidget;

    if (user.isAuthenticated()) {
      profileImage = user.data['imageUrl'] != null
          ? NetworkImage(user.data['imageUrl'])
          : AssetImage("assets/images/user.png");
      fullName = user.data['fullName'];
      email = user.data['email'];
      drawerLogout = ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout'),
        onTap: () async {
          user.update(null);
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => SignInScreen()));
        },
      );
      _bookmarksListsWidget = () {
        if (_bookmarksListsFetchIsLoading)
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY LISTS',
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListView.separated(
                    scrollDirection: Axis.vertical,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return BookmarksListSkeltonWidget(index);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8))
              ]);
        if (_bookmarksListsFetchHasNetworkError)
          return NetworkErrorWidget(
              "It looks as though you are offline.",
              "You will see your bookmarks lists when you are back online",
              _fetchBookmarksLists);
        if (_bookmarksListsFetchHasServerError)
          return NetworkErrorWidget(
            "Some thing went wrong, Please try later.",
            "Looks like we have a technical problem, you will see your bookmarks lists when you try later",
          );
        if (_bookmarksLists.isEmpty)
          return EmptyListWidget('No bookmarks lists yet!',
              'Once you add some lists you will see them here.');
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'MY LISTS',
            style: TextStyle(
                color: Colors.grey[900],
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Tap to open, swipe left to delete, and swipe right to rename.',
            style: theme.textTheme.headline6.apply(color: Colors.black),
          ),
          const SizedBox(
            height: 12,
          ),
          ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: _bookmarksLists.length,
              itemBuilder: (BuildContext context, int index) {
                return BookmarksListWidget(
                  _bookmarksLists[index],
                  index,
                  _removeListItem,
                  _updateListItem,
                  key: Key(_bookmarksLists[index].id),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 8))
        ]);
      };
    } else {
      profileImage = AssetImage("assets/images/user.png");
      fullName = "Guest";
      email = "";
      drawerLogout = ListTile(
        leading: Icon(Icons.account_box_outlined),
        title: Text('Sign up'),
        onTap: () async {
          user.update(null);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => SignUpScreen()));
        },
      );
      _bookmarksListsWidget = () {
        if (_bookmarksListsFetchIsLoading)
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY LISTS',
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListView.separated(
                    scrollDirection: Axis.vertical,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return BookmarksListSkeltonWidget(index);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8))
              ]);
        else if (_bookmarksLists.isEmpty)
          return EmptyListWidget('No bookmarks lists yet!',
              'Once you add some lists you will see them here.');
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'MY LISTS',
            style: TextStyle(
                color: Colors.grey[900],
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Tap to open, swipe left to delete, and swipe right to rename.',
            style: theme.textTheme.headline6.apply(color: Colors.black),
          ),
          const SizedBox(
            height: 12,
          ),
          ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: _bookmarksLists.length,
              itemBuilder: (BuildContext context, int index) {
                return BookmarksListWidget(
                  _bookmarksLists[index],
                  index,
                  _removeListItem,
                  _updateListItem,
                  key: Key(_bookmarksLists[index].id),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 8))
        ]);
      };
    }

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: Text('BooKeeper',
              style: theme.textTheme.headline2.apply(color: Colors.white)),
          actions: <Widget>[
            CircleAvatar(
              backgroundImage: profileImage,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 280.0,
                child: DrawerHeader(
                  // decoration: BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          radius: 62,
                          backgroundImage: profileImage,
                          backgroundColor: Colors.grey[200]),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        fullName,
                        style: theme.textTheme.headline4.apply(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        email,
                        style: theme.textTheme.headline6
                            .apply(color: Colors.black),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.mail_outline),
                title: Text('Contact'),
                onTap: () async {
                  final contactUrl = "https://seifgh.github.io/contact";
                  if (await canLaunch(contactUrl)) {
                    await launch(contactUrl);
                  }
                },
              ),
              drawerLogout,
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
            visible: _bookmarksListsFetchedSuccessfuly(),
            child: FloatingActionButton(
              backgroundColor: theme.primaryColor,
              tooltip: 'Add a bookmark',
              child: Icon(
                Icons.add,
                color: theme.accentColor,
              ),
              onPressed: () => _showAddBookmarksListDialogue(context),
            )),
        body: RefreshIndicator(
          color: theme.accentColor,
          backgroundColor: theme.primaryColor,
          onRefresh: () async {
            if (!_actionsBlocked) _fetchBookmarksLists();
          },
          child: Stack(
            children: [
              SizedBox.expand(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Hi $fullName,',
                          style: theme.textTheme.headline2
                              .apply(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Organize your bookmarks and save your links, numbers, ressources, mails, etc.',
                          style: theme.textTheme.headline6
                              .apply(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              DraggableScrollableSheet(
                  initialChildSize: 0.85,
                  minChildSize: 0.85,
                  maxChildSize: 0.98,
                  builder: (_, scrollController) => Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24))),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _bookmarksListsWidget()))))
            ],
          ),
        ));
  }
}
