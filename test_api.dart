import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Probando endpoints de API Colombia...\n');
  
  // Test Regions
  await testEndpoint('Regions', 'https://api-colombia.com/api/v1/Region');
  
  // Test InvasiveSpecie
  await testEndpoint('InvasiveSpecie', 'https://api-colombia.com/api/v1/InvasiveSpecie');
  
  // Test TypicalDish
  await testEndpoint('TypicalDish', 'https://api-colombia.com/api/v1/TypicalDish');
  
  // Test NaturalArea
  await testEndpoint('NaturalArea', 'https://api-colombia.com/api/v1/NaturalArea');
}

Future<void> testEndpoint(String name, String url) async {
  try {
    print('Testing $name endpoint: $url');
    final response = await http.get(Uri.parse(url));
    
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List && jsonData.isNotEmpty) {
        print('First item structure:');
        print(JsonEncoder.withIndent('  ').convert(jsonData.first));
      } else {
        print('Response: ${response.body}');
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
  print('\n' + '=' * 50 + '\n');
}