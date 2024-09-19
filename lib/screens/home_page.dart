import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/categories/add.dart';
import 'package:note_app/screens/login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QueryDocumentSnapshot> date = [];
  bool isLooging = true;
  //Function to get data from firebase for a user logedin
  getDate() async {
    FirebaseFirestore.instance
        .collection('categories')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        date.add(doc);
      }
      isLooging = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddCategory()));
        },
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Note App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.orange,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                //When sign in with google, to sign out must disconnect with the google account.
                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.disconnect();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: isLooging
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: date.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onLongPress: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.rightSlide,
                      title: 'Delete Category',
                      desc: 'Are you sure you want to delete it?',
                      btnCancelOnPress: () {},

                      //This is Function to delete spacific doc from firebase
                      btnOkOnPress: () async {
                        await FirebaseFirestore.instance
                            .collection('categories')
                            .doc(date[index].id)
                            .delete();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const HomePage()));
                      },
                    ).show();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          Image.asset(
                            'images/folder.png',
                            height: 120,
                          ),
                          //We reach to data with key name (keys in map)
                          Text(date[index]['name'])
                        ],
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
