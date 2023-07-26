import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class Db {
  static DatabaseFactory dbFactory = databaseFactoryIo;
  static late Database db;
  static final store = StoreRef.main();

  static Future<void> connect({required String dbName}) async {
    db = await dbFactory.openDatabase(dbName);
  }

  static Future<void> storeKeyValue(
      {required String key, required dynamic value}) async {
    await store.record(key).put(db, value);
  }

  static Future<dynamic> get({required String key}) async {
    final value = await store.record(key).get(db);
    return value;
  }

  static Future<void> delete({required String key}) async {
    await store.record(key).delete(db);
  }
}
