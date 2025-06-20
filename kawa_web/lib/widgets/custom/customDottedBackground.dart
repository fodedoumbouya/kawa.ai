part of 'custom.dart';

class DottedBackground extends StatelessWidget {
  final Color backgroundColor;
  final Color dotColor;
  final Widget child;

  const DottedBackground({
    super.key,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.dotColor = const Color(0xFFE0E0FF),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        backgroundBlendMode: BlendMode.src,
      ),
      child: CustomPaint(
        painter: DotsPainter(dotColor: dotColor),
        child: child,
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  final Color dotColor;

  DotsPainter({
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const double spacing = 40; // Space between dots
    const double radius = 1.5; // Size of dots

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
