
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lib_services/local_store.dart';
import '../widgets/heart_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _msg = TextEditingController();

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  void _send(AppState app) {
    if (!app.paired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아직 커플 연결 전이에요. 링크/코드로 먼저 연결해 주세요.')),
      );
      return;
    }
    final text = (_msg.text.trim().isEmpty) ? app.savedMessage : _msg.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메시지가 비어 있어요. 설정에서 기본 메시지를 저장해 두면 편해요.')),
      );
      return;
    }
    // 실제 전송 대신 로컬 피드백만
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('보냈다고 가정 ✅  → "$text"')),
    );
    _msg.clear();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart App'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/link'),
            icon: const Icon(Icons.link),
            tooltip: '커플 연결',
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings),
            tooltip: '설정',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              app.paired
                  ? '연결됨: ${app.partnerName.isEmpty ? app.partnerCode : app.partnerName}'
                  : '아직 연결되지 않았어요',
              style: TextStyle(color: app.paired ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 24),
            Center(
              child: HeartButton(
                color: app.heartColor,
                onTap: () => _send(app),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msg,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '하트 아래에 보일 문구(비워두면 저장된 메시지 사용)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('저장된 메시지: "${app.savedMessage}"'),
            ),
            const Spacer(),
            Text(
              '⚠️ 지금은 로컬 모드예요.\n실제 푸시는 백엔드/알림 연결 후 구현됩니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
