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
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Grocery List',
      theme: new ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: new OverviewScreen(title: 'Grocery List'),
    );
  }
}

class OverviewScreen extends StatefulWidget {
  OverviewScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OverviewScreenState createState() => new _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _counter = 0;
  DatabaseReference listsRef;
  DatabaseReference listItemsRef;

  void _incrementCounter() {
    _ensureLoggedIn().then(_connectToDatabase);
    setState(() {
      _counter++;
    });
  }

  void _connectToDatabase(FirebaseUser user) {
    setState(() {
      listsRef = FirebaseDatabase.instance.reference()
          .child('lists').child(user.uid);

//      listsRef.onChildAdded.listen((Event event) {
//        print(event.snapshot.value);
//      });
    });
  }

  @override
  void initState() {
    super.initState();
    listsRef =
        FirebaseDatabase.instance.reference().child('lists').child(
            'il3y6ivaP7dwp4NT2VldUhweTRx2');
  }

  void editList(String databaseKey) {
    print('edit list: $databaseKey');
  }

  @override
  Widget build(BuildContext context) {
    print('building state again');
    print(listsRef != null ? listsRef.path : 'No path yet');

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
          child: new FirebaseAnimatedList(
            query: listsRef,
            sort: (a, b) => b.key.compareTo(a.key),
            padding: new EdgeInsets.all(8.0),
            reverse: false,
            itemBuilder: (_, DataSnapshot snapshot,
                Animation<double> animation) {
              return new GroceryListItem(
                snapshot: snapshot,
                animation: animation,
                homePageState: this,
              );
            },
          ),
        ),
      ]),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class GroceryListItem extends StatelessWidget {
  GroceryListItem({this.snapshot, this.animation, this.homePageState});

  final DataSnapshot snapshot;
  final Animation animation;
  final _OverviewScreenState homePageState;

  void onEditPressed(String databaseKey) {
    homePageState.editList(databaseKey);
  }

  void onDeletePressed(String databaseKey) {
//    homePageState.editList(databaseKey);
  }

  @override
  Widget build(BuildContext context) {
    print('building a list entry');
    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
              child: new Row(
                  children: [
                    new Text(snapshot.value['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ])),
          new Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
              child: new Row(
                  children: [
                    new Text(snapshot.value['ownerMail']),
                  ])),
          new ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('EDIT'),
                  onPressed: () {
                    onEditPressed(snapshot.key);
                  },
                ),
                new FlatButton(
                  child: const Text('DELETE',
                      style: const TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    onDeletePressed(snapshot.key);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
