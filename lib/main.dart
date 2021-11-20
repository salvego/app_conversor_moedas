import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
          hintColor: Colors.blue,
          primaryColor: Colors.blue,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            hintStyle: TextStyle(color: Colors.blue),
          ),
      ),
    ),
  );
}

Future<Map?> getData() async {
  http.Response response = await http.get(
      Uri.parse("https://api.hgbrasil.com/finance?format=json-cors&key=SUA_KEY_AQUI"));
  return json.decode(response.body);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double dolar = 0;
  double euro = 0;

  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  void _clearAll(){
    realControler.text = "";
    dolarControler.text = "";
    euroControler.text = "";
  }

  void _realChanged(String text){

    if(text.isEmpty){
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarControler.text = (real / dolar).toStringAsFixed(2);
    euroControler.text = (real / euro).toStringAsFixed(2);

  }
  void _dolarChanged(String text){

    if(text.isEmpty){
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realControler.text = (dolar * this.dolar).toStringAsFixed(2);
    euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(2);

  }
  void _euroChanged(String text){

    if(text.isEmpty){
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realControler.text = (euro * this.euro).toStringAsFixed(2);
    dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("\$ Conversor de Moedas \$"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map?>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error ao Carregar Dados...",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 32,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.blue,
                        ),
                        buildTextField("Reais", "R\$ ", realControler, _realChanged),
                        Divider(),
                        buildTextField("Dolares", "US\$ ", dolarControler, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€ ", euroControler, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String)? function){
  return TextField(
    controller: controller,
    onChanged: function,
    style: TextStyle(
      color: Colors.blue,
      fontSize: 25.0,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.blue,
      ),
      border: OutlineInputBorder(),
      prefix: Text(prefix),
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
