import 'package:flutter/material.dart';

class AppConstants {
  static const String apiKey = '157d5bded2e04b62a781f636da7e306e'; 
  
  static const Map<String, String> assets = {
    'Bitcoin': 'BTC/USD',
    'Ethereum': 'ETH/USD',
    'Apple': 'AAPL',
    'Tesla': 'TSLA',
    'Nvidia': 'NVDA',
    'S&P 500': 'SPX',
  };

  static const List<String> currencies = ['USD', 'EUR', 'RON'];
}

class AppColors {
  static const Color primaryIndigo = Color(0xFF1A237E);
  static const Color accentAmber = Colors.amber;
  static final List<Color> bgGradient = [
    const Color(0xFF1A237E),
    const Color(0xFF3949AB),
    const Color(0xFFE1E5E9),
  ];
}