import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/screens/home_page.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController name = TextEditingController();
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  Future<void> addCategory() {
    // Call the user's CollectionReference to add a new user
    if (formKey.currentState!.validate()) {
      return categories.add({
        'name': name.text,
        'id': FirebaseAuth.instance.currentUser!.uid
      }).then((value) {
        print("Category Added");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false);
      }).catchError((error) => print("Failed to add category: $error"));
    } else {
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Category is empty',
        desc: 'Please Enter name to category',
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.orange,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  validator: (value) {
                    if (value == "") {
                      return 'Can not be empty';
                    }
                    return null;
                  },
                  controller: name,
                  decoration: InputDecoration(
                      hintText: 'Category Name',
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 20),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 184, 184, 184))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.grey))),
                ),
              )),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  addCategory();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
                child: const Text('Add'),
              ))
        ],
      ),
    );
  }
}
