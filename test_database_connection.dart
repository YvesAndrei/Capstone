import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print("Testing database connection...");
  
  try {
    // Test the get_message.php API
    final testUri = Uri.parse("http://192.168.100.238/flutter_api/get_message.php?from_user=1&to_user=2");
    print("Testing URL: $testUri");
    
    final response = await http.get(testUri);
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("API Response: $data");
      
      if (data['success'] == true) {
        print("✅ Database connection successful!");
        print("Messages found: ${data['messages'].length}");
      } else {
        print("❌ API Error: ${data['error']}");
      }
    } else {
      print("❌ HTTP Error: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception: $e");
  }
}
