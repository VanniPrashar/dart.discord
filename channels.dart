import 'package:discord/db/db.dart';
import 'package:discord/models/categories.dart';
import 'dart:io';

import 'package:sembast/sembast.dart';

class Channel {
  late dynamic id;
  late String name;
  late String categoryName;
  late String channelType;

  Channel(this.id, this.name, this.categoryName, this.channelType);
  static Future<Channel> addChannel(
      String name, String categoryName, String channelType) async {
    try {
      await Db.connect(dbName: 'channel.db');
      final key = await Db.store.add(Db.db, '$name $categoryName $channelType');
      return Channel(key, name, categoryName, channelType);
    } catch (e) {
      print(e);
      exit(1);
    }
  }
}

class Channels {
  final List<Channel> channels = [];
  Future<void> channelDb() async {
    try {
      await Db.connect(dbName: 'channel.db');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getChannel(String cn) async {
    try {
      await channelDb();
      for (int i = 1; true; i++) {
        final res = await Db.get(key: i);
        if (res == null) {
          break;
        } else {
          final id = i;
          final name = res.split(' ')[0];
          final categoryName = res.split(' ')[1];
          final channelType = res.split(' ')[2];
          if (categoryName == cn) {
            channels.add(Channel(id, name, categoryName, channelType));
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> listChannels(String cn) async {
    await getChannel(cn);
    print('Available channels in $cn:');
    for (final category in channels) {
      print(category.name);
    }
  }

  Future<Channel> joinChannel(String cn) async {
    print("Enter channel Name");
    final channelName = stdin.readLineSync().toString();
    await getChannel(cn);
    for (final channel in channels) {
      if (channel.name == channelName) {
        return Channel(channel.id, channel.name, channel.categoryName,
            channel.channelType);
      }
    }
    print("Invalid channel Name");
    exit(1);
  }
}
