import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Future<double> getRate(String targetCurrency) async {
    // Dacă moneda selectată este USD, rata este fix 1.0 (nu facem apel API)
    if (targetCurrency == 'USD') return 1.0;

    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic rawRate = data['rates'][targetCurrency];

        if (rawRate == null) return 1.0;
        
        if (rawRate is String) {
          return double.tryParse(rawRate) ?? 1.0;
        } else if (rawRate is num) {
          return rawRate.toDouble();
        }
      }
      return 1.0;
    } catch (e) {
      print("Eroare CurrencyService: $e");
      return 1.0; // Fallback în caz de eroare internet sau API
    }
  }
}