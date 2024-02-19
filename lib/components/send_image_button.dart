import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:webrtc_client/apis/chat_message.dart';
import 'package:webrtc_client/blocs/chat.dart';

class SendImageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final messages = BlocProvider.of<ChatMessagesCubit>(context);
    return IconButton(
        onPressed: () {
          showBottomSheet(
              context: context,
              builder: (context) {
                return ListView(
                  children: [
                    ListTile(
                        title: const Text("Camera"),
                        onTap: () {
                          Navigator.of(context).pop();
                          ImagePicker()
                              .pickImage(source: ImageSource.camera)
                              .then((image) {
                            if (image == null) {
                              return;
                            }
                            image.readAsBytes().then((bs) {
                              final mimeType =
                                  lookupMimeType(image.path, headerBytes: bs);
                              if (mimeType == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "cannot detect MIME type of selected image")));
                              }
                              messages.pushMessage(
                                  mimeType: mimeType!,
                                  content: base64Encode(bs));
                            });
                          });
                        }),
                    ListTile(
                        title: const Text("Libaray"),
                        onTap: () {
                          Navigator.of(context).pop();
                          ImagePicker().pickMultiImage().then((images) {
                            if (images.isEmpty) {
                              return;
                            }
                            for (final image in images) {
                              image.readAsBytes().then((bs) {
                                final mimeType =
                                    lookupMimeType(image.path, headerBytes: bs);
                                if (mimeType == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "cannot detect MIME type of selected image")));
                                }
                                messages.pushMessage(
                                    mimeType: mimeType!,
                                    content: base64Encode(bs));
                              });
                            }
                          });
                        }),
                  ],
                );
              });
        },
        icon: const Icon(Icons.image));
  }
}
