
import 'package:uuid/uuid.dart';
import 'local_store.dart';

class LinkService {
  static String ensureMyCode(AppState app) {
    if (app.myCode.isEmpty) {
      final code = const Uuid().v4().split('-').first; // short
      app.setMyCode(code);
    }
    return app.myCode;
  }

  static String buildInviteUrl(AppState app) {
    final code = ensureMyCode(app);
    final nick = Uri.encodeComponent(app.nickname.isEmpty ? 'user' : app.nickname);
    // Custom scheme deep link: heartapp://pair?code=XXXX&name=Nick
    return 'heartapp://pair?code=$code&name=$nick';
  }

  static void applyIncomingUri(AppState app, Uri uri) {
    if (uri.scheme != 'heartapp') return;
    if (uri.host != 'pair') return;
    final code = uri.queryParameters['code'] ?? '';
    final name = uri.queryParameters['name'] ?? '';
    if (code.isNotEmpty) {
      app.setPartnerCode(code);
      if (name.isNotEmpty) app.setPartnerName(name);
      app.setPaired(true);
      app.finishOnboarding();
    }
  }
}
