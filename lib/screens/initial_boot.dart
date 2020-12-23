import 'package:flutter/material.dart';

class InitialBootScreen extends StatelessWidget {
  Function refresh;
  InitialBootScreen({this.refresh});

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: theme.primaryColor,
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text('BooKeeper',
                  style: TextStyle(
                      fontSize: 64,
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 16,
              ),
              Text(
                refresh == null
                    ? 'Welcome to BooKeeper!'
                    : "No network connection",
                style:
                    theme.textTheme.headline3.apply(color: theme.accentColor),
              ),
              const SizedBox(
                height: 32,
              ),
              refresh == null
                  ? SizedBox(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(theme.accentColor),
                        // backgroundColor: theme.primaryColor,
                        strokeWidth: 3,
                      ),
                      height: 100,
                      width: 100,
                    )
                  : RaisedButton.icon(
                      color: theme.accentColor,
                      onPressed: refresh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(14),
                      icon: Icon(Icons.refresh),
                      label: Text("TRY AGAIN"))
            ])));
  }
}
