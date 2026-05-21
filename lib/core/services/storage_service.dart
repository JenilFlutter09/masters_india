import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService() : _box = GetStorage(), _memoryStore = null;

  StorageService.memory() : _box = null, _memoryStore = <String, dynamic>{};

  final GetStorage? _box;
  final Map<String, dynamic>? _memoryStore;

  static const _baseUrlKey = 'baseUrl';
  static const _loginPathKey = 'loginPath';
  static const _tokenKey = 'token';
  static const _userEmailKey = 'userEmail';
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _scaleAddressKey = 'scaleAddress';
  static const _scaleNameKey = 'scaleName';
  static const _printerAddressKey = 'printerAddress';
  static const _printerNameKey = 'printerName';

  T? _read<T>(String key) {
    final box = _box;
    if (box != null) {
      return box.read<T>(key);
    }
    return _memoryStore![key] as T?;
  }

  Future<void> _write(String key, dynamic value) async {
    final box = _box;
    if (box != null) {
      await box.write(key, value);
      return;
    }
    _memoryStore![key] = value;
  }

  Future<void> _remove(String key) async {
    final box = _box;
    if (box != null) {
      await box.remove(key);
      return;
    }
    _memoryStore!.remove(key);
  }

  String get baseUrl {
    // final stored = _read<String>(_baseUrlKey)?.trim();
    // if (stored == null ||
    //     stored.isEmpty ||
    //     stored == 'http://10.0.2.2:8000/api/v1') {
    //   return 'https://mastersindia.punitinstrument.com/api/v1';
    // }
    // return stored;
    return 'https://mastersindia.punitinstrument.com/api/v1';
   // return 'http://127.0.0.1:8000/api/v1';
   // return 'http://192.168.0.108:8000/api/v1';
  }

  Future<void> saveBaseUrl(String value) => _write(_baseUrlKey, value.trim());

  String get loginPath =>
      (_read<String>(_loginPathKey) ?? '/auth/login').trim();

  Future<void> saveLoginPath(String value) =>
      _write(_loginPathKey, value.trim());

  String? get token => _read<String>(_tokenKey);

  Future<void> saveToken(String? value) => _write(_tokenKey, value);

  String? get userEmail => _read<String>(_userEmailKey);

  Future<void> saveUserEmail(String? value) => _write(_userEmailKey, value);

  int? get userId => _read<int>(_userIdKey);

  Future<void> saveUserId(int? value) => _write(_userIdKey, value);

  String? get userName => _read<String>(_userNameKey);

  Future<void> saveUserName(String? value) => _write(_userNameKey, value);

  String? get scaleAddress => _read<String>(_scaleAddressKey);
  String? get scaleName => _read<String>(_scaleNameKey);
  String? get printerAddress => _read<String>(_printerAddressKey);
  String? get printerName => _read<String>(_printerNameKey);

  Future<void> saveScaleSelection({String? address, String? name}) async {
    await _write(_scaleAddressKey, address);
    await _write(_scaleNameKey, name);
  }

  Future<void> savePrinterSelection({String? address, String? name}) async {
    await _write(_printerAddressKey, address);
    await _write(_printerNameKey, name);
  }

  Future<void> clearSession() async {
    await _remove(_tokenKey);
    await _remove(_userEmailKey);
    await _remove(_userIdKey);
    await _remove(_userNameKey);
  }
}
