import 'package:basketballdata/basketballdata.dart';
import 'package:cloud_functions/cloud_functions.dart';

///
/// Looks up and setups the broadcast in the cloud.
///
class MediaStreaming {
  final HttpsCallable _createApi = CloudFunctions.instance
      .getHttpsCallable(functionName: "httpCreatebroadcast")
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

  Future<Broadcast> getBroadcast(String uid) async {
    /*
    var createHttp = baseUrl.replace(path: "/LiveApp/rest/broadcast/get/$uid");
    var response = await _client.post(createHttp, body: '{"streamId":"$uid"}');
    return Broadcast.fromMap(json.decode(response.body));

     */
  }
}
