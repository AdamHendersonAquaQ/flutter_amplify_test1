import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../classes/rawmessage.dart';

class RawTradesPage extends StatefulWidget {
  const RawTradesPage({super.key});

  @override
  State<RawTradesPage> createState() => _RawTradesState();
}

class _RawTradesState extends State<RawTradesPage> {
  Future<List<RawMessage>> getRequest() async {
    //replace your restFull API here.
    String url =
        "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=tblRawFixMessages";
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    //Creating a list to store input data;
    List<RawMessage> rawMessages = [];
    for (var message in responseData) {
      RawMessage rawMessage = RawMessage(
        id: message["id"],
        message: message["message"],
      );

      //Adding user to the list.
      rawMessages.add(rawMessage);
    }
    return rawMessages;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: FutureBuilder(
            future: getRequest(),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(6),
                    },
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      const TableRow(children: [
                        Text('ID'),
                        Text('Message'),
                      ]),
                      for (var message in snapshot.data)
                        TableRow(children: [
                          Text(message.id.toString()),
                          Text(message.message),
                        ]),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      )),
    );
  }
}
