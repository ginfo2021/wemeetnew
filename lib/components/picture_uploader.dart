import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:path_provider/path_provider.dart' as path;
import 'dart:math';
import 'dart:io';

import 'package:wemeet/components/loader.dart';

import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/services/user.dart';

class PictureUploader extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<String> onDone;
  final String type;
  final double right;
  final double left;
  final double radius;

  const PictureUploader(
      {Key key,
      this.imageUrl,
      @required this.onDone,
      this.radius = 50.0,
      this.right = 0.0,
      this.left = 0.0,
      @required this.type})
      : super(key: key);

  @override
  _PictureUploaderState createState() => _PictureUploaderState();
}

class _PictureUploaderState extends State<PictureUploader> {
  bool isLoading = false;

  final picker = ImagePicker();

  String _remoteUrl;
  String _localUrl;

  @override
  void initState() {
    super.initState();

    _remoteUrl = widget.imageUrl;
  }

  bool get isEmpty {
    return _remoteUrl == null && _localUrl == null;
  }

  void _upload() async {
    setState(() {
      isLoading = true;
    });

    try {
      var res = await UserService.postPhoto(_localUrl, widget.type);

      print(res);
      setState(() {
        _remoteUrl = res["data"]["imageUrl"];
      });

      widget.onDone(_remoteUrl);
    } catch (e) {
      print(e);
      setState(() {
        _localUrl = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<File> _compressImage(String filePath) async {
    final _dir = await path.getTemporaryDirectory();
    final file = File(
        "${_dir.absolute.path}//Image_${DateTime.now().millisecondsSinceEpoch}.jpg");
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      file.absolute.path,
      quality: 70,
    );

    return result;
  }

  void _longPress() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (isEmpty || isLoading) return;

    var del = await WeMeetLoader.showBottomModalSheet(context, "Delete Photo",
            content: "Are you sure you want to delete this photo?",
            okText: "Yes, delete",
            cancelText: "Cancel") ??
        false;

    if (del) {
      setState(() {
        _localUrl = _remoteUrl = null;
      });
      widget.onDone(null);
    }
  }

  void _tap() async {
    FocusScope.of(context).requestFocus(FocusNode());

    ImageSource source = await showSelect();

    if (source == null) {
      return;
    }

    // pick image and upload
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile == null) {
      return;
    }

    // compress image
    File cFile = await _compressImage(pickedFile.path);
    //File cFile = await _cropImage(pickedFile.path);

    if (cFile == null) {
      return;
    }

    setState(() {
      _localUrl = cFile.path;
    });

    // upload file
    _upload();
  }

  /// Crop Image
  Future<Null> _cropImage(filePath) async {
    /*File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        maxWidth: 1080,
        maxHeight: 1080,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));*/
    //if (croppedImage != null) {
    //imageFile = croppedImage ;

    /*---Compression Start ----*/
    final _dir = await path.getTemporaryDirectory();
    final file = File(
        "${_dir.absolute.path}//Image_${DateTime.now().millisecondsSinceEpoch}.jpg");
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      file.absolute.path,
      quality: 70,
    );

    setState(() {});
    return result;
    /*----------END-----------*/

    //}
  }

  Future<ImageSource> showSelect() async {
    ImageSource val = await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        builder: (context) => Container(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose Image From...",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 45.0,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, ImageSource.gallery);
                      },
                      icon: Icon(FeatherIcons.image),
                      label: Text(
                        "Gallery",
                        style: TextStyle(color: AppColors.color1),
                      ),
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xfff2f2f2))),
                      // textColor: ,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 45.0,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, ImageSource.camera);
                      },
                      icon: Icon(FeatherIcons.camera),
                      label: Text(
                        "Camera",
                        style: TextStyle(color: AppColors.color1),
                      ),
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xfff2f2f2))),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20.0)
                ],
              ),
            ));

    return val;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap,
      onLongPress: _longPress,
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        width: widget.radius * 2,
        height: widget.radius * 2,
        margin: EdgeInsets.only(right: widget.right, left: widget.left),
        decoration: BoxDecoration(
          color: Color(0xfff0e5fe),
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Stack(
          children: [
            // show + if empty
            if (isEmpty)
              Center(
                  child: Icon(FeatherIcons.plus,
                      size: max(16.0, widget.radius * 0.5),
                      color: AppColors.color1)),

            // if local url is present
            if (_localUrl != null /*&& _remoteUrl == null*/)
              Positioned.fill(
                child: Image.file(
                  File(_localUrl),
                  fit: BoxFit.cover,
                ),
              ),

            // if remote url is present
            if (_remoteUrl != null)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: _remoteUrl,
                  placeholder: (context, u) => Center(
                    child: SpinKitFadingCircle(
                      color: Colors.white,
                      size: max(widget.radius, 25.0),
                    ),
                  ),
                  errorWidget: (context, s, d) => Center(
                    child: Icon(FeatherIcons.alertCircle),
                  ),
                  fit: BoxFit.cover,
                ),
              ),

            // if not ready yet
            if (_remoteUrl == null && !isEmpty)
              Positioned.fill(
                  child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
              )),

            // if progress is not done
            if (isLoading)
              Center(
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: max(widget.radius, 35.0),
                ),
              )
          ].where((e) => e != null).toList(),
        ),
      ),
    );
  }
}
