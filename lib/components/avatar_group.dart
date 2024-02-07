import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webrtc_client/apis/me.dart';
import 'package:webrtc_client/apis/upload.dart';
import 'package:webrtc_client/main.dart';

class AvatarGroup extends StatefulWidget {
  final String authToken;

  const AvatarGroup({required this.authToken, super.key});

  @override
  State<StatefulWidget> createState() {
    return _AvatarGroup();
  }
}

class _AvatarGroup extends State<AvatarGroup> {
  void showError(Object err) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(err.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            "http://${Config.backendDomain}/apis/v1/me/avatar",
            headers: {"X-Auth-Token": widget.authToken},
          ),
        ),
        ElevatedButton(
            onPressed: () {
              final picker = ImagePicker();
              picker.pickImage(source: ImageSource.camera).then((image) {
                if (image != null) {
                  image.readAsBytes().then((bytes) {
                    upload(widget.authToken, image.name, bytes).then(
                        (id) => upsertAvatar(
                                    authToken: widget.authToken, uploadID: id)
                                .then((_) {
                              setState(() {});
                            }, onError: (err) => showError(err)),
                        onError: (err) => showError(err));
                  }, onError: (err) => showError(err));
                }
              });
            },
            child: const Text("Update avatar"))
      ],
    );
  }
}
