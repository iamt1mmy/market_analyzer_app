import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<List<dynamic>> fetchHistory(String symbol, DateTime start) async {
    String startStr = DateFormat('yyyy-MM-dd').format(start);
    final url = Uri.parse('https://api.twelvedata.com/time_series?symbol=$symbol&interval=1day&start_date=$startStr&apikey=${AppConstants.apiKey}');
    
    final response = await http.get(url);
    final data = json.decode(response.body);
    
    if (data['status'] == 'error') throw Exception(data['message']);
    return (data['values'] as List).reversed.toList();
  }
}