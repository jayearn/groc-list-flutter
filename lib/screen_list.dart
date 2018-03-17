import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groc_list_flutter/util.dart';

class ListScreen extends StatefulWidget {
  ListScreen({Key key, this.appState, this.title}) : super(key: key);

  final AppState appState;
  final String title;
  DatabaseReference listRef;

  @override
  _ListScreenState createState() {
    listRef = FirebaseDatabase.instance
        .reference()
        .child('listItems')
        .child(appState.user.uid)
        .child(appState.selectedListKey);
    return new _ListScreenState();
  }
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
          child: new FirebaseAnimatedList(
            query: widget.listRef,
            sort: (a, b) => b.key.compareTo(a.key),
            padding: new EdgeInsets.all(8.0),
            reverse: false,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new ListEntry(
                snapshot: snapshot,
                animation: animation,
                listScreenState: this,
              );
            },
          ),
        ),
      ]),
    );
  }
}

class ListEntry extends StatelessWidget {
  ListEntry({this.snapshot, this.animation, this.listScreenState});

  final DataSnapshot snapshot;
  final Animation animation;
  final _ListScreenState listScreenState;

  void onEditPressed(String databaseKey) {
//    listScreenState.editList(databaseKey);
  }

  void onDeletePressed(String databaseKey) {
//    homePageState.editList(databaseKey);
  }

  void onDragStart(DragStartDetails details) {
    print('onDragStart');
    print(details.toString());
  }

  void onDragStop(DragEndDetails details) {
    print('onDragStop');
    print(details.toString());
  }

  @override
  Widget build(BuildContext context) {
    print('building a list entry');

    return new ListTile(
      leading: new GestureDetector(
        child: new Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Icon(Icons.drag_handle, color: Colors.black54)),
        onVerticalDragStart: onDragStart,
        onVerticalDragEnd: onDragStop,
      ),
      title: new Text(snapshot.value['name']),
    );
  }
}
