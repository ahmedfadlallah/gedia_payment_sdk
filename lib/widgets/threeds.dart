import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart' as webviewf;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';

class ThreeDSPage extends StatefulWidget {
  final String? html;
  final String? returnURL;

  const ThreeDSPage(this.html, this.returnURL, {Key? key}) : super(key: key);

  @override
  _ThreeDSPageState createState() => _ThreeDSPageState();
}

class _ThreeDSPageState extends State<ThreeDSPage> {
  late WebViewController controller;


  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('',
          onMessageReceived: (javaMessage){

          },

      )..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (webviewf.NavigationRequest request) {
          print('allowing navigation to $request');
          if (request.url.startsWith(widget.returnURL ?? "")) {
            // Navigator.of(context).pop();
            return webviewf.NavigationDecision.prevent;
          }
          return webviewf.NavigationDecision.navigate;
        },

      ))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView is loading (progress : $progress%)');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebResourceError: $error');

            if (Platform.isIOS) {
              Navigator.of(context).pop();
            }
          },
          onPageStarted: (String url) {
            print('Page started loading: $url, ${widget.returnURL}');
            if (url.startsWith(widget.returnURL ?? "")) {
              Navigator.of(context).pop();
            }
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            // if (url.startsWith(widget.returnURL)) {
            //   Navigator.of(context).pop();
            // }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

  }

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("3DS")),
      body: Builder(builder: (BuildContext context) {
        return WebViewWidget(
          controller: controller,
        );
      }),

    );
  }



}
