
import 'package:uuid/uuid.dart';
import 'app_state.dart';

class LinkService {
  static String genShortCode() => const Uuid().v4().split('-').first;

  /// Build couple invite link
  static String buildLoveInvite(String myCode, String nickname) {
    final nick = Uri.encodeComponent(nickname.isEmpty ? 'user' : nickname);
    return 'heartapp://pair?code=$myCode&name=$nick';
  }

  /// Build team invite (leader shares)
  static String buildTeamInvite(String teamCode, String leaderName, String teamName) {
    final n = Uri.encodeComponent(leaderName.isEmpty ? 'leader' : leaderName);
    final t = Uri.encodeComponent(teamName.isEmpty ? 'team' : teamName);
    return 'heartapp://team?code=$teamCode&name=$n&team=$t';
  }

  /// Parse incoming link (both modes). Mutates app state.
  static void applyIncomingUriTo(AppState app, Uri uri) {
    if (uri.scheme != 'heartapp') return;
    switch (uri.host) {
      case 'pair':
        final code = uri.queryParameters['code'] ?? '';
        final name = uri.queryParameters['name'] ?? '';
        if (code.isNotEmpty) {
          app.chooseMode(AppMode.love);
          app.loveSetPartner(code, name);
        }
        break;
      case 'team':
        final code = uri.queryParameters['code'] ?? '';
        final team = uri.queryParameters['team'] ?? '';
        if (code.isNotEmpty) {
          app.chooseMode(AppMode.team);
          // Recipient defaults to member
          app.teamJoinAsMember(code, team);
        }
        break;
      default:
        break;
    }
  }
}

extension AppDeepLink on AppState {
  void applyIncomingUri(Uri uri) => LinkService.applyIncomingUriTo(this, uri);
}
