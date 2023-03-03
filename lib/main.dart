import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'confirmation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyWidget(),
          ],
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => new Size.fromHeight(50);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Doctolib',
        style: GoogleFonts.nunito(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {

  List _dataList = [];

  @override
  void initState() {
    super.initState();
    _getDataFromFirestore();
  }

  void _getDataFromFirestore() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Doctor').get();
    List dataList = querySnapshot.docs
        .map((documentSnapshot) => documentSnapshot.data())
        .toList();

    setState(() {
      _dataList = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white10,
      child: Column(
        children: [
          Text(
            'Choose your doctor:',
            style: GoogleFonts.nunito(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          Container(
            child: Column(
              children: _dataList.map((doctor) {
                return DoctorCard(doctor);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map doctorData;
  DoctorCard(this.doctorData);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  doctorData['Name'],
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  doctorData['Place'],
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Confirmation(doc: doctorData)),
                    );
                  },
                  child: const Text('Prendre RDV'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
