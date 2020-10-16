import 'package:flutter/material.dart';
import 'package:editable/editable.dart';
import 'package:sqflite/sqflite.dart';

class _EditableHomeState extends State<EditableHome> {
  DataProvider data = DataProvider();

  List placeholderRows = [
    {
      "name": 'Dash',
      "type": 'Stratus',
      "lastSeen": '2020-10-15',
    },
    {
      "name": 'Fitz',
      "type": 'Cirrus',
      "lastSeen": '2020-10-15',
    },
  ];

  List columns = [
    {"title": 'Name', 'index': 1, 'key': 'name'},
    {"title": 'Type', 'index': 2, 'key': 'type'},
    {"title": 'Last Seen', 'index': 3, 'key': 'lastSeen'},
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cloud>>(
      future: data.getAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        //List rows = snapshot.data.map((e) => e.toMap()).toList();
        List rows = placeholderRows;

        return Editable(
          columns: columns,
          rows: rows,
          columnRatio: .28,
          showCreateButton: true,
          createButtonColor: Colors.blue,
          showSaveIcon: true,
          onRowSaved: (row) {
            // TODO
          },
        );
      },
    );
  }
}

class Spreadsheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditableHome(),
      appBar: AppBar(
        title: Text("Cloudy Recorder"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class EditableHome extends StatefulWidget {
  @override
  _EditableHomeState createState() => _EditableHomeState();
}

class Cloud {
  int id;
  String name;
  String type;
  String lastSeen;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'type': type,
      'lastSeen': lastSeen,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Cloud();

  Cloud.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    name = map['name'];
    type = map['type'];
    lastSeen = map['lastSeen'];
  }
}

class DataProvider {
  Database db;

  final tableName = 'Clouds';

  Future<void> open() async {
    db = await openDatabase('clouds.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''CREATE TABLE $tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  type TEXT,
  lastSeen TEXT
)
''');
    });
  }

  Future<List<Cloud>> getAll() async {
    if (db == null) {
      await open();
    }

    List<Map> maps =
        await db.query(tableName, columns: ['id', 'name', 'type', 'lastSeen']);

    List<Cloud> records = maps.map((e) => Cloud.fromMap(e)).toList();
    return records;
  }

  Future<Cloud> insert(Cloud cloud) async {
    if (db == null) {
      await open();
    }

    cloud.id = await db.insert(tableName, cloud.toMap());
    return cloud;
  }

  Future<void> close() async {
    await db?.close();
  }
}
