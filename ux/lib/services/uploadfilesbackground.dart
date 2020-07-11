import 'dart:convert';
import 'dart:io';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/sqldbraw.dart';
import 'package:built_collection/built_collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class _UploadTask {
  final UploadData data;
  final StorageUploadTask task;

  _UploadTask(this.data, this.task);
}

class UploadFilesBackground {
  List<_UploadTask> _data = [];
  SQLDBRaw _sql;
  final Uuid uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});

  UploadFilesBackground(this._sql) {
    // Wait till we get a database, then load everything.
    _sql.getDatabase().then((db) async {
      var data = await db.query(SQLDBRaw.uploadTable);
      var uploads = BuiltList<UploadData>.from(data
          .map((Map<String, dynamic> e) =>
              UploadData.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
          .toList());
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
            _doRemoval(u, db);
          }
        } catch (FileNotFoundException) {
          // No file any more, delete it too.
          _doRemoval(u, db);
        }
      }
    });
  }

  Future<void> addUploadTask(
      String path, String gameUid, String videoUid) async {
    var f = File(path);
    var uploadPath = "$gameUid/${videoUid}_upload.mp4";
    var db = await _sql.getDatabase();
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
    await db.insert(SQLDBRaw.uploadTable, {
      SQLDBRaw.indexColumn: data.data.uid,
      SQLDBRaw.dataColumn: json.encode(data.data.toMap()),
    });
    task.onComplete.then((value) => _doRemoval(data.data, db));
    _data.add(data);
  }

  Future<void> _doRemoval(UploadData data, Database db) {
    _data.remove(data);
    return db
        .delete(SQLDBRaw.uploadTable, where: "uid = ?", whereArgs: [data.uid]);
  }
}
