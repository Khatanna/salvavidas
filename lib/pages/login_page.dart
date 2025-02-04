import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/provider/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

const Set<String> _kIds = <String>{
  '01salvavidas',
};

class _LoginPageState extends State<LoginPage> {
  bool _policy = false;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> loadPurchases() async {
    final ctx = context;
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      return;
    }

    showDialog(
      context: ctx,
      builder: (context) => FutureBuilder(
        future: InAppPurchase.instance.queryProductDetails(_kIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data as ProductDetailsResponse;

          products.productDetails.sort((a, b) {
            return a.price.compareTo(b.price);
          });

          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.subscriptions,
              style: const TextStyle(fontSize: 20),
            ),
            scrollable: true,
            content: Column(
              children: [
                for (var (index, product) in products.productDetails.indexed)
                  ListTile(
                    onTap: () {
                      InAppPurchase.instance.buyNonConsumable(
                        purchaseParam: PurchaseParam(
                          productDetails: product,
                          applicationUserName: 'salvavidas.user',
                        ),
                      );
                    },
                    leading: Image.asset(
                      index == 0
                          ? 'assets/icons/security_red.png'
                          : index == 1
                              ? 'assets/icons/security_yellow.png'
                              : index == 2
                                  ? 'assets/icons/security_green.png'
                                  : 'assets/icons/security_blue.png',
                    ),
                    title: Text(
                      index == 0
                          ? '(Salvavidas) 3 meses'
                          : index == 1
                              ? '(Salvavidas) 6 meses'
                              : index == 2
                                  ? '(Salvavidas) 1 año'
                                  : '1 Semana de prueba',
                      style: const TextStyle(fontSize: 12, fontFamily: 'arial'),
                      locale: Localizations.localeOf(context),
                    ),
                    subtitle: Text(
                      product.price,
                      style: const TextStyle(fontSize: 12, fontFamily: 'arial'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  _showPendingUI() {
    Logger().i('showPendingUI');
  }

  _handleError(IAPError error) {
    Logger().e('Error: ${error.message}');
  }

  _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final bool valid = await _verifyPurchase(purchaseDetails);
    return valid;
  }

  _deliverProduct(PurchaseDetails purchaseDetails) {
    Logger().i('deliverProduct');
  }

  _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    Logger().e('handleInvalidPurchase');
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription.cancel(),
      onError: (error) => Logger().e('Error: $error'),
    );
    SharedPreferences.getInstance().then((prefs) {
      final snackContext = ScaffoldMessenger.of(context);
      if (prefs.getBool('policy') == null || prefs.getBool('policy') == false) {
        snackContext.showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar los términos y condiciones'),
          ),
        );
        return;
      }

      setState(() {
        _policy = prefs.getBool('policy') ?? false;
      });
    });
    loadPurchases();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(132, 26, 30, 1),
                Color.fromRGBO(136, 39, 39, 1),
                Color.fromRGBO(183, 14, 33, 1),
                Color.fromRGBO(216, 3, 25, 1),
                Color.fromRGBO(228, 0, 26, 1)
              ]),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              fit: BoxFit.cover,
              'assets/icons/logo-out-bg.png',
              width: screenWidth / 2,
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Salvavidas",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SignInButton(
              Buttons.google,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              text: "Iniciar sesión",
              padding: const EdgeInsets.only(left: 15, right: 15),
              onPressed: () async {
                final snackContext = ScaffoldMessenger.of(context);
                final prefs = await SharedPreferences.getInstance();

                if (prefs.getBool('policy') == null ||
                    prefs.getBool('policy') == false) {
                  snackContext.showSnackBar(
                    const SnackBar(
                      content: Text('Debes aceptar los términos y condiciones'),
                    ),
                  );
                  return;
                }

                authProvider.signInWithGoogle().then((value) {
                  context.go('/home');
                });
              },
            ),
            const SizedBox(
              height: 40,
            ),
            RadioListTile(
              title: Text(
                AppLocalizations.of(context)!.acceptTerms,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              toggleable: true,
              fillColor: WidgetStateProperty.all(Colors.white),
              value: _policy ? 1 : 0,
              groupValue: 1,
              onChanged: (value) async {
                setState(() {
                  _policy = !_policy;
                });
                final prefs = await SharedPreferences.getInstance();

                prefs.setBool('policy', value != null);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                launchUrlString('https://gottret.com/salvavidas/sample-page/');
              },
              child: Text(
                AppLocalizations.of(context)!.showTerms,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
