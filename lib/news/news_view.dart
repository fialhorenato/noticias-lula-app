import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsView extends StatelessWidget {

  final String title;
  final String url;
  final FirebaseAnalytics analytics;

  const NewsView({Key? key, required this.title, required this.url, required this.analytics}) : super(key: key);

  Future<void> share() async {
    await FlutterShare.share(
        title: title,
        text: "Olha que notícia legal sobre o Lula!",
        linkUrl: url
    );
  }

  @override
  Widget build(BuildContext context) {

    analytics.logScreenView(
      screenName: url,
      screenClass: "WebView",
    );

    WebView.platform = AndroidWebView();

    var navigationDelegate = Uri.parse(url).host == "www.instagram.com" ? NavigationDecision.navigate : NavigationDecision.prevent;
    var icon = GestureDetector(
      child: const Icon(Icons.share),
      onTap: () => share(),
    );
    var appBar = AppBar(
        title: Text(title),
        actions: [icon],
    );
    return Scaffold(
      appBar: appBar,
      body: WebView(
          initialUrl: url,
          navigationDelegate: (request) => navigationDelegate,
          javascriptMode: JavascriptMode.unrestricted),
    );
  }

}