import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/l10n/l10n.dart';
import 'package:salvavidas/pages/contact_page.dart';
import 'package:salvavidas/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:salvavidas/pages/login_page.dart';
import 'package:salvavidas/pages/settings_page.dart';
import 'package:salvavidas/pages/sync_page.dart';
import 'package:salvavidas/pages/term_and_conditions_page.dart';
import 'package:salvavidas/provider/auth_provider.dart';
import 'package:salvavidas/provider/lang_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LangProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _selectedIndex = 0;

  final Map<int, String> _routes = {
    0: '/home',
    1: '/contacts',
    2: '/map',
    3: '/sync',
    4: '/settings',
    // 5: '/terms'
  };

  void _onItemTapped(int index) {
    if (index == 2) {
      Geolocator.getCurrentPosition().then((location) {
        final String url =
            'https://www.google.com/maps?q=${location.latitude.toString()},${location.longitude.toString()}';
        launchUrlString(url);
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]!);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/header_banner.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
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
                        ),
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
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      const String url = 'https://www.gottret.com/salvavidas/';
                      launchUrlString(url);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.public,
                          color: Color.fromRGBO(136, 39, 39, 1),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.web,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () => {
                      authProvider.logout().then((value) {
                        context.go('/login');
                      })
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Color.fromRGBO(136, 39, 39, 1),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.logout,
                        ),
                      ],
                    ),
                  ),
                ];
              },
              child: const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        unselectedFontSize: 10,
        backgroundColor: const Color.fromRGBO(136, 39, 39, 1),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: AppLocalizations.of(context)!.contacts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.map,
              color: Colors.white,
            ),
            label: AppLocalizations.of(context)!.myLocation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
            ),
            label: AppLocalizations.of(context)!.sync,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LangProvider>(
      builder: (context, value, child) {
        return SafeArea(
          child: MaterialApp.router(
            routerConfig: _createRouter(context),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(136, 39, 39, 1),
              ),
              useMaterial3: true,
            ),
            supportedLocales: L10n.all,
            locale: value.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        );
      },
    );
  }

  GoRouter _createRouter(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
          redirect: (context, state) {
            if (authProvider.isAuth) {
              return state.fullPath;
            }

            return null;
          },
        ),
        ShellRoute(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          redirect: (context, state) {
            if (!authProvider.isAuth) {
              return '/login';
            }

            return null;
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/contacts',
              builder: (context, state) => const ContactPage(),
            ),
            GoRoute(
              path: '/sync',
              builder: (context, state) => const SyncPage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: '/terms',
              builder: (context, state) => const TermAndConditionsPage(),
            ),
          ],
        ),
      ],
    );
  }
}
