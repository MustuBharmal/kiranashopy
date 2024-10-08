import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:user/models/businessLayer/base.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/imageModel.dart';

class OpenImageDialog extends Base {
  final List<ImageModel>? imageList;
  final int? index;
  final String? name;

  OpenImageDialog({a, o, this.imageList, this.index, this.name}) : super(analytics: a, observer: o);
  @override
  OpenImageDialogState createState() => OpenImageDialogState(this.imageList, this.index, this.name);
}

class OpenImageDialogState extends BaseState {
  int? index;
  final List<ImageModel>? imageList;
  String? name;
  int? currentIndex = 0;
  PageController? pageController;
  OpenImageDialogState(this.imageList, this.index, this.name) : super();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          name != null && name!.isNotEmpty ? '$name' : '',
          style: textTheme.titleLarge,
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
          child: PhotoViewGallery.builder(
        customSize: Size(300, 300),
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider("${global.appInfo!.imageUrl}${imageList![index].image}"),
            initialScale: PhotoViewComputedScale.contained * 0.8,
          );
        },
        itemCount: imageList!.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 2,
              value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        pageController: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      )),
      bottomNavigationBar: imageList != null
          ? Container(
              height: 50,
              child: DotsIndicator(
                dotsCount: imageList!.length > 0 ? imageList!.length : 1,
                position: currentIndex!,
                onTap: (i) {
                  currentIndex = i.toInt();
                },
                decorator: DotsDecorator(
                  activeSize: const Size(6, 6),
                  size: const Size(6, 6),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    if (index != null) {
      pageController = new PageController(initialPage: index!);
      currentIndex = index;
    }
  }
}
