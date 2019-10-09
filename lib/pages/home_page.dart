import 'dart:math';

import 'package:a_vida_e_bela/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = new GlobalKey<FormState>();

  String _number;
  String _errorMessage;
  String _advice;

  TextEditingController _controllerNumber = TextEditingController();

  bool _isLoading;
  bool _isFavorite = false;
  int _maxValue = 0;
  
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      try {

        if (_number.isEmpty) {
          var rng = new Random();
          _number = rng.nextInt(_maxValue + 1).toString();
        }

        // Buscar conselho no Firebase
        Query _conselhoQuery = _database
            .reference()
            .child("conselhos/" + _number);

        _conselhoQuery.once().then((snapshot) async {
          setState(() {
            _controllerNumber.text = '';
            if (snapshot.value != null) {
              _advice = snapshot.value['texto'];
            } else {
              _errorMessage = 'Não foi possível encontrar conselho para o número informado.';
              _number = "";
              _advice = "";
            }
            FocusScope.of(context).requestFocus(FocusNode());
          });
        }).catchError((error) {
          setState(() {
            _errorMessage = error.toString();
          });
        });

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }

  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _advice = "";
    _number = "";
    _isLoading = false;
    Query _lastQuery = _database
        .reference()
        .child("conselhos")
        .orderByKey()
        .limitToLast(1);

    _lastQuery.once().then((snapshot) async {
      setState(() {
        _maxValue = int.parse(snapshot.value.keys.first);
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('A vida é bela (ou não)'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Logout',
                style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: _signOut,
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress(),
        ],
      ),
    );
  }

    Widget _showCircularProgress() {
      if (_isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      return Container(height: 0.0, width: 0.0,);
    }

    Widget _showBody() {
      return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showNumberInput(),
              _showPrimaryButton(),
              _showErrorMessage(),
              _showAdviceText(),
            ],
          ),
        ),
      );
    }

    Widget _showErrorMessage() {
      if (_errorMessage.length > 0 && _errorMessage != null) {
        return new Padding(
          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: new Center(
            child: new Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      } else {
        return new Container(
          height: 0.0,
        );
      }
    }

    Widget _showLogo() {
      return new Hero(
        tag: 'hero',
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 48.0,
            child: Image.asset('assets/avidaebela-icon.jpg'),
          ),
        ),
      );
    }

    Widget _showNumberInput() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: new TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.number,
          autofocus: true,
          controller: _controllerNumber,
          validator: (value) => value.isNotEmpty && int.parse(value) > _maxValue ? 'Uai, eu falei até ' + _maxValue.toString() + "!!!" : null,
          onSaved: (value) => _number = value.trim(),
          decoration: InputDecoration(
            hintText: 'Informe um número entre 0 e ' + _maxValue.toString() + ". Ou não!" ,

          ),
        ),
      );
    }

    Widget _showPrimaryButton() {
      return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text(
              'Me fala alguma coisa',
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            onPressed: _validateAndSubmit,
          ),
        ),
      );
    }

    Widget _showAdviceText() {
      if (_advice.length > 0 && _advice != null) {
        return new Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(_advice),
                      trailing: _isFavorite ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border),
                      onTap: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                    ),
                  ],
                ),
              ),

            )
        );
      } else {
        return new Container(
          height: 0.0,
        );
      }
    }
  }
