import 'dart:io';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/localstoragedata.dart';
import 'package:basketballstats/services/sqldbraw.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class _UploadTask {
  final UploadData data;
  final StorageUploadTask task;

  _UploadTask(this.data, this.task);
}

class UploadFilesBackground {
  List<_UploadTask> _data = [];
  final Uuid uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});
  final Box<Map<String, dynamic>> box;

  UploadFilesBackground() : box = Hive.box(LocalStorageData.uploadsBox) {
    // Wait till we get a database, then load everything.
    var uploads = box.values.map((d) => UploadData.fromMap(d)).toList();
    _restartUploads(uploads);
  }

  void _restartUploads(List<UploadData> uploads) async {
    // Restart the uploads, first see if the uploaded file matches what
    // we think it should.
    for (var u in uploads) {
      // See if the file even exists.
      try {
        var f = File(u.localPath);
        var st = await f.stat();
        var md = await FirebaseStorage().ref().child(u.gcsPath).getMetadata();
        if (md.sizeBytes != st.size) {
          // Do the upload.
          var task = FirebaseStorage().ref().child(u.gcsPath).putFile(
              f,
              StorageMetadata(customMetadata: {
                'gameUid': u.gameUid,
                'videoUid': u.videoUid,
              }));
          var data = _UploadTask(u, task);
          _data.add(data);
        } else {
          // Delete.
          _doRemoval(u);
        }
      } catch (FileNotFoundException) {
        // No file any more, delete it too.
        _doRemoval(u);
      }
    }
  }

  Future<void> addUploadTask(
      String path, String gameUid, String videoUid) async {
    var f = File(path);
    var uploadPath = "$gameUid/${videoUid}_upload.mp4";
    var task = FirebaseStorage().ref().child(uploadPath).putFile(
        f,
        StorageMetadata(customMetadata: {
          'gameUid': gameUid,
          'videoUid': videoUid,
        }));
    var data = _UploadTask(
        UploadData((b) => b
          ..gameUid = gameUid
          ..videoUid = videoUid
          ..gcsPath = uploadPath
          ..localPath = path
          ..uid = uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.uploadTable)),
        task);
    task.onComplete.then((value) => _doRemoval(data.data));
    _data.add(data);
    box.put(data.data.uid, data.data.toMap());
  }

  Future<void> _doRemoval(UploadData data) {
    _data.remove(data);
    box.delete(data.uid);
    return null;
  }
}
