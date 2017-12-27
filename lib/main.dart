import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groc_list_flutter/firebase.dart';
import 'package:groc_list_flutter/screen_list.dart';
import 'package:groc_list_flutter/util.dart';

void main() {
  runApp(new GroceryListApp());
}

AppState _appState;

class GroceryListApp extends StatefulWidget {
  @override
  State createState() {
    return new GroceryListAppState();
  }
}

class GroceryListAppState extends State<GroceryListApp> {

  GroceryListAppState() {
    _appState = new AppState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Grocery List',
      theme: new ThemeData(
          primarySwatch: Colors.cyan,
          splashColor: Colors.white,
          scaffoldBackgroundColor: new Color.fromARGB(0xFF, 0xEB, 0xF0, 0xF2)
      ),
      routes: {
        '/': (BuildContext context) =>
        new OverviewScreen(title: 'Grocery List'),
        '/list': (BuildContext context) =>
        new ListScreen(appState: _appState, title: 'Bla',),
      },
    );
  }
}

//class LoginScreen extends StatefulWidget {
//  LoginScreen({Key key, this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  State createState() => new _LoginScreenState();
//}
//
//class _LoginScreenState extends State<LoginScreen> {
//
//  _LoginScreenState() {
//    _login();
//  }
//
//  _login() async {
//    FirebaseUser user = await ensureLoggedIn();
//    print('user: ' + user.toString());
//    setState(() {
//      if (user != null) {
//        _appState.user = user;
//        Navigator.of(context).pushNamed('/');
//      }
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Center(
//      child: new Text('Hi!'),
//    );
//  }
//}

class OverviewScreen extends StatefulWidget {
  OverviewScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OverviewScreenState createState() => new _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {

  DatabaseReference listsRef;

  _OverviewScreenState() {
    _login();
  }

  _login() async {
    FirebaseUser user = await ensureLoggedIn();
    print('user: ' + user.toString());
    setState(() {
      if (user != null) {
        _appState.user = user;
        _connectToDatabase(_appState.user);
      }
    });
  }

  void _incrementCounter() {
    ensureLoggedIn().then(_connectToDatabase);
    setState(() {
      bool bla = true;
    });
  }

  void _connectToDatabase(FirebaseUser user) {
    setState(() {
      print('setState and set listsRef');
      listsRef = FirebaseDatabase.instance.reference()
          .child('lists').child(user.uid);
    });
  }

  void editList(String databaseKey) {
    print('edit list: $databaseKey');
    _appState.selectedListKey = databaseKey;
    Navigator.of(context).pushNamed('/list');
  }

  @override
  void initState() {
    super.initState();
    listsRef = null;
  }

  @override
  Widget build(BuildContext context) {
    print('building state again');
    print(listsRef != null ? listsRef.path : 'No path yet');

    if (listsRef == null) {
      return new Text('Logging in..');
    } else
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
                  child: const Text('DELETE',
                      style: const TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    onDeletePressed(snapshot.key);
                  },
                ),
                new FlatButton(
                  child: const Text('EDIT'),
                  onPressed: () {
                    onEditPressed(snapshot.key);
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
