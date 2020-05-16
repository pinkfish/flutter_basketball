import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

///
/// Download the firebase storage image and show a placvehole
/// till it is downloaded.
///
class FirebaseStorageImage extends StatelessWidget {
  final String storageId;
  final PlaceholderWidgetBuilder placeholder;
  final LoadingErrorWidgetBuilder errorWidget;

  FirebaseStorageImage(
      {@required this.storageId, this.placeholder, this.errorWidget});

  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: FutureBuilder<Uint8List>(
          future: FirebaseStorage.instance
              .getReferenceFromUrl(this.storageId)
              .then((value) => value.getData(100000)),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              if (errorWidget != null) {
                return errorWidget(context, storageId, snapshot.error);
              }
              return Icon(Icons.error);
            }
            if (snapshot.hasData) {
              return Image.memory(snapshot.data);
            }
            if (placeholder != null) {
              return placeholder(context, storageId);
            }
            return Icon(Icons.image);
          },
        ));
  }
}
