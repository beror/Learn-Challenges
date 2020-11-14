import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

String address = "http://192.168.0.104:8085/PLanguages";
String receivedJWT;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server requests application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
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
                color: Colors.green,
                borderRadius: BorderRadius.circular(50)
              ),
              child: Text(
                "Get",
                style: TextStyle(fontSize: 30))
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PostFormRoute()));
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 4, 10, 10),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Text(
                    "Post",
                    style: TextStyle(fontSize: 30))
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PutFormRoute()));
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 4, 10, 10),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Text(
                    "Put",
                    style: TextStyle(fontSize: 30))
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteFormRoute()));
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 4, 10, 10),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Text(
                    "Delete",
                    style: TextStyle(fontSize: 30))
            ),
          )
        ],
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  createState() => LoginState();
}

class LoginState extends State<Login> {
  final loginFormKey_username = GlobalKey<FormState>();
  final loginFormKey_password = GlobalKey<FormState>();

  String username;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
        AppBar(
            title: Text("Log in")
        ),
        body: Column(
            children: [
              Form(
                  key: loginFormKey_username,
                  child: Padding(
                      child: TextFormField(
                          onSaved: (value) async {
                            username = value;
                          },
                          decoration: InputDecoration(hintText: "Username")
                      ),
                      padding: EdgeInsets.fromLTRB(35, 10, 35, 20)
                  )
              ),
              Form(
                  key: loginFormKey_password,
                  child: Padding(
                      child: TextFormField(
                        onSaved: (value) async {
                          password = value;
                        },
                        decoration: InputDecoration(hintText: "Password"),
                      ),
                      padding: EdgeInsets.fromLTRB(35, 10, 35, 0)
                  )
              ),
              Padding(
                  child: RaisedButton.icon(
                      icon: Icon(Icons.input, size: 40),
                      label: Text("Log in", style: TextStyle(fontSize: 40)),
                      onPressed: () async {
                        loginFormKey_username.currentState.save();
                        loginFormKey_password.currentState.save();

                        String postBody = "{"
                            "\"username\": \"$username\","
                            "\"password\": \"$password\""
                            "}";
                        print(postBody);
                        var response = await post("http://192.168.0.104:8085/login", body: postBody);
                        receivedJWT = response.headers["authorization"].split(" ").elementAt(1);
                        print("Received JWT: " + receivedJWT);
                        print(response.headers);
                        print(response.body);

                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                      },
                      color: Colors.white12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.fromLTRB(25, 20, 25, 20)
                  ),
                  padding: EdgeInsets.all(20)
              )
            ]
        )
    );
  }
}

class GetRoute extends StatelessWidget {
  int requestItemCount;
  var jsonDecodedBody;

  Future<Response> getGet() async {
    var response = await get(address, headers: {"Authorization": "Bearer " + receivedJWT});
    jsonDecodedBody = jsonDecode(response.body);
    requestItemCount = jsonDecodedBody.length;
    return response;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: getGet(),
    builder: (context, snapshot) {
      if(snapshot.hasData) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Get all entries")
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
              itemCount: jsonDecodedBody.length
            )
        );
      }
      else return Scaffold(appBar: AppBar(title: null), body: Center(child: CircularProgressIndicator()));
    }
  );
}

class PostFormRoute extends StatefulWidget {
  @override
  createState() => PostFormRouteState();
}

class PostFormRouteState extends State<PostFormRoute> {
  final postFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
        AppBar(
          title: Text("Post an entry")
        ),
      body: Column(
          children: [
            Form(
              key: postFormKey,
              child: Padding(
                  child: TextFormField(
                    onSaved: (value) async {
                    print(value);
                    String postBody = "{"
                        "\"name\": \"$value\""
                        "}";
                    var response = await post(address, body: postBody, headers: {"Authorization": "Bearer " + receivedJWT});
                    print(jsonDecode(response.body));
                    },
                  decoration: InputDecoration(hintText: "Language name")
                ),
                padding: EdgeInsets.fromLTRB(35, 10, 35, 0)
              )
            ),
            Padding(
              child: RaisedButton.icon(
                icon: Icon(Icons.add, size: 50),
                label: Text("Add", style: TextStyle(fontSize: 40)),
                onPressed: () {
                  postFormKey.currentState.save();
                },
                color: Colors.white12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.fromLTRB(25, 20, 25, 20)
              ),
              padding: EdgeInsets.all(20)
            )
          ]
      )
      );
  }
}

