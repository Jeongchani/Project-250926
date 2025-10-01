import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'lib_services/local_store.dart';
import 'lib_services/link_service.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/link_screen.dart';

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
  late final AppState appState;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    appState = AppState(widget.store);
    _appLinks = AppLinks();

    // 초기 링크 + 이후 들어오는 링크 모두 이 스트림에서 처리
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => LinkService.applyIncomingUri(appState, uri),
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Heart App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: appState.heartColor),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const MainScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/link': (_) => const LinkScreen(),
        },
        initialRoute: appState.onboarded ? '/' : '/link',
      ),
    );
  }
}
