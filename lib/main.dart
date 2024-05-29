import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/l10n/l10n.dart';
import 'package:salvavidas/pages/contact_page.dart';
import 'package:salvavidas/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:salvavidas/pages/settings_page.dart';
import 'package:salvavidas/pages/term_and_conditions_page.dart';
import 'package:salvavidas/provider/lang_provider.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const MyHomePage(),
    routes: [
      GoRoute(
        path: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
          path: 'terms',
          builder: (context, state) => const TermAndConditionsPage()),
    ],
  ),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => LangProvider())],
      child: SafeArea(
        child: Builder(
          builder: (context) => MaterialApp.router(
            title: 'Salvavidas',
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            supportedLocales: L10n.all,
            locale: Provider.of<LangProvider>(context).locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  final screens = const [ContactPage(), HomePage(), SettingsPage()];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/icons/header_banner.png'),
              fit: size > 600 ? BoxFit.fitWidth : BoxFit.cover,
            ),
          ),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: () => context.go('/settings'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.settings,
                      color: Color.fromRGBO(136, 39, 39, 1),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.settings,
                    )
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => context.go('/terms'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.question_mark_outlined,
                      color: Color.fromRGBO(136, 39, 39, 1),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.help,
                    )
                  ],
                ),
              )
            ],
            child: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(
              size: 50,
              Icons.person,
              color: Color.fromRGBO(136, 39, 39, 1),
            ),
            label: AppLocalizations.of(context)!.contacts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.home,
              size: 50,
              color: Color.fromRGBO(136, 39, 39, 1),
            ),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              size: 50,
              Icons.settings,
              color: Color.fromRGBO(136, 39, 39, 1),
            ),
            label: AppLocalizations.of(context)!.settings,
          )
        ],
      ),
    );
  }
}
