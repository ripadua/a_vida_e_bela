import 'package:flutter/material.dart';
import 'package:a_vida_e_bela/services/authentication.dart';
import 'package:a_vida_e_bela/pages/root_page.dart';

class AVidaEBelaApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'A vida é bela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new Auth()));
  }
}