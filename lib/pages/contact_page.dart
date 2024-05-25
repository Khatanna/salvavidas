import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // late FullContact _contacts;

  // _getContacts() async {
  //   final contacts = await FlutterContactPicker.pickFullContact();
  //   setState(() {
  //     _contacts = contacts;
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: FlutterContactPicker.pickFullContact(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("cargando...");
            }

            return Text(snapshot.data.toString());
          }),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color.fromRGBO(136, 39, 39, 1),
      //   onPressed: _getNewPhoneNumber,
      //   child: const Icon(Icons.person_add_alt, size: 30, color: Colors.white),
      // ),
    );
  }
}
