class CurrencyService {
  // Full ISO country → currency mapping
  static final Map<String, Currency> _currencyMap = {
    // --- USD countries/territories ---
    "US": Currency(code: "USD", symbol: "\$"),
    "PR": Currency(code: "USD", symbol: "\$"),
    "GU": Currency(code: "USD", symbol: "\$"),
    "VI": Currency(code: "USD", symbol: "\$"),
    "AS": Currency(code: "USD", symbol: "\$"),
    "FM": Currency(code: "USD", symbol: "\$"),
    "MH": Currency(code: "USD", symbol: "\$"),
    "PW": Currency(code: "USD", symbol: "\$"),

    // --- PKR ---
    "PK": Currency(code: "PKR", symbol: "₨"),

    // --- AED ---
    "AE": Currency(code: "AED", symbol: "د.إ"),

    // --- EUR (Eurozone countries) ---
    "FR": Currency(code: "EUR", symbol: "€"),
    "DE": Currency(code: "EUR", symbol: "€"),
    "IT": Currency(code: "EUR", symbol: "€"),
    "ES": Currency(code: "EUR", symbol: "€"),
    "NL": Currency(code: "EUR", symbol: "€"),
    "BE": Currency(code: "EUR", symbol: "€"),
    "PT": Currency(code: "EUR", symbol: "€"),
    "IE": Currency(code: "EUR", symbol: "€"),
    "FI": Currency(code: "EUR", symbol: "€"),
    "GR": Currency(code: "EUR", symbol: "€"),
    "AT": Currency(code: "EUR", symbol: "€"),
    "LU": Currency(code: "EUR", symbol: "€"),
    "CY": Currency(code: "EUR", symbol: "€"),
    "EE": Currency(code: "EUR", symbol: "€"),
    "LV": Currency(code: "EUR", symbol: "€"),
    "LT": Currency(code: "EUR", symbol: "€"),
    "MT": Currency(code: "EUR", symbol: "€"),
    "SK": Currency(code: "EUR", symbol: "€"),
    "SI": Currency(code: "EUR", symbol: "€"),
    "HR": Currency(code: "EUR", symbol: "€"),

    // --- GBP ---
    "GB": Currency(code: "GBP", symbol: "£"),
    "GG": Currency(code: "GBP", symbol: "£"),
    "IM": Currency(code: "GBP", symbol: "£"),
    "JE": Currency(code: "GBP", symbol: "£"),

    // --- CAD ---
    "CA": Currency(code: "CAD", symbol: "C\$"),

    // --- AUD/NZD family ---
    "AU": Currency(code: "AUD", symbol: "A\$"),
    "NZ": Currency(code: "NZD", symbol: "NZ\$"),

    // --- SAR ---
    "SA": Currency(code: "SAR", symbol: "﷼"),

    // --- INR ---
    "IN": Currency(code: "INR", symbol: "₹"),

    // --- TRY ---
    "TR": Currency(code: "TRY", symbol: "₺"),

    // --- CNY ---
    "CN": Currency(code: "CNY", symbol: "¥"),

    // --- JPY ---
    "JP": Currency(code: "JPY", symbol: "¥"),

    // --- KWD ---
    "KW": Currency(code: "KWD", symbol: "KD"),

    // --- QAR ---
    "QA": Currency(code: "QAR", symbol: "﷼"),

    // --- BHD ---
    "BH": Currency(code: "BHD", symbol: ".د.ب"),

    // --- OMR ---
    "OM": Currency(code: "OMR", symbol: "﷼"),

    // --- CHF ---
    "CH": Currency(code: "CHF", symbol: "CHF"),

    // --- ZAR ---
    "ZA": Currency(code: "ZAR", symbol: "R"),
  };

  static Currency getCurrencyFromCountryCode(String countryCode) {
    return _currencyMap[countryCode] ??
        Currency(code: "USD", symbol: "\$"); // fallback
  }

  static Future<double> convertPrice(
    double amount, {
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // For real use, replace with API (Fixer, OpenExchangeRates, etc.)
    double rate = 1.0;
    if (fromCurrency == "USD" && toCurrency == "PKR") rate = 280;
    if (fromCurrency == "USD" && toCurrency == "AED") rate = 3.67;
    if (fromCurrency == "USD" && toCurrency == "EUR") rate = 0.92;
    if (fromCurrency == "USD" && toCurrency == "GBP") rate = 0.78;
    if (fromCurrency == "USD" && toCurrency == "INR") rate = 83.1;
    if (fromCurrency == "USD" && toCurrency == "SAR") rate = 3.75;
    if (fromCurrency == "USD" && toCurrency == "CNY") rate = 7.25;
    if (fromCurrency == "USD" && toCurrency == "JPY") rate = 145.0;

    await Future.delayed(const Duration(milliseconds: 200));
    return amount * rate;
  }
}

class Currency {
  final String code;
  final String symbol;
  Currency({required this.code, required this.symbol});
}
