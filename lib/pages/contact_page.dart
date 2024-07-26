import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:salvavidas/db/operation.dart';
import 'package:salvavidas/models/Contact.dart' as Contact;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:country_code_picker/country_code_picker.dart' show codes;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact.Contact> _contacts = [];
  String? _locale;
  _getNewPhoneNumber() {
    if (_locale == null) {
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
      final contact = Contact.Contact(
        name: pick.fullName ?? "Sin nombre",
        phone:
            '$_locale${pick.phoneNumber?.number?.replaceAll(_locale ?? '', '')}',
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _getCountryCodeFromLocation(position.latitude, position.longitude);
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> _getCountryCodeFromLocation(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String? countryCode = place.isoCountryCode;
        if (countryCode != null) {
          final code = codes.firstWhere((element) {
            return element['code'] == countryCode;
          })['dial_code'];

          setState(() {
            _locale = code;
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.noCountryCode),
              ),
            );
          });
        }
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noCountryCode),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _getContacts();
    _getCurrentLocation();
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
              }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(136, 39, 39, 1),
        onPressed: _getNewPhoneNumber,
        child: Builder(builder: (context) {
          if (_locale == null) {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            );
          }
          return const Icon(
            Icons.person_add_alt,
            size: 30,
            color: Colors.white,
          );
        }),
      ),
    );
  }
}
