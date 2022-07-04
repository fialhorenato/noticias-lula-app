import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:politic_news_app/client/api_client.dart';
import 'package:politic_news_app/domain/instagram_model.dart';

import '../news/news_view.dart';

class InstagramList extends StatefulWidget {
  final FirebaseAnalytics analytics;

  const InstagramList({Key? key, required this.analytics}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InstagramListState();
  }
}

class InstagramListState extends State<InstagramList> {
  final PagingController<int, InstagramModel> _pagingController =
      PagingController(firstPageKey: 0);

  static const _pageSize = 10;
  final ApiClient _apiClient = ApiClient();

  final BannerAd myBanner = BannerAd(
    adUnitId: "ca-app-pub-3018780392060907/6758101968",
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
      final newItems = await _apiClient.getInstagram(pageKey, _pageSize);
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
        )));
  }

  get _myBody {
    return Column(children: [Expanded(child: _newsList), _bannerAd]);
  }

  get _newsList {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PagedGridView<int, InstagramModel>(
          pagingController: _pagingController,
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          builderDelegate: PagedChildBuilderDelegate<InstagramModel>(
            itemBuilder: (context, item, index) =>
                itemBuilder(context, item, index),
          )),
    );
  }

  Widget itemBuilder(
      BuildContext context, InstagramModel instagramPost, int index) {
    var webView = NewsView(
        title: instagramPost.account,
        url: instagramPost.url,
        analytics: widget.analytics);
    var page = MaterialPageRoute(builder: (context) => webView);
    var image = Image(
        image: NetworkImage(
          instagramPost.imageUrl,
        ),
        loadingBuilder: _loadingBuilder,
        errorBuilder: _errorBuilder,
        );
    return InkWell(
        onTap: () {
          Navigator.of(context).popUntil((route) => true);
          Navigator.of(context).push(page);
        },
        child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(children: [
              Expanded(child: image),
              Text("@${instagramPost.account}")
            ])));
  }

  Widget _loadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Center(child: Image.network("https://play-lh.googleusercontent.com/h9jWMwqb-h9hjP4THqrJ50eIwPekjv7QPmTpA85gFQ10PjV02CoGAcYLLptqd19Sa1iJ"));
  }
}
