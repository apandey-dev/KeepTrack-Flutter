import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogo(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.mali(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Pixel-perfect vector representation of the official Google 4-color 'G' logo
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final strokeWidth = radius * 0.42;

    // Outer circle bounds
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw Yellow arc (approx 120° to 220°)
    arcPaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.0, 1.4, false, arcPaint);

    // Draw Red arc (approx 220° to 340°)
    arcPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.4, 1.7, false, arcPaint);

    // Draw Green arc (approx 40° to 120°)
    arcPaint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.4, 1.6, false, arcPaint);

    // Draw Blue arc (right lower curve)
    arcPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.3, 0.7, false, arcPaint);

    // Blue horizontal arm
    final barRect = Rect.fromLTRB(
      center.dx - radius * 0.05,
      center.dy - strokeWidth / 2,
      center.dx + radius * 0.95,
      center.dy + strokeWidth / 2,
    );
    canvas.drawRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
