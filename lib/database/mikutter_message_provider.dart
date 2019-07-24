import 'package:sqflite/sqflite.dart';
import 'package:mikutter_fcm/model/mikutter_message.dart';

final String tableMessage = 'mikutter_message';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnBody = 'body';
final String columnUrl = 'url';

class MikutterMessageProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableMessage ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnBody text not null,
  $columnUrl text not null)
''');
    });
  }

  Future<MikutterMessage> insert(MikutterMessage message) async {
    message.id = await db.insert(tableMessage, message.toMap());
    return message;
  }

  Future<List<MikutterMessage>> getMessages(int count) async {
    List<Map> maps = await db.query(
      tableMessage,
      columns: [columnId, columnTitle, columnBody, columnUrl],
      limit: count,
    );
    return maps.map((entity) => MikutterMessage.fromMap(entity)).toList();
  }

  Future<MikutterMessage> findMessage(int id) async {
    List<Map> maps = await db.query(
      tableMessage,
      columns: [columnId, columnTitle, columnBody, columnUrl],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return MikutterMessage.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableMessage, where: '$columnId = ?', whereArgs: [id]);
  }

  Future close() async => db.close();
}
