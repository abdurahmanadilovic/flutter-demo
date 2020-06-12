import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoopBackSample extends StatefulWidget {
  static String tag = 'loopback_sample';

  @override
  _MyAppState createState() => _MyAppState();
}

class Item {
  final String title;
  final String description;

  Item(this.title, this.description);
}

class Cart {
  final List<Item> items = List();

  addItem(Item item) {
    items.add(item);
  }

  removeItem(Item item) {
    items.remove(item);
  }
}

final _cart = Cart();

class _MyAppState extends State<LoopBackSample> {
  List<CameraDescription> cameras = List();
  CameraController controller;

  @override
  initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    setState(() {});
  }

  _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Expanded(
              child: Stack(
            children: <Widget>[
              WebView(
                initialUrl: "https://www.google.com",
                javascriptMode: JavascriptMode.unrestricted,
                onWebResourceError: (error) {
                  log("---- $error");
                },
              ),
              RaisedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Icon(Icons.remove))
            ],
          ));
        });
  }

  _openWebView() {
    Navigator.push(context, _createRoute());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Search example!'),
      ),
      body: Stack(
        children: <Widget>[
          if (controller != null) Expanded(child: CameraPreview(controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWebView,
        child: Icon(Icons.search),
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => BrowserScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class BrowserScreen extends StatefulWidget {
  @override
  _BrowserScreenState createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  WebViewController _webViewController;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add articles"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (!_loaded)
              Flexible(
                flex: 8,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Flexible(
              flex: 8,
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (page) {
                  log("page finished");
                  setState(() {
                    _loaded = true;
                  });
                },
                onWebViewCreated: (controller) {
                  controller.loadUrl("https://www.amazon.com");
                  _webViewController = controller;
                },
                onWebResourceError: (error) {
                  log('error $error');
                },
              ),
            ),
            RaisedButton(
              onPressed: () {
                _cart.addItem(Item("title", "description"));
                setState(() {});
              },
              child: Text("Add item to cart"),
            ),
            Flexible(
              flex: 2,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _cart.items
                    .map((item) => Container(
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(color: Colors.black45),
                          height: 100,
                          width: 60,
                          child: RaisedButton(
                            onPressed: () {
                              _cart.removeItem(item);
                              setState(() {});
                            },
                            child: Icon(Icons.remove),
                          ),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
