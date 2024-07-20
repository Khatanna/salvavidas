import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:logger/logger.dart';
import 'package:salvavidas/db/operation.dart';
import 'package:salvavidas/models/Contact.dart' as Contact;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact.Contact> _contacts = [];
  _getNewPhoneNumber() {
    FlutterContactPicker.pickPhoneContact().then((pick) async {
      final color = await showDialog<Color?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Seleciona el color del botón'),
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
                        width: 60,
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
                        width: 60,
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
                        width: 60,
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
                        width: 60,
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
        phone: pick.phoneNumber?.number ?? 'Sin número',
        buttonColor: color ?? Colors.red,
      );
      Operation.insertContact(contact);
      setState(() {
        _contacts = [..._contacts, contact];
      });
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
              }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(136, 39, 39, 1),
        onPressed: _getNewPhoneNumber,
        child: const Icon(Icons.person_add_alt, size: 30, color: Colors.white),
      ),
    );
  }
}
