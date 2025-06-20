part of 'custom.dart';

class CustomImageNetworkWidget extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final bool showLoading;
  final Color? color;
  final String? imgAlt;
  const CustomImageNetworkWidget(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.showLoading = true,
    this.color,
    this.imgAlt,
  });

  Widget get errorImg => Icon(
        Icons.error,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    return (url.isEmpty || !showLoading)
        ? errorImg
        : Image.network(
            url,
            fit: fit,
            height: height,
            width: width,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  color: KColors.bcBlack,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return errorImg;
            },
          );
  }
}
