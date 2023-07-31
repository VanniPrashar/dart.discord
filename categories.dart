import 'package:discord/db/db.dart';
import 'dart:io';

import 'package:sembast/sembast.dart';

class Category {
  late dynamic id;
  late String name;
  late String servername;

  Category(this.id, this.name, this.servername);

  static Future<Category> addCategory(String name, String servername) async {
    try {
      await Db.connect(dbName: 'category.db');
      final key = await Db.store.add(Db.db, '$name $servername');
      return Category(key, name, servername);
    } catch (e) {
      print(e);
      exit(1);
    }
  }
}

class Categories {
  final List<Category> categories = [];
  Future<void> categoryDb() async {
    try {
      await Db.connect(dbName: 'category.db');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCategory(String sn) async {
    try {
      await categoryDb();
      for (int i = 1; true; i++) {
        final res = await Db.get(key: i);
        if (res == null) {
          break;
        } else {
          final id = i;
          final name = res.split(' ')[0];
          final servername = res.split(' ')[1];
          if (servername == sn) categories.add(Category(id, name, servername));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> listCategories(String sn) async {
    await getCategory(sn);
    print('Available Categories in $sn:');
    for (final category in categories) {
      print(category.name);
    }
  }

  Future<Category> checkoutCategory(String serverName) async {
    await getCategory(serverName);
    print("Enter category name");
    final name = stdin.readLineSync().toString();
    for (final category in categories) {
      if (category.name == name) {
        return Category(category.id, category.name, category.servername);
      }
    }
    print('Invalid category name');
    exit(1);
  }
}
