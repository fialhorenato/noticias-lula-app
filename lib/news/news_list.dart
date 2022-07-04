import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:politic_news_app/client/api_client.dart';
import 'package:politic_news_app/domain/news_model.dart';

import 'news_card.dart';

class NewsList extends StatefulWidget {
  final ScrollController scrollController;
  final FirebaseAnalytics analytics;

  const NewsList({Key? key, required this.scrollController, required this.analytics}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
     return NewsListState();
  }
}

class NewsListState extends State<NewsList> {
  final PagingController<int, NewsModel> _pagingController = PagingController(firstPageKey: 0);

  static const _pageSize = 20;
  final ApiClient _apiClient = ApiClient();

  final BannerAd myBanner = BannerAd(
    adUnitId: "ca-app-pub-3018780392060907/6746785259",
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );



  @override
  void initState() {
    myBanner.load();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _apiClient.getNews(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => _myBody;

  get _bannerAd {
    return SizedBox(
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
        child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width + 30,
              height: myBanner.size.height.toDouble(),
              child: AdWidget(ad: myBanner),
            )
        )
    );
  }

  get _myBody {
    widget.analytics.logScreenView(screenClass: "NewsList", screenName: "NewsList");
    return  Column(
      children: [

        Expanded(child: _newsList),
        _bannerAd]
    );
  }

  get _newsList {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
      ),
      child: PagedListView<int, NewsModel>(
        scrollController: widget.scrollController,
        pagingController: _pagingController,
        physics: const AlwaysScrollableScrollPhysics() ,
        builderDelegate: PagedChildBuilderDelegate<NewsModel>(
            itemBuilder:itemBuilder
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, NewsModel news, int index) {
    return NewsCard(description: news.description, title: news.title, url: news.url, publishedAt: news.publishedAt, analytics: widget.analytics,);
  }
}