import 'package:bookeeper/data_providers/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import '../screens/bookmarks.dart';

class BookmarksListWidget extends StatefulWidget {
  final BookmarksList item;
  Function removeItem, updateItem;
  int index;
  BookmarksListWidget(this.item, this.index, this.removeItem, this.updateItem,
      {Key key})
      : super(key: key);
  _BookmarksListState createState() => _BookmarksListState();
}

class _BookmarksListState extends State<BookmarksListWidget> {
  final _updatedTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updatedTitleController.text = widget.item.title;
  }

  void _updateListLength(int newLen) {
    setState(() {
      widget.item.bookmarksLength = newLen;
    });
  }

  void _updateItem(BuildContext context) {
    if (_updatedTitleController.text.isNotEmpty) {
      Navigator.pop(context);
      widget.updateItem(widget.index, _updatedTitleController.text);
    }
  }

  void _showUpdateItemDialogue(BuildContext context) {
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
                              Text('Edit list',
                                  style: theme.textTheme.headline2
                                      .apply(color: theme.primaryColor)),
                              // Divider(
                              //   color: Colors.grey[400],
                              // ),
                              const SizedBox(
                                height: 24,
                              ),
                              TextField(
                                controller: _updatedTitleController,
                                onSubmitted: (_) => _updateItem(context),
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
                                onPressed: () => _updateItem(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                color: theme.primaryColor,
                                textColor: theme.accentColor,
                                child: Text(
                                  'Update',
                                ),
                              ),
                            ],
                          )))));
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SlideAction(
              decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(8))),
              child: Icon(
                Icons.edit_outlined,
                size: 32,
                color: Colors.white,
              ),
              closeOnTap: true,
              onTap: () => _showUpdateItemDialogue(context),
            ),
          )
        ],
        secondaryActions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SlideAction(
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(8))),
              child: Icon(
                Icons.delete_outline,
                size: 32,
                color: Colors.white,
              ),
              closeOnTap: true,
              onTap: () => widget.removeItem(widget.index),
            ),
          )
        ],
        child: FlatButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookmarksScreen(widget.item, _updateListLength)));
          },
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          highlightColor: Colors.grey[200],
          color: widget.index % 2 == 0 ? Colors.grey[100] : Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                widget.item.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
              const SizedBox(
                width: 8,
              ),
              Row(children: <Widget>[
                Container(
                  width: 1.5,
                  height: 52,
                  color: Colors.grey[300],
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(children: <Widget>[
                  Text(
                    widget.item.bookmarksLength.toString(),
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 24,
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    "Saved",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ])
              ])
            ],
          ),
        ));
  }
}

class BookmarksListSkeltonWidget extends StatelessWidget {
  int index;
  BookmarksListSkeltonWidget(this.index);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: () => null,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        highlightColor: Colors.grey[200],
        color: index % 2 == 0 ? Colors.grey[100] : Colors.transparent,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 96,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      width: 64,
                      height: 12,
                      color: Colors.grey[300],
                    ),
                  ]),
              Row(children: <Widget>[
                Container(
                  width: 2,
                  height: 52,
                  color: Colors.grey[300],
                ),
                const SizedBox(
                  width: 16,
                ),
                Container(
                  width: 36,
                  height: 36,
                  color: Colors.grey[300],
                ),
              ])
            ],
          ),
        ));
  }
}
