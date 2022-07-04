import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String youtubeId;
  final String publishedAt;
  final YoutubePlayerController controller;

  const VideoCard({Key? key, required this.title, required this.youtubeId, required this.publishedAt, required this.controller})
      : super(key: key);

  get _title {
    var myTitle = Text(title, style: GoogleFonts.inter(fontSize: 13));
    return Column(
        children: [myTitle]
    );
  }

  get _url {
    var imageUrl = "https://img.youtube.com/vi/$youtubeId/0.jpg";
    return Image(image: NetworkImage(imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Card(child: _cardContent),
        onTap: () => controller.cue(youtubeId),
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
