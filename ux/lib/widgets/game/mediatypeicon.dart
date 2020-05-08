import 'package:basketballdata/basketballdata.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

///
/// List tile to show all the details about the media type.
///
class MediaTypeListTile extends Card {
  static DateFormat format = DateFormat.yMd().add_jm();

  MediaTypeListTile({@required MediaInfo media, GestureTapCallback onTap})
      : super(
          child: ListTile(
            title: Text(format.format(media.startAt)),
            subtitle: Text(media.description),
            leading: MediaTypeIcon(media.type),
            trailing: SizedBox(
              width: 40.0,
              height: 40.0,
              child: media.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: media.thumbnailUrl.toString(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : const Icon(Icons.play_arrow),
            ),
            onTap: onTap,
          ),
        );
}
