import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아직 연결 전이에요. 상단 링크 아이콘으로 먼저 연결!')),
      );
      return;
    }
    final text = (_msg.text.trim().isEmpty) ? app.loveSavedMessage : _msg.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메시지가 비어 있어요. 설정에서 기본 메시지를 저장해 두면 편해요.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('보냈다고 가정 ✅  → "$text"')),
    );
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
          onPressed: () {
            app.switchMode();
            Navigator.pushReplacementNamed(context, app.mode == AppMode.love ? '/love' : '/team');
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.link), onPressed: () => _showLinkSheet(context, app)),
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- 연결 시트 (내 코드/링크 + 상대 코드 입력) ----------------
  void _showLinkSheet(BuildContext context, AppState app) {
    final myLink = LinkService.buildLoveInvite(app.loveMyCode, app.nickname);
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('연결 링크 / 코드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText('내 코드: ${app.loveMyCode}'),
            const SizedBox(height: 8),
            SelectableText('내 링크: $myLink'),
            const Divider(height: 28),
            const Text('상대 코드로 연결', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '상대가 보낸 코드 입력'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _connectByCode(context, app, codeCtrl.text.trim()),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _connectByCode(context, app, codeCtrl.text.trim()),
              icon: const Icon(Icons.link),
              label: const Text('코드로 연결'),
            ),
          ],
        ),
      ),
    );
  }

  void _connectByCode(BuildContext context, AppState app, String code) {
    if (code.isEmpty) return;
    app.loveSetPartner(code, '');
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('연결되었습니다!')));
  }

  // ---------------- 설정 시트 (색 변경 = 광고→티켓→피커) ----------------
  void _showSettingsSheet(BuildContext context, AppState app) {
    final nickCtrl = TextEditingController(text: app.nickname);
    final msgCtrl  = TextEditingController(text: app.loveSavedMessage);

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
            controller: nickCtrl,
            onChanged: (v) => app.nickname = v,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '저장된 메시지'),
            controller: msgCtrl,
            onChanged: (v) => app.loveSetSavedMessage(v),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _confirmAdThenOpenPicker(context, app),
                icon: const Icon(Icons.color_lens),
                label: const Text('색 변경'),
              ),
              const SizedBox(width: 12),
              Text('티켓: ${app.colorTickets}'),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.check), label: const Text('닫기')),
        ]),
      ),
    );
  }

  Future<void> _confirmAdThenOpenPicker(BuildContext context, AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('광고 시청'),
        content: const Text('광고를 시청하면 색 변경을 1회 할 수 있어요. 시청하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('예')),
        ],
      ),
    ) ?? false;

    if (!ok) return;

    // TODO: 여기서 google_mobile_ads 보상형 광고를 로드/표시하고,
    // 성공 콜백에서 아래 두 줄을 실행하세요.
    app.grantColorTicket();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('광고 보상 지급: 색 변경 티켓 +1')));

    _openColorPicker(context, app);
  }

  void _openColorPicker(BuildContext context, AppState app) {
    Color temp = app.heartColor;
    final hexCtrl = TextEditingController(text: _toHex(temp));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('색 선택 (드래그/클릭 가능)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // ✅ HSV 정사각형 팔레트 + Hue/Alpha 슬라이더가 포함된 피커
            ColorPicker(
              pickerColor: temp,
              onColorChanged: (c) { temp = c; hexCtrl.text = _toHex(c); },
              paletteType: PaletteType.hsvWithHue, // 정사각형 영역 + Hue 슬라이더
              enableAlpha: false, // 필요 시 true로 바꾸면 투명도 슬라이더도 생김
              displayThumbColor: true,
              pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
            ),

            const SizedBox(height: 12),
            Row(children: [
              const Text('HEX  '),
              Expanded(
                child: TextField(
                  controller: hexCtrl,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '#RRGGBB 또는 #AARRGGBB'),
                  onSubmitted: (v) {
                    final c = _fromHex(v, temp);
                    temp = c;
                    hexCtrl.text = _toHex(c);
                  },
                ),
              ),
            ]),

            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!app.consumeColorTicket()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('티켓이 없어요. 색 변경 전 광고를 시청해 주세요.')));
                      return;
                    }
                    app.heartColor = temp;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('색 변경 완료 ✅ (티켓 -1)')));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('적용(티켓 사용)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- HEX 유틸
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
