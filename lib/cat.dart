import 'package:flutter/material.dart';

import 'app_state.dart';

/// 고양이 표정.
enum CatMood { idle, focused, happy, sad }

/// 성장 단계와 기분에 따라 달라지는 고양이.
///
/// ponytail: 도형으로 그린다. 재미가 확인되면 Rive/Lottie 아트로 교체한다.
class CatView extends StatelessWidget {
  const CatView({
    super.key,
    required this.stage,
    required this.mood,
    this.size = 200,
  });

  final CatStage stage;
  final CatMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CatPainter(stage: stage, mood: mood)),
    );
  }
}

class _CatPainter extends CustomPainter {
  _CatPainter({required this.stage, required this.mood});

  final CatStage stage;
  final CatMood mood;

  /// 성장할수록 몸집이 커진다.
  double get _scale => switch (stage) {
        CatStage.baby => 0.7,
        CatStage.teen => 0.85,
        CatStage.adult => 1.0,
      };

  Color get _furColor => switch (mood) {
        CatMood.happy => const Color(0xFFFFC9A9),
        CatMood.sad => const Color(0xFFC9C4D6),
        _ => const Color(0xFFF5D5B8),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * _scale;
    final fur = Paint()..color = _furColor;
    final ink = Paint()
      ..color = const Color(0xFF4A4453)
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 귀
    for (final dx in [-0.62, 0.62]) {
      final path = Path()
        ..moveTo(center.dx + r * dx - r * 0.26, center.dy - r * 0.55)
        ..lineTo(center.dx + r * dx, center.dy - r * 1.15)
        ..lineTo(center.dx + r * dx + r * 0.26, center.dy - r * 0.55)
        ..close();
      canvas.drawPath(path, fur);
    }

    // 얼굴
    canvas.drawCircle(center, r * 0.9, fur);

    // 눈
    final eyeY = center.dy - r * 0.12;
    for (final dx in [-0.34, 0.34]) {
      final eye = Offset(center.dx + r * dx, eyeY);
      if (mood == CatMood.happy) {
        // ^ ^ 웃는 눈
        canvas.drawPath(
          Path()
            ..moveTo(eye.dx - r * 0.14, eye.dy + r * 0.07)
            ..lineTo(eye.dx, eye.dy - r * 0.09)
            ..lineTo(eye.dx + r * 0.14, eye.dy + r * 0.07),
          ink,
        );
      } else if (mood == CatMood.sad) {
        // 아래로 처진 눈
        canvas.drawPath(
          Path()
            ..moveTo(eye.dx - r * 0.14, eye.dy - r * 0.05)
            ..lineTo(eye.dx, eye.dy + r * 0.09)
            ..lineTo(eye.dx + r * 0.14, eye.dy - r * 0.05),
          ink,
        );
      } else {
        // 집중 중엔 눈을 가늘게, 평소엔 동그랗게
        final h = mood == CatMood.focused ? r * 0.07 : r * 0.15;
        canvas.drawOval(
          Rect.fromCenter(center: eye, width: r * 0.24, height: h * 2),
          Paint()..color = const Color(0xFF4A4453),
        );
      }
    }

    // 코와 입
    final noseY = center.dy + r * 0.24;
    canvas.drawCircle(
      Offset(center.dx, noseY),
      r * 0.07,
      Paint()..color = const Color(0xFFE79FA6),
    );
    final mouthDip = mood == CatMood.sad ? -r * 0.12 : r * 0.14;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - r * 0.2, noseY + r * 0.1)
        ..quadraticBezierTo(
            center.dx, noseY + r * 0.1 + mouthDip, center.dx + r * 0.2, noseY + r * 0.1),
      ink,
    );

    // 수염
    for (final side in [-1.0, 1.0]) {
      for (final dy in [-0.08, 0.06]) {
        canvas.drawLine(
          Offset(center.dx + side * r * 0.32, noseY + r * dy),
          Offset(center.dx + side * r * 0.82, noseY + r * (dy - 0.06)),
          ink,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CatPainter old) =>
      old.stage != stage || old.mood != mood;
}
