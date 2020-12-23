import 'package:bookeeper/data_providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'screens/sign_in.dart';
import './screens/home.dart';
import 'screens/initial_boot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      theme: ThemeData(
          primaryColor: Colors.indigoAccent,
          buttonColor: Colors.indigoAccent,
          disabledColor: Colors.indigoAccent[300],
          indicatorColor: Colors.white,
          accentColor: Colors.white,
          fontFamily: 'RobotoCondensed',
          textTheme: TextTheme(
            headline1: TextStyle(
              fontSize: 46.0,
              fontWeight: FontWeight.bold,
            ),
            headline2: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            headline3: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            headline4: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
            ),
            headline6: TextStyle(
              fontSize: 14.0,
            ),
            button: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            bodyText2: TextStyle(
              fontSize: 14.0,
            ),
          )
          // visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
      home: FutureBuilder<User>(
        future: Future<User>.sync(() => user.initialize()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (user.type == null) return SignInScreen();
            if (user.isGuest()) return HomeScreen();
            // auth user
            if (user.initUserApiResponse.isSuccessful) {
              return HomeScreen();
            }
            if (user.initUserApiResponse.hasNetworkError ||
                user.initUserApiResponse.hasServerError) {
              return InitialBootScreen(refresh: () => setState(() {}));
            }
            return SignInScreen();
          }
          return InitialBootScreen();
        },
      ),
    );
  }
}
