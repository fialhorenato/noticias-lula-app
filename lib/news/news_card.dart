import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'news_view.dart';

class NewsCard extends StatelessWidget {
  final String description;
  final String title;
  final String url;
  final String publishedAt;
  final FirebaseAnalytics analytics;

  const NewsCard({Key? key,
    required this.description,
    required this.title,
    required this.url,
    required this.publishedAt,
    required this.analytics})
      : super(key: key);

  get _title {
    var myTitle = Text(title, style: GoogleFonts.inter(fontSize: 13));
    return Column(
        children: [myTitle]
    );
  }

  get _url {
    var favicon = "https://www.google.com/s2/favicons?domain=$url&sz=20";
    var date = DateTime.parse(publishedAt);
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    var timeAgo = timeago.format(date, locale: 'pt_BR');
    var timeAgoWidget = Text(timeAgo, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey));
    return Column(children: [
      Image(image: NetworkImage(favicon), height: 20),
      const SizedBox(height: 20),
      timeAgoWidget]);
  }

  @override
  Widget build(BuildContext context) {
    var webView = NewsView(title : title, url : url, analytics: analytics);
    return Card(
      child: InkWell(
        child: _cardContent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => webView),
          );
        }
      )
    );
  }

  get _cardContent {
    return Padding(
        padding: const EdgeInsets.all(10), child: _titleAndDescription);
  }

  get _titleAndDescription {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: _url,
            title: _title,
          )
        ]);
  }
}
