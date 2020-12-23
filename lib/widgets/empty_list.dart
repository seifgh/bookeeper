import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget {
  final String title, description;
  EmptyListWidget(this.title, this.description);
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
            image: AssetImage('assets/images/empty.png'),
            width: screenSize.width - 24,
          ),
          const SizedBox(
            height: 32,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline3.apply(color: Colors.black),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline6.apply(color: Colors.black),
          ),
        ]));
  }
}
