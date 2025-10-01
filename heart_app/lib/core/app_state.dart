
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'auth.dart';
import 'local_store.dart';
import 'link_service.dart';

/// High-level application mode.
enum AppMode { love, team }

/// Team role
enum TeamRole { leader, member }

/// Simplified in-app announcement model (local only for now).
class Announcement {
  final String id; // uuid
  final String text;
  final DateTime createdAt;

  Announcement({required this.id, required this.text, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: j['id'] as String,
        text: j['text'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class AppState extends ChangeNotifier {
  final LocalStore store;
  AppState(this.store) {
    // Ensure we have a local anonymous id for recovery/linking later.
    if (store.userId.isEmpty) {
      store.userId = const Uuid().v4();
    }
  }

  // --------- Auth (local-first, upgrade-ready)
  Account get account => store.account;
  String get userId => store.userId;
  bool get isAuthed => account.status == AuthStatus.authenticated;

  /// Simulate "upgrade" to an email account (no server yet).
  void upgradeToEmail(String email) {
    store.setAuthenticated(email: email, provider: 'email');
    notifyListeners();
  }

  /// Local logout (keeps userId for now so local data can be mapped later).
  void logoutToAnonymous() {
    store.setAnonymous();
    notifyListeners();
  }

  // --------- Shared (both modes)
  String get nickname => store.nickname;
  set nickname(String v) { store.nickname = v.trim(); notifyListeners(); }

  Color get heartColor => store.heartColor;
  set heartColor(Color c) { store.heartColor = c; notifyListeners(); }

  bool get modeChosen => store.modeChosen;
  AppMode get mode => store.mode;
  void chooseMode(AppMode m) { store.mode = m; store.modeChosen = true; notifyListeners(); }
  void switchMode() { store.mode = (store.mode == AppMode.love) ? AppMode.team : AppMode.love; notifyListeners(); }

  // --------- Love (couple) mode
  bool get lovePaired => store.lovePaired;
  String get loveMyCode => store.loveMyCode;
  String get lovePartnerCode => store.lovePartnerCode;
  String get lovePartnerName => store.lovePartnerName;
  String get loveSavedMessage => store.loveSavedMessage;

  void loveEnsureMyCode() { if (store.loveMyCode.isEmpty) store.loveMyCode = LinkService.genShortCode(); notifyListeners(); }
  void loveSetPartner(String code, String name) { store.lovePartnerCode = code; store.lovePartnerName = name; store.lovePaired = true; notifyListeners(); }
  void loveSetSavedMessage(String v) { store.loveSavedMessage = v.trim(); notifyListeners(); }

  // --------- Team mode
  bool get teamJoined => store.teamJoined;
  String get teamCode => store.teamCode;
  String get teamName => store.teamName;
  TeamRole get teamRole => store.teamRole;

  List<Announcement> get announcements => store.teamAnnouncements;

  void teamEnsureMyCode() { if (store.teamCode.isEmpty) store.teamCode = LinkService.genShortCode(); notifyListeners(); }
  void teamCreateAsLeader(String code, String name) { store.teamCode = code; store.teamName = name; store.teamRole = TeamRole.leader; store.teamJoined = true; notifyListeners(); }
  void teamJoinAsMember(String code, String name) { store.teamCode = code; store.teamName = name; store.teamRole = TeamRole.member; store.teamJoined = true; notifyListeners(); }
  void teamPost(String text) { store.addAnnouncement(Announcement(id: const Uuid().v4(), text: text, createdAt: DateTime.now())); notifyListeners(); }
  void teamClear() { store.clearAnnouncements(); notifyListeners(); }

  // --------- Deep link handler (single entry)
  void applyIncomingUri(Uri uri) {
    LinkService.applyIncomingUriTo(this, uri);
  }
}
