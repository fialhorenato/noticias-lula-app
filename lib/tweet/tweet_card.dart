
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../news/news_view.dart';

class TweetCard extends StatelessWidget {
  final String title;
  final String url;
  final String account;
  final String description;
  final String publishedAt;
  final FirebaseAnalytics analytics;

  const TweetCard(
      {Key? key,
        required this.title,
        required this.publishedAt,
        required this.url,
        required this.account,
        required this.description,
        required this.analytics}
      ) : super(key: key);

  get _title {
    var myTitle = Text(title, style: GoogleFonts.inter(fontSize: 13));
    return Column(
        children: [myTitle]
    );
  }
  get _leading {
    var twitterUrl = "https://www.twitter.com";
    var favicon = "https://www.google.com/s2/favicons?domain=$twitterUrl&sz=1024";
    var date = DateTime.parse(publishedAt);
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    var timeAgo = timeago.format(date, locale: 'pt_BR');
    var timeAgoWidget = Text(timeAgo, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey));
    var userWidget = Text("@$account", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey));
    return Column(children: [
      Image(image: NetworkImage(favicon)),
      userWidget,
      timeAgoWidget
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var webView = NewsView(title : title, url : url, analytics: analytics);
    var page = MaterialPageRoute(builder: (context) => webView);
    return InkWell(
        child: Card(child: _cardContent),
        onTap: () {
          Navigator.of(context).popUntil((route) => true);
          Navigator.of(context).push(page);
        }
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
            leading : _leading,
            title: _title,
          )
        ]);
  }


}
