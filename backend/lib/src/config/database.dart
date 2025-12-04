import 'package:dotenv/dotenv.dart';

class DatabaseConfig {
  static late String host;
  static late int port;
  static late String databaseName;
  static late String username;
  static late String password;

  static Future<void> initialize() async {
    var env = DotEnv(includePlatformEnvironment: true)..load();

    host = env['DB_HOST'] ?? 'localhost';
    port = int.parse(env['DB_PORT'] ?? '5432');
    databaseName = env['DB_NAME'] ?? 'sportofolio_db';
    username = env['DB_USER'] ?? 'postgres';
    password = env['DB_PASSWORD'] ?? '';

    // Initialize database connection here
    // Example for PostgreSQL:
    // await _initializePostgres();
  }

  // Example PostgreSQL initialization
  // static Future<void> _initializePostgres() async {
  //   final connection = PostgreSQLConnection(
  //     host,
  //     port,
  //     databaseName,
  //     username: username,
  //     password: password,
  //   );
  //   await connection.open();
  // }
}
