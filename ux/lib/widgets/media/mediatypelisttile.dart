import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/util/switchedimage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mediatypeicon.dart';

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
                  ? SwitchedImage(
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
