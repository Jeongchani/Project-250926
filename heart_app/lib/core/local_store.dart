import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';
import 'auth.dart';

class LocalStore {
  final SharedPreferences _p;
  LocalStore._(this._p);
  static Future<LocalStore> create() async {
    final p = await SharedPreferences.getInstance();
    return LocalStore._(p);
  }

  // ---- keys
  static const _kUserId = 'user_id';
  static const _kAuthStatus = 'auth_status'; // 'anon' | 'authed'
  static const _kAuthEmail = 'auth_email';
  static const _kAuthProvider = 'auth_provider';

  static const _kNickname = 'nickname';
  static const _kHeartColor = 'heart_color';
  static const _kModeChosen = 'mode_chosen';
  static const _kMode = 'mode'; // 'love' / 'team'

  // love
  static const _kLovePaired = 'love_paired';
  static const _kLoveMy = 'love_my_code';
  static const _kLovePartner = 'love_partner_code';
  static const _kLovePartnerName = 'love_partner_name';
  static const _kLoveSavedMsg = 'love_saved_message';

  // team
  static const _kTeamJoined = 'team_joined';
  static const _kTeamCode = 'team_code';
  static const _kTeamName = 'team_name';
  static const _kTeamRole = 'team_role'; // 'leader' | 'member'
  static const _kTeamAnnouncements = 'team_announcements'; // json list

  // ---- auth
  String get userId => _p.getString(_kUserId) ?? '';
  set userId(String v) => _p.setString(_kUserId, v);

  Account get account {
    final st = _p.getString(_kAuthStatus) ?? 'anon';
    final email = _p.getString(_kAuthEmail);
    final prov = _p.getString(_kAuthProvider);
    return Account(
      userId: userId,
      status: st == 'authed' ? AuthStatus.authenticated : AuthStatus.anonymous,
      email: email,
      provider: prov,
    );
  }

  void setAuthenticated({required String email, required String provider}) {
    _p.setString(_kAuthStatus, 'authed');
    _p.setString(_kAuthEmail, email);
    _p.setString(_kAuthProvider, provider);
  }

  void setAnonymous() {
    _p.setString(_kAuthStatus, 'anon');
    _p.remove(_kAuthEmail);
    _p.remove(_kAuthProvider);
  }

  // ---- shared
  String get nickname => _p.getString(_kNickname) ?? '';
  set nickname(String v) => _p.setString(_kNickname, v);

  Color get heartColor {
    final v = _p.getInt(_kHeartColor);
    return v == null ? Colors.pink : Color(v);
  }
  set heartColor(Color c) => _p.setInt(_kHeartColor, c.value);

  bool get modeChosen => _p.getBool(_kModeChosen) ?? false;
  set modeChosen(bool v) => _p.setBool(_kModeChosen, v);

  AppMode get mode {
    final m = _p.getString(_kMode) ?? 'love';
    return m == 'team' ? AppMode.team : AppMode.love;
  }
  set mode(AppMode m) => _p.setString(_kMode, m == AppMode.team ? 'team' : 'love');

  // ---- love
  bool get lovePaired => _p.getBool(_kLovePaired) ?? false;
  set lovePaired(bool v) => _p.setBool(_kLovePaired, v);

  String get loveMyCode => _p.getString(_kLoveMy) ?? '';
  set loveMyCode(String v) => _p.setString(_kLoveMy, v);

  String get lovePartnerCode => _p.getString(_kLovePartner) ?? '';
  set lovePartnerCode(String v) => _p.setString(_kLovePartner, v);

  String get lovePartnerName => _p.getString(_kLovePartnerName) ?? '';
  set lovePartnerName(String v) => _p.setString(_kLovePartnerName, v);

  String get loveSavedMessage => _p.getString(_kLoveSavedMsg) ?? '사랑해 💗';
  set loveSavedMessage(String v) => _p.setString(_kLoveSavedMsg, v);

  // ---- team
  bool get teamJoined => _p.getBool(_kTeamJoined) ?? false;
  set teamJoined(bool v) => _p.setBool(_kTeamJoined, v);

  String get teamCode => _p.getString(_kTeamCode) ?? '';
  set teamCode(String v) => _p.setString(_kTeamCode, v);

  String get teamName => _p.getString(_kTeamName) ?? '';
  set teamName(String v) => _p.setString(_kTeamName, v);

  TeamRole get teamRole {
    final s = _p.getString(_kTeamRole) ?? 'member';
    return s == 'leader' ? TeamRole.leader : TeamRole.member;
  }
  set teamRole(TeamRole r) => _p.setString(_kTeamRole, r == TeamRole.leader ? 'leader' : 'member');

  List<Announcement> get teamAnnouncements {
    final raw = _p.getString(_kTeamAnnouncements);
    if (raw == null || raw.isEmpty) return <Announcement>[];
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Announcement.fromJson).toList();
  }
  void addAnnouncement(Announcement a) {
    final cur = teamAnnouncements;
    final next = [...cur, a].map((e) => e.toJson()).toList();
    _p.setString(_kTeamAnnouncements, json.encode(next));
  }
  void clearAnnouncements() => _p.remove(_kTeamAnnouncements);
}
