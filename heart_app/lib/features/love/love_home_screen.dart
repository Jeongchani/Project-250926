
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/link_service.dart';
import 'widgets/heart_button.dart';

class LoveHomeScreen extends StatefulWidget {
  const LoveHomeScreen({super.key});

  @override
  State<LoveHomeScreen> createState() => _LoveHomeScreenState();
}

class _LoveHomeScreenState extends State<LoveHomeScreen> {
  final TextEditingController _msg = TextEditingController();

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  void _send(AppState app) {
    if (!app.lovePaired) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('아직 연결 전이에요. 상단 링크 아이콘으로 먼저 연결!')));
      return;
    }
    final text = (_msg.text.trim().isEmpty) ? app.loveSavedMessage : _msg.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('메시지가 비어 있어요. 설정에서 기본 메시지를 저장해 두면 편해요.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('보냈다고 가정 ✅  → "$text"')));
    _msg.clear();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    app.loveEnsureMyCode();
    return Scaffold(
      appBar: AppBar(
        title: const Text('연애 모드'),
        leading: IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: '모드 전환',
          onPressed: () { app.switchMode(); Navigator.pushReplacementNamed(context, app.mode == AppMode.love ? '/love' : '/team'); },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.link), onPressed: () => _showLinkSheet(context, app)),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () => _showAccountSheet(context, app)),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _showSettingsSheet(context, app)),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      app.lovePaired
                        ? '연결됨: ${app.lovePartnerName.isEmpty ? app.lovePartnerCode : app.lovePartnerName}'
                        : '아직 연결되지 않았어요',
                      style: TextStyle(color: app.lovePaired ? Colors.green : Colors.red),
                    ),
                    const SizedBox(height: 24),
                    Center(child: HeartButton(color: app.heartColor, onTap: () => _send(app))),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _msg,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: '하트 아래에 보일 문구(비워두면 저장된 메시지 사용)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: Text('저장된 메시지: "${app.loveSavedMessage}"')),
                    const SizedBox(height: 24),
                    Text(
                      '⚠️ 지금은 로컬 모드예요.\n실제 푸시는 백엔드/알림 연결 후 구현됩니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLinkSheet(BuildContext context, AppState app) {
    final myLink = LinkService.buildLoveInvite(app.loveMyCode, app.nickname);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('연결 링크 / 코드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText('코드: ${app.loveMyCode}'),
          const SizedBox(height: 8),
          SelectableText('링크: $myLink'),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.check), label: const Text('닫기')),
        ]),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, AppState app) {
    final hexCtrl = TextEditingController(text: _toHex(app.heartColor));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '닉네임'),
            controller: TextEditingController(text: app.nickname),
            onChanged: (v) => app.nickname = v,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '저장된 메시지'),
            controller: TextEditingController(text: app.loveSavedMessage),
            onChanged: (v) => app.loveSetSavedMessage(v),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('하트 색상 HEX  '),
            Expanded(child: TextField(
              controller: hexCtrl,
              onSubmitted: (v) { final c = _fromHex(v, app.heartColor); app.heartColor = c; hexCtrl.text = _toHex(c); },
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '#RRGGBB 또는 #AARRGGBB'),
            )),
          ]),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.check), label: const Text('닫기')),
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

  String _toHex(Color c) {
    final hex = c.value.toRadixString(16).padLeft(8, '0').toUpperCase(); // AARRGGBB
    return '#${hex.substring(2)}'; // RRGGBB
  }
  Color _fromHex(String s, Color fallback) {
    final v = s.trim().replaceAll('#', '');
    if (v.length == 6) return Color(int.parse('FF$v', radix: 16));
    if (v.length == 8) return Color(int.parse(v, radix: 16));
    return fallback;
  }
}
