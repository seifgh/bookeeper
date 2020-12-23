import 'package:flutter/material.dart';

class NetworkErrorWidget extends StatelessWidget {
  final String title, description;
  Function refresh;
  NetworkErrorWidget(this.title, this.description, [this.refresh]);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    return Container(
        width: screenSize.width,
        child: Column(children: [
          const SizedBox(
            height: 64,
          ),
          Image(
            image: AssetImage('assets/images/network-error.png'),
            width: screenSize.width - 24,
          ),
          const SizedBox(
            height: 32,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline3.apply(
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline6.apply(
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          if (refresh != null)
            OutlineButton.icon(
                onPressed: refresh,
                textColor: theme.primaryColor,
                color: theme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(14),
                icon: Icon(Icons.refresh),
                label: Text("TRY AGAIN"))
        ]));
  }
}
