import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:politic_news_app/client/api_client.dart';
import 'package:politic_news_app/domain/tweet_model.dart';
import 'package:politic_news_app/tweet/tweet_card.dart';


class TweetList extends StatefulWidget {
  final FirebaseAnalytics analytics;
  const TweetList({Key? key, required this.analytics}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
     return TweetListState();
  }
}

class TweetListState extends State<TweetList> {
  final PagingController<int, TweetModel> _pagingController = PagingController(firstPageKey: 0);

  static const _pageSize = 20;
  final ApiClient _apiClient = ApiClient();

  final BannerAd myBanner = BannerAd(
    adUnitId: "ca-app-pub-3018780392060907/4463773822",
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
      final newItems = await _apiClient.getTweet(pageKey, _pageSize);
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
    return  Column(
      children: [
        Expanded(child: _tweetList),
        _bannerAd]
    );
  }

  get _tweetList {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
      ),
      child: PagedListView<int, TweetModel>(
        pagingController: _pagingController,
        physics: const AlwaysScrollableScrollPhysics() ,
        builderDelegate: PagedChildBuilderDelegate<TweetModel>(
            itemBuilder:itemBuilder
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, TweetModel tweet, int index) {
    return TweetCard(title: tweet.title, publishedAt: tweet.publishedAt, url: tweet.url, account: tweet.account, description: tweet.description, analytics:widget.analytics);
  }
}