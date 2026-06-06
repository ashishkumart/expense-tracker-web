import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);
final indianDateFormat = DateFormat('dd/MM/yyyy');
final monthFormat = DateFormat('MMMM yyyy');

DateTime dateOnlyUtc(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

Color colorFromHex(String value) =>
    Color(int.parse(value.replaceFirst('#', '0xFF')));

String colorToHex(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
