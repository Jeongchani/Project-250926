
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';

/// First-run mode selector. After chosen once, app goes directly to that mode.
class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                onTap: () { app.chooseMode(AppMode.love); Navigator.pushReplacementNamed(context, '/love'); },
                child: Container(
                  width: double.infinity,
                  color: Colors.red.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite, size: 72, color: Colors.red),
                      SizedBox(height: 8),
                      Text('연애 모드', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () { app.chooseMode(AppMode.team); Navigator.pushReplacementNamed(context, '/team'); },
                child: Container(
                  width: double.infinity,
                  color: Colors.blue.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.campaign, size: 72, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('공지 모드(팀)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
