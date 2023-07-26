import 'package:discord/db/db.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:args/args.dart';
// import 'package:crypto/crypto.dart';
// import 'package:password_hash/password_hash.dart';

import 'dart:io';

class Users {
  late String username;
  late String password;
  bool isLoggedIn = false;

  Users(String password, String username) {
    this.password = password;
    this.username = username;
  }
  static Future<void> userDB() async {
    await Db.connect(dbName: 'users.db');
  }

  static Future<Users> Register() async {
    await userDB();
    print("Enter Username");
    final username = stdin.readLineSync().toString();
    print("Enter password");
    final password = stdin.readLineSync().toString();

    // Hash the password before storing it in the database

    await Db.storeKeyValue(
        key: 'usernameAndPass',
        value: {"username": username, "pass": password});
    return Users(password, username);
  }

  // static Future<String> hashPassword(String password) async {
  //   // You can specify the number of salt rounds as a cost factor (e.g., 12)
  //   final saltRounds = 12;
  //   final hashedPassword = await Bcrypt.hash(password, saltRounds);
  //   return hashedPassword;
  // }

  // // New method to hash the password
  // static String hashPassword(String password) {
  //   final salt = generateSalt();
  //   final key = pbkdf2(utf8.encode(password), salt, 100000, 32, sha256);
  //   final hash = base64.encode(key);
  //   return "${base64.encode(salt)}:$hash";
  // }

  // // Method to generate a random salt
  // static List<int> generateSalt() {
  //   final random = Random.secure();
  //   final salt = List<int>.generate(32, (i) => random.nextInt(256));
  //   return salt;
  // }

// New method to hash the password
  static Future<String> hashPassword(String password) async {
    return await BCrypt.hashpw(
        password, '28'); // Use cost factor of 12 for good security
  }

  static Future<Users> Login(
      {required String username, required String password}) async {
    await userDB();
    final response = await Db.get(key: 'usernameAndPass');
    if (response == null) {
      print("Register First");
      final user = await Users.Register();
      return user;
    }
    if (response["username"] != username) {
      await Db.delete(key: 'loggedin');
      Db.storeKeyValue(key: 'loggedin', value: false);
      print("Register First");
      final user = await Users.Register();
      return user;
    } else {
      if (response["pass"] != password) {
        await Db.delete(key: 'loggedin');
        await Db.storeKeyValue(key: 'loggedin', value: false);
        print("Invalid Password");
        exit(1);
      } else {
        await Db.delete(key: 'loggedin');
        Db.storeKeyValue(key: 'loggedin', value: true);
        print("LoggedInSuccessFully");
        return Users(password, username);
      }
    }
  }

  static Future<Users> LoginwithUsername(String username) async {
    await userDB();
    final response = await Db.get(key: 'usernameAndPass');
    if (response == null) {
      print("Register First");
      exit(1);
    }
    if (response["username"] != username) {
      await Db.delete(key: 'loggedin');
      await Db.storeKeyValue(key: 'loggedin', value: false);
      final user = await Users.Register();
      return user;
    } else {
      print("Enter password");
      final password = stdin.readLineSync().toString();
      if (response["pass"] != password) {
        await Db.delete(key: 'loggedin');
        await Db.storeKeyValue(key: 'loggedin', value: false);
        print("Invalid Password");
        exit(1);
      } else {
        await Db.delete(key: 'loggedin');
        Db.storeKeyValue(key: 'loggedin', value: true);
        print("LoggedInSuccessFully");
        return Users(password, username);
      }
    }
  }

  static Future<void> Logout() async {
    await userDB();
    await Db.delete(key: 'usernameAndPass');
    await Db.delete(key: 'loggedin');
  }

  static Future<bool> isLoggedin() async {
    await userDB();
    final isLoggedIn = await Db.get(key: 'loggedin');
    if (isLoggedIn == null) {
      return false;
    }
    if (isLoggedIn) {
      return true;
    } else {
      return false;
    }
  }
}
