import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Gmap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double width;
  final double height;

  Gmap(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.width,
      required this.height});

  late final iframeUrl =
      "http://maps.google.com/maps?q=$latitude, $longitude&z=19&output=embed";

  late final errorNotifier = ValueNotifier(false);
  late final loadinNotifier = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    double oldWidth = this.width;
    final oldHeight = this.height;
    final width = this.width * MediaQuery.of(context).devicePixelRatio;
    final height = this.height * MediaQuery.of(context).devicePixelRatio;
    late final String futureHtml = '''
  "<!DOCTYPE html>
            <html>
            <head>
               
            </head>
            <body>
               
                <iframe src='$iframeUrl' width='$width' height='$height' frameborder='0' style='border:0' allowfullscreen></iframe>
            </body>
            </html>"    
            ''';
    late final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            loadinNotifier.value = false;
          },
          onWebResourceError: (WebResourceError error) =>
              errorNotifier.value = true,
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    controller.loadHtmlString(futureHtml);
    return ValueListenableBuilder(
        valueListenable: loadinNotifier,
        builder: (context, isLoading, child) => isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  color: Colors.white,
                  width: width,
                  height: oldHeight,
                ))
            : ValueListenableBuilder(
                valueListenable: errorNotifier,
                builder: (context, value, child) => !value
                    ? Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: WebViewWidget(controller: controller),
                          ),
                          Positioned.fill(
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      lauchGMapFromCoordinated(
                                          latitude, longitude);
                                    },
                                  )))
                        ],
                      )
                    : Container(
                        height: oldHeight,
                        width: oldWidth,
                        color: Colors.grey.shade50,
                      )));
  }
}
