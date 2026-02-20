import 'package:currency_converter/currency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_converter/currency_converter.dart';
import 'package:intl/intl.dart';

final currencyConverterProvider = Provider<CurrencyService>((ref) {
  return CurrencyService();
});

class CurrencyService {
  final _vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Convert USD string to VND and format it
  Future<String> convertUsdToVnd(String? usdAmount) async {
    if (usdAmount == null || usdAmount.isEmpty) {
      return '';
    }

    try {
      final amount = double.tryParse(usdAmount);
      if (amount == null || amount == 0) {
        return '0₫';
      }

      final convertedAmount = await CurrencyConverter.convert(
        from: Currency.usd,
        to: Currency.vnd,
        amount: amount,
      );

      return _vndFormatter.format(convertedAmount);
    } catch (e) {
      // If conversion fails, show the USD amount
      return '\$$usdAmount';
    }
  }

  /// Format VND amount
  String formatVnd(double amount) {
    return _vndFormatter.format(amount);
  }
}

/// Provider for converted currency display
final convertedCurrencyProvider = FutureProvider.family<String, String?>((
  ref,
  usdAmount,
) async {
  final currencyService = ref.read(currencyConverterProvider);
  return currencyService.convertUsdToVnd(usdAmount);
});
