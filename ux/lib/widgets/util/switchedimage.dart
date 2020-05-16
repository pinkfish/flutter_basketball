import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'firebasestorageimage.dart';

///
/// Figures out if this is a network image or a firestore imagena does the
/// right thing in loading it.
///
class SwitchedImage extends StatelessWidget {
  final String imageUrl;
  final PlaceholderWidgetBuilder placeholder;
  final LoadingErrorWidgetBuilder errorWidget;

  SwitchedImage({@required this.imageUrl, this.placeholder, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith("gs:")) {
      return FirebaseStorageImage(
        storageId: imageUrl,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
