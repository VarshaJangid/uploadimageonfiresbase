import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Picker"),
      ),
      body: Container(
        child: imageFile == null
            ? Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.greenAccent,
                      onPressed: () {
                        _getFromGallery();
                      },
                      child: Text("PICK FROM GALLERY"),
                    ),
                    Container(
                      height: 40.0,
                    ),
                    RaisedButton(
                      color: Colors.lightGreenAccent,
                      onPressed: () {
                        _getFromCamera();
                      },
                      child: Text("PICK FROM CAMERA"),
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    height: 90,
                    width: 90,
                    child: imageFile != null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                              image: DecorationImage(
                                image: FileImage(imageFile!),
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                  ),
                  TextButton(
                      onPressed: () {
                        uploadImage(imageFile!);
                      },
                      child: Text("Upload"))
                ],
              ),
      ),
    );
  }
Future<String> uploadImage(File image) async {
  String imageUrl;
  try {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('newsImage/${basename(image.path)}');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    print("Task Snapshot State ------- ${snapshot.state}");
    if (snapshot.state == TaskState.success) {
      imageUrl = await snapshot.ref.getDownloadURL();
      print("Image Url ------ $imageUrl");
      return imageUrl;
    } else {
      print("Error in Task Snapshot State ");
      return '';
    }
  } catch (error) {
    print("Error In Upload Image on Firebase $error");
    return '';
  }
}
  /// Get from gallery
  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
}
