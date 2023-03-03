import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_field/date_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Confirmation extends StatelessWidget {
  const Confirmation({super.key, required this.doc});
  final doc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddEventPage(doc),
          ],
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => new Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Prenez votre rendez-vous',
        style: GoogleFonts.nunito(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.grey[800],
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

class AddEventPage extends StatefulWidget {
  final doc;
  AddEventPage(this.doc);

  @override
  State<AddEventPage> createState() => _AddEventPageStat();
}

class _AddEventPageStat extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  DateTime _date = DateTime.now();
  final commentController = TextEditingController();

  final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('Patient');

  Future<void> addAppointment(String firstName, String lastName, DateTime date, String comment) {
    // Ajoutez un document à la collection users
    return appointmentsCollection
        .add({
      'firstName': firstName,
      'lastName': lastName,
      'Doctor': {
        'Name': widget.doc['Name'],
        'Place': widget.doc['Place']
      },
      'Date': date,
      'Comment': comment
    })
        .then((value) => Navigator.pop(context))
        .catchError((error) => print('Erreur lors de l\'ajout du rdv : $error'));
  }

  @override
  void dispose(){
    super.dispose();

    lastNameController.dispose();
    firstNameController.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(20),
      child:Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entre ton nom',
                  border: OutlineInputBorder()
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Tu dois completer ce texte";
                  }
                  return null;
                },
                controller: lastNameController,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prenom',
                  hintText: 'Entre ton prenom',
                  border: OutlineInputBorder()
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Tu dois completer ce texte";
                  }
                  return null;
                },
                controller: firstNameController,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Commentaire',
                    hintText: 'Description de ton problème',
                    border: OutlineInputBorder()
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Tu dois completer ce texte";
                  }
                  return null;
                },
                controller: commentController,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: DateTimeFormField(
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.black45),
                  errorStyle: TextStyle(color: Colors.redAccent),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.event_note),
                  labelText: 'Choisir une date',
                ),
                firstDate: DateTime.now(),
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez choisir une date.';
                  }
                  return null;
                },
                onDateSelected: (DateTime value) {
                  setState(() {
                    _date = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()){
                    final lastName = lastNameController.text;
                    final firstName = firstNameController.text;
                    final comment = commentController.text;

                    _formKey.currentState!.save();

                    addAppointment(firstName, lastName, _date, comment);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Envoi en cours..."))
                    );
                    FocusScope.of(context).requestFocus(FocusNode());
                  }
                },
                child: Text("Envoyer")
              ),
            )
          ],
        )
      ),   
    );
  }
}