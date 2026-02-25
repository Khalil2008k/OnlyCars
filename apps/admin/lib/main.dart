import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_ui/oc_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: OnlyCarsAdminApp()));
}

class OnlyCarsAdminApp extends StatelessWidget {
  const OnlyCarsAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlyCars Admin',
      debugShowCheckedModeBanner: false,
      theme: OcTheme.dark,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AdminShell(),
    );
  }
}
