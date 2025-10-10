import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api-colombia.com';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // API Endpoints
  static String get typicalDishEndpoint => '$apiBaseUrl/api/$apiVersion/TypicalDish';
  static String get naturalAreaEndpoint => '$apiBaseUrl/api/$apiVersion/NaturalArea';
  static String get regionEndpoint => '$apiBaseUrl/api/$apiVersion/Region';
  static String get invasiveSpecieEndpoint => '$apiBaseUrl/api/$apiVersion/InvasiveSpecie';

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}