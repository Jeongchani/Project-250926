
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  final SharedPreferences _prefs;
  LocalStore._(this._prefs);
  static const _kNickname = 'nickname';
  static const _kOnboarded = 'onboarded';
  static const _kPaired = 'paired';
  static const _kMyCode = 'my_code';
  static const _kPartnerCode = 'partner_code';
  static const _kPartnerName = 'partner_name';
  static const _kHeartColor = 'heart_color';
  static const _kSavedMessage = 'saved_message';
  static const _kPremium = 'premium_unlocked';

  static Future<LocalStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore._(prefs);
  }

  String get nickname => _prefs.getString(_kNickname) ?? '';
  set nickname(String v) => _prefs.setString(_kNickname, v);

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  set onboarded(bool v) => _prefs.setBool(_kOnboarded, v);

  bool get paired => _prefs.getBool(_kPaired) ?? false;
  set paired(bool v) => _prefs.setBool(_kPaired, v);

  String get myCode => _prefs.getString(_kMyCode) ?? '';
  set myCode(String v) => _prefs.setString(_kMyCode, v);

  String get partnerCode => _prefs.getString(_kPartnerCode) ?? '';
  set partnerCode(String v) => _prefs.setString(_kPartnerCode, v);

  String get partnerName => _prefs.getString(_kPartnerName) ?? '';
  set partnerName(String v) => _prefs.setString(_kPartnerName, v);

  Color get heartColor {
    final v = _prefs.getInt(_kHeartColor);
    if (v == null) return Colors.pink;
    return Color(v);
    }
  set heartColor(Color c) => _prefs.setInt(_kHeartColor, c.value);

  String get savedMessage => _prefs.getString(_kSavedMessage) ?? '사랑해 💗';
  set savedMessage(String v) => _prefs.setString(_kSavedMessage, v);

  bool get premiumUnlocked => _prefs.getBool(_kPremium) ?? false;
  set premiumUnlocked(bool v) => _prefs.setBool(_kPremium, v);
}

class AppState extends ChangeNotifier {
  final LocalStore store;
  AppState(this.store);

  String get nickname => store.nickname;
  bool get onboarded => store.onboarded;
  bool get paired => store.paired;
  String get myCode => store.myCode;
  String get partnerCode => store.partnerCode;
  String get partnerName => store.partnerName;
  Color get heartColor => store.heartColor;
  String get savedMessage => store.savedMessage;
  bool get premiumUnlocked => store.premiumUnlocked;

  void setNickname(String v) { store.nickname = v.trim(); notifyListeners(); }
  void finishOnboarding() { store.onboarded = true; notifyListeners(); }
  void setMyCode(String v) { store.myCode = v; notifyListeners(); }
  void setPartnerCode(String v) { store.partnerCode = v; notifyListeners(); }
  void setPartnerName(String v) { store.partnerName = v; notifyListeners(); }
  void setPaired(bool v) { store.paired = v; notifyListeners(); }
  void setHeartColor(Color c) { store.heartColor = c; notifyListeners(); }
  void setSavedMessage(String v) { store.savedMessage = v.trim(); notifyListeners(); }
  void unlockPremium() { store.premiumUnlocked = true; notifyListeners(); }
}
