import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:politic_news_app/client/api_client.dart';
import 'package:politic_news_app/domain/video_model.dart';
import 'package:politic_news_app/video/video_card.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class VideoList extends StatefulWidget {
  final FirebaseAnalytics analytics;
  const VideoList({Key? key, required this.analytics}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
     return VideoListState();
  }
}

class VideoListState extends State<VideoList> {
  final PagingController<int, VideoModel> _pagingController = PagingController(firstPageKey: 0);

  final YoutubePlayerController controller = YoutubePlayerController(
    params: const YoutubePlayerParams(
      showControls: true,
      showFullscreenButton: true,
      enableJavaScript: true,
      autoPlay: false
    ), initialVideoId: '',
  );

  static const _pageSize = 20;
  final ApiClient _apiClient = ApiClient();

  final BannerAd myBanner = BannerAd(
    adUnitId: "ca-app-pub-3018780392060907/8021898974",
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  get _videoPlayer {
    return YoutubePlayerIFrame(
      controller: controller,
      aspectRatio: 16 / 9,
    );
  }

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
      final newItems = await _apiClient.getVideo(pageKey, _pageSize);
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
    
    if (_pagingController.value.itemList != null && pageKey == 0) {
      var firstVideoId = _pagingController.value.itemList![0].youtubeId;

      if (firstVideoId != "jSOVyhaymvg") {
        controller.cue(firstVideoId);
      }
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
        _videoPlayer,
        Expanded(child: _newsList),
        _bannerAd]
    );
  }

  get _newsList {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
      ),
      child: PagedListView<int, VideoModel>(
        pagingController: _pagingController,
        physics: const AlwaysScrollableScrollPhysics() ,
        builderDelegate: PagedChildBuilderDelegate<VideoModel>(
            itemBuilder:itemBuilder
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, VideoModel video, int index) {
    return VideoCard(title: video.title, youtubeId: video.youtubeId, publishedAt: video.publishedAt, controller: controller);
  }
}