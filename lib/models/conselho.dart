import 'package:firebase_database/firebase_database.dart';

class Conselho {
  final String id;
  final String texto;

  Conselho.fromSnapshot(DataSnapshot snapshot) :
      id = snapshot.key,
      texto = snapshot.value['texto'];

}