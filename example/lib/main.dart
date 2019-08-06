import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:firebase_ui/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FFULocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', 'FR'),
        const Locale('en', 'US'),
        const Locale('de', 'DE'),
        const Locale('pt', 'BR'),
        const Locale('es', 'MX'),
      ],
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<FirebaseUser> _listener;

  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return SignInScreen(
        title: "Demo",
        header: SizedBox(
          height: MediaQuery.of(context).size.height / 5,
        ),
        showBar: true,
        horizontalPadding: 24.0,
        bottomPadding: 8.0,
        avoidBottomInset: true,
        color: Color(0xFF363636),
        providers: [ProvidersTypes.google, ProvidersTypes.facebook, ProvidersTypes.email],
      );
    } else {
      return HomeScreen(user: _currentUser);
    }
  }

  void _checkCurrentUser() async {
    _currentUser = await _auth.currentUser();
    _currentUser?.getIdToken(refresh: true);

    _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _currentUser = user;
      });
    });
  }
}

class HomeScreen extends StatelessWidget {
  final FirebaseUser user;

  HomeScreen({this.user});

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue"),
        elevation: 4.0,
      ),
      body: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: Colors.amber),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Welcome,"),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(user.displayName ?? user.email),
              SizedBox(
                height: 32.0,
              ),
              RaisedButton(child: new Text("DECONNEXION"), onPressed: _logout)
            ],
          )));

  void _logout() {
    signOutProviders();
  }
}
