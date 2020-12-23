import 'package:bookeeper/data_providers/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class BookmarkWidget extends StatelessWidget {
  final Bookmark item;
  Function removeItem, updateItem;
  BookmarkWidget(this.item, this.removeItem, this.updateItem, {Key key})
      : super(key: key);

  final _updatedTitleController = TextEditingController();
  final _updatedContentController = TextEditingController();

  String formatedContent() {
    final content = item.content;
    if (content.isNotEmpty) {
      return content.length > 255 ? "${content.substring(0, 255)}..." : content;
    }
    return "Empty content!";
  }

  void _copyContent(BuildContext context) {
    Navigator.pop(context);
    if (item.content.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: item.content));
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Content copied", textAlign: TextAlign.center)));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Content is empty!", textAlign: TextAlign.center)));
    }
  }

  void _updateItem() {
    if (_updatedTitleController.text.isNotEmpty) {
      updateItem(_updatedTitleController.text, _updatedContentController.text);
    }
  }

  void _editItem(BuildContext context) {
    Navigator.pop(context);
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
                              Text('Edit bookmark',
                                  style: theme.textTheme.headline2
                                      .apply(color: theme.primaryColor)),
                              const SizedBox(
                                height: 24,
                              ),
                              TextField(
                                controller: _updatedTitleController,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Title',
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
                                controller: _updatedContentController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Content',
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
                                onPressed: () => _updateItem(),
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

  Widget build(BuildContext context) {
    _updatedTitleController.text = item.title;
    _updatedContentController.text = item.content;
    return FlatButton(
        onPressed: () {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
              ),
              context: context,
              builder: (_) {
                return Wrap(children: [
                  SizedBox(
                    height: 6,
                    width: 1,
                  ),
                  Center(
                    child: Container(
                      height: 6,
                      width: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            item.title,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SelectableText(
                            item.content.isNotEmpty
                                ? item.content
                                : "This bookmark has no content!",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        ],
                      )),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.copy_rounded),
                    title: Text('Copy content'),
                    onTap: () => _copyContent(context),
                  ),
                  ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      onTap: () => _editItem(context)),
                  ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                    onTap: removeItem,
                  ),
                ]);
              });
        },
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        highlightColor: Colors.grey[200],
        color: Colors.grey[100],
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                formatedContent(),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
              )
            ],
          ),
        ));
  }
}

class BookmarkSkeltonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: null,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        highlightColor: Colors.grey[200],
        color: Colors.grey[100],
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 24,
                  color: Colors.grey[300],
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  width: double.infinity,
                  height: 8,
                  color: Colors.grey[300],
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  width: double.infinity,
                  height: 8,
                  color: Colors.grey[300],
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  width: 220,
                  height: 8,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ));
  }
}
