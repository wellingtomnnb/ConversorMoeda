import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=b049b976";

void main() async {
  runApp(MaterialApp(home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));

}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
Widget buildTextFiel(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold é um widged que permite colocar a barra superior(onde fica o nome do aplicativo ou da tela..)
      backgroundColor: Colors.black,
      appBar: AppBar(
          //AppBar é a barra superior propriamente dita
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            //snapshot = situação atual dos dados
            switch (snapshot.connectionState) {
              //verifica o status da conexão
              case ConnectionState
                  .none: //caso não esteja conectado ou esteja aguardando
              case ConnectionState.waiting:
                return Center(
                    //Center=widged que centraliza outro widged
                    child: Text("Carregando Dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));
              default:
                if (snapshot.hasError) {
                  return Center(
                      //Center=widged que centraliza outro widged
                      child: Text("Erro ao Carregar Dados :(",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, //alinhamento central
                        children: [
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextFiel("Real", "R\$ ", realController, _realChanged),
                          Divider(),
                          buildTextFiel("Dólar", "US\$ ", dolarController, _dolarChanged),
                          Divider(),
                          buildTextFiel("Euro", "€ ", euroController, _euroChanged)
                    ],
                  ));
                }
            }
          }),
    );
  }
}

