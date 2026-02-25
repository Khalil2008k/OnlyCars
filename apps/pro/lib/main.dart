import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_ui/oc_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await OcSupabase.init(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://wfzwrcqpjrzqpgawiess.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_rhKJKH0_O6iojpAOSw97Yw_wnDBczgX',
    ),
  );

  runApp(const ProviderScope(child: OnlyCarsProApp()));
}

class OnlyCarsProApp extends ConsumerWidget {
  const OnlyCarsProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(proRouterProvider);

    return MaterialApp.router(
      title: 'OnlyCars Pro',
      debugShowCheckedModeBanner: false,
      theme: OcTheme.light,
      darkTheme: OcTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
