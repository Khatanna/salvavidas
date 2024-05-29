import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:salvavidas/db/operation.dart';
import 'package:salvavidas/models/Contact.dart' as Contact;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact.Contact> _contacts = [];
  _getNewPhoneNumber() async {
    try {
      final PhoneContact pick = await FlutterContactPicker.pickPhoneContact();
      final contact = Contact.Contact(
          name: pick.fullName ?? "Sin nombre",
          phone: pick.phoneNumber?.number ?? 'Sin número');

      Operation.insertContact(contact);
      setState(() {
        _contacts = [..._contacts, contact];
      });
    } catch (e) {
      print(e);
    }
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
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 100, color: Colors.grey),
                Text('No hay contactos guardados',
                    style: TextStyle(fontSize: 20, color: Colors.grey)),
              ],
            ))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
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
                  onTap: _getNewPhoneNumber,
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
