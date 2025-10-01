
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/link_service.dart';

class TeamHomeScreen extends StatefulWidget {
  const TeamHomeScreen({super.key});

  @override
  State<TeamHomeScreen> createState() => _TeamHomeScreenState();
}

class _TeamHomeScreenState extends State<TeamHomeScreen> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _teamName = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _teamName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    app.teamEnsureMyCode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지 모드(팀)'),
        leading: IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: '모드 전환',
          onPressed: () { app.switchMode(); Navigator.pushReplacementNamed(context, app.mode == AppMode.love ? '/love' : '/team'); },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.link), onPressed: () => _showLinkSheet(context, app)),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () => _showAccountSheet(context, app)),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _showRoleSheet(context, app)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              app.teamJoined
                ? '팀: ${app.teamName.isEmpty ? app.teamCode : app.teamName}   (${app.teamRole == TeamRole.leader ? '리더' : '팀원'})'
                : '아직 팀에 참여하지 않았어요',
              style: TextStyle(color: app.teamJoined ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 12),
            if (app.teamRole == TeamRole.leader) ...[
              // Leader can broadcast (local only for now)
              TextField(
                controller: _text,
                maxLines: 2,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '공지 내용 작성'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: !app.teamJoined ? null : () {
                  if (_text.text.trim().isEmpty) return;
                  app.teamPost(_text.text.trim());
                  _text.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('보냈다고 가정 ✅ (로컬 저장)')));
                },
                icon: const Icon(Icons.campaign),
                label: const Text('확성기 보내기'),
              ),
              const SizedBox(height: 12),
            ],
            const Text('공지 기록'),
            const SizedBox(height: 8),
            Expanded(
              child: app.announcements.isEmpty
                ? const Center(child: Text('아직 공지가 없어요'))
                : ListView.separated(
                    itemCount: app.announcements.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = app.announcements[i];
                      return ListTile(
                        leading: const Icon(Icons.campaign),
                        title: Text(a.text),
                        subtitle: Text(a.createdAt.toLocal().toString()),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkSheet(BuildContext context, AppState app) {
    final link = LinkService.buildTeamInvite(app.teamCode, app.nickname, app.teamName);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('팀 접속 코드/링크', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText('코드: ${app.teamCode}'),
          const SizedBox(height: 8),
          SelectableText('링크: $link'),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.check), label: const Text('닫기')),
        ]),
      ),
    );
  }

  void _showRoleSheet(BuildContext context, AppState app) {
    _teamName.text = app.teamName;
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('팀 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _teamName,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '팀 이름(선택)'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(
              onPressed: () {
                // Become leader and create/join team (local)
                app.teamCreateAsLeader(app.teamCode, _teamName.text.trim());
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.verified_user),
              label: const Text('리더로 생성/참여'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '코드로 참여(팀원)'),
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  app.teamJoinAsMember(v.trim(), _teamName.text.trim());
                  Navigator.pop(ctx);
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showAccountSheet(BuildContext context, AppState app) {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('계정(미래 확장용)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText('사용자 ID: ${app.userId}'),
          const SizedBox(height: 8),
          Text('상태: ${app.isAuthed ? '인증됨' : '익명'}'),
          const SizedBox(height: 12),
          if (!app.isAuthed) ...[
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '이메일(업그레이드 데모)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () { if (emailCtrl.text.trim().isNotEmpty) { app.upgradeToEmail(emailCtrl.text.trim()); Navigator.pop(ctx); } },
              icon: const Icon(Icons.upgrade),
              label: const Text('익명 → 이메일 계정으로 업그레이드 (로컬 데모)'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () { app.logoutToAnonymous(); Navigator.pop(ctx); },
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃(익명으로 전환, 로컬)'),
            ),
          ],
        ]),
      ),
    );
  }
}
