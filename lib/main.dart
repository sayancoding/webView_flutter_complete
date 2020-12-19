import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoad = true;
  bool isConnected = true;
  _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: isConnected
              ? Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      decoration: BoxDecoration(color: Colors.indigo),
                      child: SafeArea(
                          child: Center(
                              child: FutureBuilder<WebViewController>(
                                  future: _controller.future,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<WebViewController>
                                          controller) {
                                    if (controller.hasData) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                              icon: Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                              ),
                                              onPressed: () async {
                                                if (await controller.data
                                                    .canGoBack()) {
                                                  controller.data.goBack();
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              Text("Back")));
                                                } else {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "Have no way to back!")));
                                                }
                                              }),
                                          Text(
                                            isLoad ? "Loading.." : "E-HISAAB",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          IconButton(
                                              icon: Icon(
                                                Icons.refresh,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                controller.data.reload();
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content:
                                                            Text("Reloaded")));
                                              }),
                                        ],
                                      );
                                    }
                                  }))),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.88,
                            child: Stack(
                              children: [
                                WebView(
                                  // initialUrl: "https://www.google.com/",
                                  initialUrl:
                                      "http://ehisaab.netwizardinfotech.in/",
                                  javascriptMode: JavascriptMode.unrestricted,
                                  onWebViewCreated:
                                      (WebViewController webViewController) {
                                    _controller.complete(webViewController);
                                  },
                                  onPageStarted: (start) {
                                    setState(() {
                                      isLoad = true;
                                    });
                                  },
                                  onPageFinished: (finish) {
                                    setState(() {
                                      isLoad = false;
                                    });
                                  },
                                ),
                                isLoad
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Stack()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "You're offline now.\n\nPlease go back and connect\nwith internet.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        FlatButton(
                            onPressed: () {
                              exit(0);
                            },
                            child: Text("Exit"))
                      ],
                    ),
                  ),
                )),
    );
  }
}
