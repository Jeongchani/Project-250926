import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'core/app_state.dart';
import 'core/local_store.dart';
import 'core/theme.dart';
import 'features/mode_select/mode_select_screen.dart';
import 'features/love/love_home_screen.dart';
import 'features/team/team_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.create();
  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  final LocalStore store;
  const MyApp({super.key, required this.store});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppState app;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    app = AppState(widget.store);
    _appLinks = AppLinks();

    // ✅ Handle initial + subsequent deep links in one stream
    _sub = _appLinks.uriLinkStream.listen((uri) {
      app.applyIncomingUri(uri);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Heart App',
        theme: buildTheme(app.heartColor),
        routes: {
          '/': (_) => const _EntryRouter(),
          '/love': (_) => const LoveHomeScreen(),
          '/team': (_) => const TeamHomeScreen(),
          '/mode': (_) => const ModeSelectScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}

/// Decides where to go on cold start based on saved mode choice.
class _EntryRouter extends StatelessWidget {
  const _EntryRouter(); //const _EntryRouter({super.key}) 잠시제거

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.modeChosen) {
      return const ModeSelectScreen();
    }
    return app.mode == AppMode.love
        ? const LoveHomeScreen()
        : const TeamHomeScreen();
  }
}
