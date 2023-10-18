import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoView extends StatefulWidget {
  final String photoUrl;

  const FullPhotoView({super.key, required this.photoUrl});

  @override
  State<FullPhotoView> createState() => _FullPhotoViewState();
}

class _FullPhotoViewState extends State<FullPhotoView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(widget.photoUrl),
      ),
    );
  }
}
