
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../lib_services/local_store.dart';


const List<Color> kFreeColors = <Color>[
  Colors.pink, Colors.red, Colors.orange, Colors.amber,
  Colors.green, Colors.teal, Colors.blue, Colors.purple,
];

const List<Color> kPremiumColors = <Color>[
  Colors.pink, Colors.red, Colors.deepOrange, Colors.orange, Colors.amber, Colors.yellow,
  Colors.lime, Colors.lightGreen, Colors.green, Colors.teal, Colors.cyan,
  Colors.lightBlue, Colors.blue, Colors.indigo, Colors.purple, Colors.deepPurple,
  Colors.brown, Colors.grey, Colors.black,
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _savedMsg;
  late TextEditingController _hexCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _savedMsg = TextEditingController(text: app.savedMessage);
    _hexCtrl = TextEditingController(text: _toHex(app.heartColor));
  }

  @override
  void dispose() {
    _savedMsg.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  String _toHex(Color c) {
  // c.value => AARRGGBB, 8자리 안 되면 왼쪽을 '0'으로 채움
  final hex = c.value.toRadixString(16).padLeft(8, '0').toUpperCase(); // AARRGGBB
  return '#${hex.substring(2)}'; // 앞의 AA(알파) 잘라내고 RRGGBB만 사용
}

  Color _fromHex(String s, Color fallback) {
    final v = s.trim().replaceAll('#', '');
    if (v.length == 6) {
      return Color(int.parse('FF$v', radix: 16)); // opaque
    }
    if (v.length == 8) {
      return Color(int.parse(v, radix: 16));
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isPremium = app.premiumUnlocked;

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('닉네임', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: app.nickname),
            onChanged: (v) => app.setNickname(v),
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '상대에게 보일 이름'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('하트 색상', style: Theme.of(context).textTheme.titleMedium),
              if (!isPremium)
                ElevatedButton(
                  onPressed: () => app.unlockPremium(), // 광고/결제 자리
                  child: const Text('프리미엄 해제(임시)'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlockPicker(
                  pickerColor: app.heartColor,
                  availableColors: isPremium ? kPremiumColors : kFreeColors,
                  onColorChanged: (c) {
                    app.setHeartColor(c);
                    _hexCtrl.text = _toHex(c);
                  },
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('HEX'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _hexCtrl,
                        decoration: const InputDecoration(
                          hintText: '#RRGGBB 또는 #AARRGGBB',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (v) {
                          final c = _fromHex(v, app.heartColor);
                          app.setHeartColor(c);
                          _hexCtrl.text = _toHex(c);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('저장된 메시지', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _savedMsg,
            maxLines: 2,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '기본 메시지를 저장해 두세요'),
            onChanged: (v) => app.setSavedMessage(v),
          ),
          const SizedBox(height: 32),
          Text(
            '※ 프리미엄/광고 연동은 자리만 마련해 두었어요. 실제 광고 SDK나 결제는 이후에 붙이면 됩니다.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      ),
    );
  }
}
