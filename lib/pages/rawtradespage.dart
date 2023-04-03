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
    String url =
        "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=tblRawFixMessages";
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    List<RawMessage> rawMessages = [];
    for (var message in responseData) {
      RawMessage rawMessage = RawMessage(
        id: message["id"],
        message: message["message"],
      );

      rawMessages.add(rawMessage);
    }
    return rawMessages;
  }

  @override
  Widget build(BuildContext context) {
    var headings = ["ID", "Message"];
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 83, 83, 83),
      ),
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
                  color: Color.fromARGB(255, 83, 83, 83),
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(6),
                    },
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 27, 27, 27),
                          ),
                          children: [
                            for (var heading in headings)
                              Center(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Text(
                                  heading,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )),
                          ]),
                      for (var message in snapshot.data)
                        TableRow(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 44, 44, 44),
                            ),
                            children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    message.id.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    message.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
