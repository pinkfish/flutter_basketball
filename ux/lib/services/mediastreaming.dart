import 'package:basketballdata/basketballdata.dart';
import 'package:cloud_functions/cloud_functions.dart';

///
/// Looks up and setups the broadcast in the cloud.
///
class MediaStreaming {
  final HttpsCallable _createApi = CloudFunctions.instance
      .getHttpsCallable(functionName: "httpCreatebroadcast")
        ..timeout = const Duration(seconds: 20);
  final HttpsCallable _endApi = CloudFunctions.instance
      .getHttpsCallable(functionName: "httpEndbroadcast")
        ..timeout = const Duration(seconds: 20);
  final HttpsCallable _getApi = CloudFunctions.instance
      .getHttpsCallable(functionName: "httpGetbroadcast")
        ..timeout = const Duration(seconds: 20);

  MediaStreaming();

  Future<Broadcast> createBroadcast(Game g) async {
    print("Womble it up ${_createApi.toString()}");
    var result = await _createApi.call({
      'gameUid': g.uid,
      'teamUid': g.teamUid,
      'seasonUid': g.seasonUid,
    });
    print(result.data);
    var data = Broadcast.fromMap(Map<String, dynamic>.from(result.data));
    return data;
  }

  Future<Broadcast> endBroadcast(MediaInfo ev) async {
    print("Womble it up ${_createApi.toString()}");
    var result = await _endApi.call({
      'mediaInfoUid': ev.uid,
      'gameUid': ev.gameUid,
      'teamUid': ev.teamUid,
      'seasonUid': ev.seasonUid,
    });
    print(result.data);
    var data = Broadcast.fromMap(Map<String, dynamic>.from(result.data));
    return data;
  }

  Future<Broadcast> getBroadcast(MediaInfo ev) async {
    print("Womble it up ${_getApi.toString()}");
    var result = await _getApi.call({
      'mediaInfoUid': ev.uid,
      'gameUid': ev.gameUid,
      'teamUid': ev.teamUid,
      'seasonUid': ev.seasonUid,
    });
    print(result.data);
    var data = Broadcast.fromMap(Map<String, dynamic>.from(result.data));
    return data;
  }
}
