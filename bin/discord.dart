import 'package:discord/discord.dart' as discord;
import 'package:discord/models/user.dart';
import 'package:discord/models/servers.dart';
import 'package:args/args.dart';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
 
  parser.addCommand('logout');
  
  parser.addCommand('create');
  parser.addCommand('join');
  parser.addCommand('list');

  var username = '';
  var password = '';

  parser.addOption('username',
      abbr: 'u', callback: (un) => username = un.toString());
  parser.addOption('password',
      abbr: 'p', callback: (p) => password = p.toString());
  // Adding the 'username' option.
  parser.addOption('name', abbr: 'n');
  parser.addOption('inviteCode', abbr: 'i');
  final results = parser.parse(arguments);
  print(results);

  if (results.command == null) {
    print("Usage: dart your_script_name.dart <command>");
    print(parser.usage);
    return;
  }

  var user = await Users.Login(username: username, password: password);

  final command = results.command?.name;

  final servers = Servers();

  switch (command) {
    case 'register':
      await Users.Register();
      break;
    case 'logout':
      await Users.Logout();
      break;
    case 'create':
      print('Enter Server Name');
      final name = stdin.readLineSync().toString();
      print('Enter Invite code');
      final inviteCode = stdin.readLineSync().toString();
      await servers.createServer(name, inviteCode, user);
    case 'join':
      print('Enter Invite Code');
      final inviteCode = stdin.readLineSync().toString();
      await servers.joinServer(inviteCode, user);
    case 'list':
      await servers.listServers();
    default:
      print("Invalid command: $command");
      print(parser.usage);
      break;
  }
}
