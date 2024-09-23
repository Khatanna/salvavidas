import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:logger/logger.dart';
import 'package:salvavidas/db/operation.dart';
import 'package:salvavidas/models/Contact.dart' as Contact;
import 'package:shared_preferences/shared_preferences.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact.Contact> _contacts = [];

  _getNewPhoneNumber(SharedPreferences prefs) async {
    final countryCode = prefs.getString('countryCode');
    if (countryCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectCountryCode),
        ),
      );
      return;
    }

    FlutterContactPicker.pickPhoneContact().then((pick) async {
      final color = await showDialog<Color?>(
        context: context,
        builder: (BuildContext context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final sizeByButton = (screenWidth - screenWidth * 0.45) / 4;
          return AlertDialog(
            title: Center(
              child: Text(
                AppLocalizations.of(context)!.selectButtonColor,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            content: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipOval(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(Colors.red);
                      },
                      child: Image.asset(
                        'assets/icons/security_red.png',
                        width: sizeByButton,
                      ),
                    ),
                  ),
                  ClipOval(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(Colors.yellow);
                      },
                      child: Image.asset(
                        'assets/icons/security_yellow.png',
                        width: sizeByButton,
                      ),
                    ),
                  ),
                  ClipOval(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(Colors.green);
                      },
                      child: Image.asset(
                        'assets/icons/security_green.png',
                        width: sizeByButton,
                      ),
                    ),
                  ),
                  ClipOval(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(Colors.blue);
                      },
                      child: Image.asset(
                        'assets/icons/security_blue.png',
                        width: sizeByButton,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final phone = pick.phoneNumber != null &&
              pick.phoneNumber!.number != null &&
              pick.phoneNumber!.number!.contains('+')
          ? pick.phoneNumber?.number
          : '$countryCode${pick.phoneNumber?.number}';

      final contact = Contact.Contact(
        name: pick.fullName ?? "Sin nombre",
        phone: '+${phone?.replaceAll(RegExp(r'[^\d]'), '')}',
        buttonColor: color ?? Colors.red,
      );
      Operation.insertContact(contact);
      setState(() {
        _contacts = [..._contacts, contact];
      });
    }).catchError((e) {
      Logger().e(e);
    });
  }

  _getContacts() {
    Operation.getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
      });
    });
  }

  _removeContact(int id) {
    Operation.deleteContact(id).then((value) {
      _getContacts();
    });
  }

  @override
  void initState() {
    super.initState();

    _getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contacts.isEmpty
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 100, color: Colors.grey),
                Text(AppLocalizations.of(context)!.emptyContacts,
                    style: const TextStyle(fontSize: 20, color: Colors.grey)),
              ],
            ))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _contacts[index].buttonColor,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(_contacts[index].name),
                  subtitle: Text(_contacts[index].phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _removeContact(_contacts[index].id!);
                        _contacts.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            final prefs = snapshot.data as SharedPreferences;

            return FloatingActionButton(
              backgroundColor: const Color.fromRGBO(136, 39, 39, 1),
              onPressed: () => _getNewPhoneNumber(prefs),
              child: const Icon(
                Icons.person_add_alt,
                size: 30,
                color: Colors.white,
              ),
            );
          }),
    );
  }
}
