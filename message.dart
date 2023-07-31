import 'dart:io';

import 'package:discord/db/db.dart';
import 'package:discord/models/user.dart';
import 'package:sembast/sembast.dart';

class Message {
  late dynamic id;
  late String sender;
  late String message;
  late String channelName;

  Message(this.id, this.sender, this.message, this.channelName);
  static Future<Message> addMessage(
      String sender, String message, String channelName) async {
    try {
      await Db.connect(dbName: 'message.db');
      final key = await Db.store.add(Db.db, '$sender $message in $channelName');
      return Message(key, sender, message, channelName);
    } catch (e) {
      print(e);
      exit(1);
    }
  }
}

class Messages {
  final List<Message> messages = [];
  Future<void> messageDb() async {
    try {
      await Db.connect(dbName: 'message.db');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getMessages(String channelName) async {
    try {
      await messageDb();
      for (int i = 1; true; i++) {
        final res = await Db.get(key: i);
        print(res);
        if (res == null) {
          break;
        } else {
          final id = i;
          final sender = res.split(' ')[0];
          final message = res.split(' ')[1];
          final channel = res.split(' ')[4];
          if (channel == channelName) {
            messages.add(Message(id, sender, message, channel));
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> listMessages(String channelName) async {
    await getMessages(channelName);
    print('Messages in $channelName');
    print(messages);
    for (final message in messages) {
      print('[${message.sender}] ${message.message}');
    }
  }
}

class DmMessage {
  late dynamic id;
  late String sender;
  late String message;
  late String to;

  DmMessage(this.id, this.sender, this.message, this.to);
  static Future<Message> addMessage(
      String sender, String message, String to) async {
    bool founduser = false;
    await Db.connect(dbName: 'users.db');
    for (int i = 1; true; i++) {
      final res = await Db.get(key: i);
      if (res == null) {
        break;
      } else {
        if (res.split(' ')[0] == to) {
          founduser = true;
        }
      }
    }
    if (founduser) {
      try {
        await Db.connect(dbName: 'message-dm.db');
        final key = await Db.store.add(Db.db, '$sender $message to $to');
        return Message(key, sender, message, to);
      } catch (e) {
        print(e);
        exit(1);
      }
    } else {
      print("Invalid sender");
      exit(1);
    }
  }
}

class DmMessages {
  final List<DmMessage> messages = [];
  Future<void> messageDb() async {
    try {
      await Db.connect(dbName: 'message-dm.db');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getMessages(Users user) async {
    try {
      await messageDb();
      for (int i = 1; true; i++) {
        final res = await Db.get(key: i);
        print(res);
        if (res == null) {
          break;
        } else {
          final id = i;
          final sender = res.split(' ')[0];
          final message = res.split(' ')[1];
          final to = res.split(' ')[4];
          if (sender == user.username || to == user.username) {
            messages.add(DmMessage(id, sender, message, to));
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> listMessages(Users user) async {
    await getMessages(user);
    print('DM Messages');
    for (final message in messages) {
      print('[${message.sender}] ${message.message} to ${message.to}');
    }
  }
}
