
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../lib_services/local_store.dart';
import '../lib_services/link_service.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  final TextEditingController _nick = TextEditingController();
  final TextEditingController _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _nick.text = app.nickname;
  }

  @override
  void dispose() {
    _nick.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final myCode = LinkService.ensureMyCode(app);
    final inviteUrl = LinkService.buildInviteUrl(app);

    return Scaffold(
      appBar: AppBar(title: const Text('커플 연결')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 닉네임', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nick,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '상대에게 보일 이름'),
              onChanged: (v) => app.setNickname(v),
            ),
            const SizedBox(height: 16),
            Text('내 초대 코드', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectableText(myCode, style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton(
                  onPressed: () => Share.share(inviteUrl, subject: 'Heart App 초대 링크'),
                  icon: const Icon(Icons.share),
                  tooltip: '링크 공유',
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('링크: $inviteUrl'),
            const Divider(height: 32),
            Text('상대 코드 붙여넣기', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _code,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '상대가 보낸 코드 입력'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_code.text.trim().isEmpty) return;
                    app.setPartnerCode(_code.text.trim());
                    app.setPaired(true);
                    app.finishOnboarding();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('연결되었습니다!')));
                  },
                  child: const Text('연결하기'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    app.finishOnboarding();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('나중에 하기'),
                )
              ],
            ),
            const Spacer(),
            Text(
              '💡 백엔드 없이 작동: 두 사람이 서로의 코드를 앱에 수동 입력하거나, heartapp:// 링크를 터치하면 자동 연결됩니다.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }
}