class PutFormRoute extends StatefulWidget {
  @override
  createState() => PutFormRouteState();
}

class PutFormRouteState extends State<PutFormRoute> {
  final putFormKeyIDToEdit = GlobalKey<FormState>();
  final putFormKeyID = GlobalKey<FormState>();
  final putFormKeyName = GlobalKey<FormState>();
  var jsonDecodedBody;

  var idToEdit;
  var idToChangeTo;
  var nameToChangeTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
        AppBar(
            title: Text("Put an entry")
        ),
        body: Column(
            children: [
              Form(
                  key: putFormKeyIDToEdit,
                  child: Padding(
                      child: TextFormField(
                          onSaved: (value) async {
                          idToEdit = value;
                          },
                          decoration: InputDecoration(hintText: "Current ID to be changed")
                      ),
                      padding: EdgeInsets.fromLTRB(35, 10, 35, 20)
                  )
              ),
              Form(
                  key: putFormKeyID,
                  child: Padding(
                      child: TextFormField(
                        onSaved: (value) async {
                        idToChangeTo = value;
                        },
                        decoration: InputDecoration(hintText: "ID to be changed to"),
                      ),
                      padding: EdgeInsets.fromLTRB(35, 10, 35, 0)
                  )
              ),
              Form(
                  key: putFormKeyName,
                  child: Padding(
                      child: TextFormField(
                        onSaved: (value) async {
                          nameToChangeTo = value;
                          },
                        decoration: InputDecoration(hintText: "Name to be changed to"),
                      ),
                      padding: EdgeInsets.fromLTRB(35, 10, 35, 0)
                  )
              ),
              Padding(
                  child: RaisedButton.icon(
                      icon: Icon(Icons.edit, size: 40),
                      label: Text("Edit", style: TextStyle(fontSize: 40)),
                      onPressed: () async {
                        putFormKeyIDToEdit.currentState.save();
                        putFormKeyID.currentState.save();
                        putFormKeyName.currentState.save();

                        String putBody = "{"
                            "\"id\": $idToChangeTo,"
                            "\"name\": \"$nameToChangeTo\""
                            "}";
                        print(putBody);
                        var response = await put(address + "/" + idToEdit, body: putBody, headers: {"Authorization": "Bearer " + receivedJWT});
                        print(response.body);
                      },
                      color: Colors.white12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.fromLTRB(25, 20, 25, 20)
                  ),
                  padding: EdgeInsets.all(20)
              )
            ]
        )
    );
  }
}

class DeleteFormRoute extends StatefulWidget {
  @override
  createState() => DeleteFormRouteState();
}

class DeleteFormRouteState extends State<DeleteFormRoute> {
  var deleteFormKey = GlobalKey<FormState>();

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delete an entry")),
      body: Column(
        children: [
          Form(
            key: deleteFormKey,
            child: Padding(
              child: TextFormField(
                  onSaved: (value) async {
                    var response = await delete(address + "/" + value, headers: {"Authorization": "Bearer " + receivedJWT});
                    print(response);
                    },
                  decoration: InputDecoration(hintText: "Language ID to delete")
              ),
                padding: EdgeInsets.fromLTRB(35, 10, 35, 0)
            )
          ),
          Padding(
              child: RaisedButton.icon(
                  icon: Icon(Icons.delete, size: 40),
                  label: Text("Delete", style: TextStyle(fontSize: 40)),
              onPressed: () => deleteFormKey.currentState.save(),
              color: Colors.white12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.fromLTRB(25, 20, 25, 20)
            ),
            padding: EdgeInsets.all(20)
          )
        ]
      )
    );
  }
}