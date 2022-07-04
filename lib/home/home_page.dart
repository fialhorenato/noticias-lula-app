import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:politic_news_app/instagram/instagram_list.dart';
import 'package:politic_news_app/news/news_list.dart';

import '../tweet/tweet_list.dart';
import '../video/video_list.dart';

class HomePage extends StatefulWidget {
  final FirebaseAnalytics analytics;

  const HomePage(this.analytics, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();
  var _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    var newsPage = NewsList(analytics: widget.analytics, scrollController: scrollController);
    var videoPage = VideoList(analytics : widget.analytics);
    var tweetPage = TweetList(analytics : widget.analytics);
    var instagramList = InstagramList(analytics: widget.analytics);
    var pages = [newsPage, videoPage, tweetPage, instagramList];

    var scaffold = Scaffold(
      appBar: _appBar(scrollController, _selectedIndex),
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: _bottomNavigationBar(pages),
    );

    return scaffold;
  }

  _bottomNavigationBar(List<Widget> pages) {
    var items = [
      const BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.rss), label: "Notícias"),
      const BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.youtube), label: "Vídeos"),
      const BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.twitter), label: "Tweets"),
      const BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.instagram), label: "Instagram")
    ];

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex : _selectedIndex,
        onTap: _onTapBottomBar,
        items: items);
  }

  void _onTapBottomBar(int index) {
    setState(() {
      Navigator.of(context).popUntil((route) => true);
      _selectedIndex = index;
    });
  }
}

_appBar(ScrollController scrollController, selectedIndex) {
  var actions = [ GestureDetector(
      child: const Icon(Icons.arrow_circle_up, color: Colors.white),
      onTap: () => {
        if (scrollController.hasClients) scrollController.jumpTo(0)
      }
  )];

  return AppBar(
      backgroundColor: Colors.red,
      actions: selectedIndex == 0 ? actions : [],
      leading: const Icon(Icons.star, color: Colors.white,),
      centerTitle: true,
      title: Text(
          "Notícias Lula",
          style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
      )
  );
}