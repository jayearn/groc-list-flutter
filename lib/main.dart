import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
final googleSignIn = new GoogleSignIn();

Future<FirebaseUser> _ensureLoggedIn() async {
  FirebaseUser firebaseUser = await auth.currentUser();
  if (firebaseUser != null) return firebaseUser;

  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null)
    user = await googleSignIn.signInSilently();
  if (user == null) {
    user = await googleSignIn.signIn();
    analytics.logLogin();
  }

  if (await auth.currentUser() == null && googleSignIn.currentUser != null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    return auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  } else {
    return null;
  }
}

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Grocery List',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.cyan,
      ),
      home: new MyHomePage(title: 'Grocery List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  DatabaseReference listsRef;

  void _incrementCounter() {
    _ensureLoggedIn().then(_connectToDatabase);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _connectToDatabase(FirebaseUser user) {
    setState(() {
      listsRef =
          FirebaseDatabase.instance.reference().child('lists').child(user.uid);

      listsRef.onChildAdded.listen((Event event) {
        print(event.snapshot.value);
      });
    });
  }

  @override
  void initState() {
    listsRef =
        FirebaseDatabase.instance.reference().child('lists').child('abc');
  }

  @override
  Widget build(BuildContext context) {
    print('building state again');
    print(listsRef != null ? listsRef.path : 'No path yet');
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
          child: new FirebaseAnimatedList(
            query: listsRef,
            sort: (a, b) => b.key.compareTo(a.key),
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, DataSnapshot snapshot,
                Animation<double> animation) {
              return new GroceryListItem(
                  snapshot: snapshot,
                  animation: animation
              );
            },
          ),
        ),
      ]),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class GroceryListItem extends StatelessWidget {
  GroceryListItem({this.snapshot, this.animation});

  final DataSnapshot snapshot;
  final Animation animation;

  @override
  Widget build(BuildContext context) {
    print('building a list entry');
    return new Text(snapshot.value['name']);
  }
}
