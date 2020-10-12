import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server requests application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests")
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () {
              //GetRoute.getGet();
              Navigator.push(context, MaterialPageRoute(builder: (context) => GetRoute()));
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 4, 10, 10),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(50)
              ),
              child: Text(
                "Get",
                style: TextStyle(fontSize: 30))
            ),
          )
        ],
      ),
    );
  }
}

class GetRoute extends StatelessWidget {
  int requestItemCount;
  var jsonDecodedBody;
  Future<Response> getGetFuture() async {
    var response = await get('http://192.168.0.105:8085/PLanguages');
    jsonDecodedBody = jsonDecode(response.body);
    requestItemCount = jsonDecodedBody.length;
    return response;
    /*List<dynamic> responseBody = jsonDecode(response.body);
    responseBody.forEach((element) {
      print(element.forEach((key, value) {
        print("$element:");
        print("Key: $key");
        print("Value: $value");
        print("Key type: ${key.runtimeType}");
        print("Value type: ${value.runtimeType}");
      }));
    });*/
  }
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: getGetFuture(),
    builder: (context, snapshot) {
      if(snapshot.hasData) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Get")
            ),
            body: ListView.builder(
                itemBuilder: (_, i) {
                  return Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            child: ListView.builder(
                              itemBuilder: (_, j) {
                                  return Text("${jsonDecodedBody[i].keys.elementAt(j)}: ${jsonDecodedBody[i].values.elementAt(j)}", style: TextStyle(fontSize: 20));
                              },
                              itemCount: jsonDecodedBody[0].keys.length,
                              shrinkWrap: true
                            ),
                            width: 390,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10)
                              )
                            ),
                          )
                        ]
                      )
                    ],
                  );
                },
              itemCount: jsonDecodedBody.length,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
            )
        );
      }
      else return Text("Loading");
    }
  );
}