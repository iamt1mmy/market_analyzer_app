import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CurrencyService {
  static Future<double> getRate(String target) async {
    if (target == 'USD') return 1.0;
    final url = Uri.parse('https://api.twelvedata.com/exchange_rate?symbol=USD/$target&apikey=${AppConstants.apiKey}');
    final response = await http.get(url);
    return double.parse(json.decode(response.body)['rate']);
  }
}