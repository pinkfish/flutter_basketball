import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

///
/// Shows the media type as a nice icon.
///
class MediaTypeIcon extends StatelessWidget {
  final MediaType type;

  MediaTypeIcon(this.type);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MediaType.Image:
        return Icon(Icons.image);
      case MediaType.VideoOnDemand:
        return Icon(Icons.ondemand_video);
      case MediaType.VideoStreaming:
        return Icon(Icons.videocam);
    }
    return Icon(Icons.error);
  }
}
