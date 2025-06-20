part of 'custom.dart';

enum FeatureSectionStatus {
  loading,
  done,
  fail,
  none,
}

class FeatureSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> cards;
  final bool showConnector;
  final FeatureSectionStatus status;

  const FeatureSection({
    super.key,
    required this.title,
    required this.icon,
    required this.cards,
    required this.showConnector,
    this.status = FeatureSectionStatus.none,
  });

  @override
  Widget build(BuildContext context) {
    Widget w;
    Color connectorColor = Colors.grey.shade300;
    Color txtColor = Colors.black87;
    switch (status) {
      case FeatureSectionStatus.loading:
        w = SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
        );
        txtColor = Colors.blue;
        break;
      case FeatureSectionStatus.done:
        w = Icon(
          Icons.check,
          size: 20,
          color: Colors.blue,
        );
        connectorColor = Colors.blue.shade300;
        txtColor = Colors.blue;
        break;
      case FeatureSectionStatus.fail:
        w = Icon(
          Icons.close,
          size: 20,
          color: Colors.red,
        );
        txtColor = Colors.red;
        break;
      case FeatureSectionStatus.none:
        w = Icon(
          icon,
          size: 20,
          color: Colors.black54,
        );
        txtColor = Colors.black87;
        break;
      default:
        w = SizedBox.shrink();
    }
    return Stack(
      children: [
        if (showConnector)
          Positioned(
            left: 10,
            top: 28,
            bottom: 0,
            child: Container(
              width: 2,
              color: connectorColor,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                w,
                const SizedBox(width: 8),
                CustomTextWidget(
                  title,
                  size: 16,
                  fontWeight: FontWeight.w600,
                  color: txtColor,
                ),
              ],
            ),
            if (cards.isNotEmpty) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final FeatureSectionStatus status;
  final void Function()? onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.status = FeatureSectionStatus.none,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    switch (status) {
      case FeatureSectionStatus.loading:
        color = Colors.white;
        textColor = Colors.blue.shade700;
        break;
      case FeatureSectionStatus.done:
        color = Colors.blue;
        textColor = Colors.white;
        break;
      case FeatureSectionStatus.fail:
        color = Colors.red;
        textColor = Colors.white;
        break;
      case FeatureSectionStatus.none:
        color = Colors.white;
        textColor = Colors.grey;

        break;
      default:
        color = Colors.black54;
        textColor = Colors.white;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  title,
                  size: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                const SizedBox(height: 4),
                CustomTextWidget(
                  description,
                  size: 12,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
