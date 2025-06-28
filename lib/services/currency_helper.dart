import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mawqif/services/currency_service.dart';

class CurrencyHelper {
  // Singleton instance
  static final CurrencyHelper _instance = CurrencyHelper._internal();
  factory CurrencyHelper() => _instance;
  CurrencyHelper._internal() {
    // Silent automatic detection when helper is first initialized
    _detectCountrySilently();
  }

  Country? _country;
  Currency? _currency;
  bool _isDetecting = false;

  Currency get currency => _currency ?? Currency(code: "USD", symbol: "\$");

  /// Silent detection (called once automatically)
  Future<void> _detectCountrySilently() async {
    if (_isDetecting || _country != null) return; // Prevent multiple calls
    _isDetecting = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        final detectedCountryCode = placemarks.first.isoCountryCode ?? "US";
        _country = Country.parse(detectedCountryCode);
      } else {
        _country = Country.parse("US");
      }
    } catch (_) {
      _country = Country.parse("US");
    }

    _currency = CurrencyService.getCurrencyFromCountryCode(
      _country!.countryCode,
    );

    _isDetecting = false;
  }

  /// Convert price from USD to detected currency
  Future<double> convertPrice(double priceUSD) async {
    // Wait for detection if not ready
    if (_currency == null) {
      await _detectCountrySilently();
    }
    return await CurrencyService.convertPrice(
      priceUSD,
      fromCurrency: "USD",
      toCurrency: _currency!.code,
    );
  }

  /// Optional: Manually override country & currency
  void setCountry(Country country) {
    _country = country;
    _currency = CurrencyService.getCurrencyFromCountryCode(country.countryCode);
  }

  /// Get the detected country name (for display)
  String get countryName => _country?.name ?? "Detecting...";
}
