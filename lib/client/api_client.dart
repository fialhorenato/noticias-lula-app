import 'dart:convert';

import 'package:politic_news_app/domain/instagram_model.dart';
import 'package:politic_news_app/domain/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:politic_news_app/domain/tweet_model.dart';
import 'package:politic_news_app/domain/video_model.dart';

class ApiClient {

  final String _baseUrl = "https://politic-news-api.herokuapp.com/";
  //final String _baseUrl = "http://localhost:8080/";

  Future<List<NewsModel>> getNews(int? page,int? size) async {
    var path = "v1/news";

    if (page != null && size != null) {
      path = "$path?page=$page&size=$size";
    }

    var url = Uri.parse(_baseUrl + path);
    var response = await http.get(url);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var newsJson = decodedResponse['content'] as List;

    var myList = newsJson
        .map(_transformNewsModel)
        .toList();

    return Future.value(myList);
  }

  Future<List<VideoModel>> getVideo(int? page,int? size) async {
    var path = "v1/video";

    if (page != null && size != null) {
      path = "$path?page=$page&size=$size";
    }

    var url = Uri.parse(_baseUrl + path);
    var response = await http.get(url);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var newsJson = decodedResponse['content'] as List;

    var myList = newsJson
        .map(_transformVideoModel)
        .toList();

    return Future.value(myList);
  }

  Future<List<TweetModel>> getTweet(int? page,int? size) async {
    var path = "v1/tweet";

    if (page != null && size != null) {
      path = "$path?page=$page&size=$size";
    }

    var url = Uri.parse(_baseUrl + path);
    var response = await http.get(url);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var newsJson = decodedResponse['content'] as List;

    var myList = newsJson
        .map(_transformTweetModel)
        .toList();

    return Future.value(myList);
  }

  Future<List<InstagramModel>> getInstagram(int? page,int? size) async {
    var path = "v1/instagram-post";

    if (page != null && size != null) {
      path = "$path?page=$page&size=$size";
    }

    var url = Uri.parse(_baseUrl + path);
    var response = await http.get(url);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var newsJson = decodedResponse['content'] as List;

    var myList = newsJson
        .map(_transformInstagramModel)
        .toList();

    return Future.value(myList);
  }

  NewsModel _transformNewsModel(e) {
    return NewsModel(e['title'], e['description'], e['url'], e['published_at']);
  }

  VideoModel _transformVideoModel(e) {
    return VideoModel(e['title'], e['youtube_id'], e['published_at']);
  }

  TweetModel _transformTweetModel(e) {
    return TweetModel(e['title'], e['url'], e['account'], e['description'], e['published_at']);
  }

  InstagramModel _transformInstagramModel(e) {
    return InstagramModel(e['url'], e['image_url'], e['account'], e['published_at']);
  }
}