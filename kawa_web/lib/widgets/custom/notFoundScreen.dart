part of 'custom.dart';

class NotFoundScreen extends StatelessWidget {
  final String? title;
  final String? content;
  const NotFoundScreen({this.title, this.content, super.key});

  void goStore() {
    AppNavigator.goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning,
                color: Colors.red,
                // KColors.bcRed,
                size: 80.0,
              ),
              const SizedBox(height: 16.0),
              CustomTextWidget(
                title ?? "Page Not Found",
                // ?? transT.,
                size: 18.sp,
                fontWeight: FontWeight.w900,
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: 30.w,
                child: CustomTextWidget(
                  content ?? "The page you are looking for does not exist.",
                  // transT.pageNotFoundContent,
                  size: 13.sp,
                  color: Colors.grey[600],
                  maxLines: 10,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  goStore();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.h,
                    vertical: 2.h,
                  ),
                  backgroundColor: Colors.blue,
                  // ZColors.bc,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      KConstant.radiusBigger,
                    ),
                  ),
                ),
                child: CustomTextWidget(
                  // transT.returnToHome,
                  "Return to Home",
                  color: Colors.grey.shade300,
                  // ZColors.bpWhite,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '© ${DateTime.now().year} Kawa.ai Inc. All right reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
