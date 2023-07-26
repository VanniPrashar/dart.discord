import 'dart:io';
import 'dart:js_interop';
import 'package:args/args.dart';
import 'package:discord/db/db.dart';
import 'package:discord/models/user.dart';

class Server {
  late String name;
  late String inviteCode;
  List<Users> users = [];

  Server(name, inviteCode, Users? user) {
    this.name = name;
    this.inviteCode = inviteCode;
    if (user != null) users.add(user);
  }
}

class Servers {
  late List<Server> _servers;

  Future<void> serverDb() async {
    try {
      await Db.connect(dbName: 'servers.db');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getServers() async {
    try {
      await serverDb();
      final res = await Db.get(key: 'servers');
      if (res == null) {
        _servers = [];
      } else {
        _servers = res["server"];
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createServer(String name, String inviteCode, Users? user) async {
    try {
      await getServers();
      _servers.add(Server(name, inviteCode, user));
      try {
        for (var i = 0; i < _servers.length; i++) {
          await Db.storeKeyValue(key: 'servers$i', value: {
            "servers$i": [
              _servers[i].name,
              _servers[i].users.map((e) => e.username).toString(),
              _servers[i].inviteCode
            ]
          });
        }
        print('Server "$name" created with invite code "$inviteCode".');
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> listServers() async {
    await getServers();
    print('Available Servers:');
    print(_servers);
    for (var server in _servers) {
      print('${server.name} - Invite Code: ${server.inviteCode}');
    }
  }

  Future<void> joinServer(String inviteCode, Users user) async {
    await getServers();
    final server = _servers.firstWhere(
      (s) => s.inviteCode == inviteCode,
      orElse: () => Server('', '', user),
    );
    if (server.name == '') {
      print('Server with invite code "$inviteCode" not found.');
    } else {
      print('Joined the server: ${server.name}');
      server.users.add(user);
      _servers = [..._servers, server];
      await Db.storeKeyValue(key: 'servers', value: {"servers": _servers});
    }
  }
}
