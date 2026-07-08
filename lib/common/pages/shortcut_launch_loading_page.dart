import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

class ShortcutLaunchLoadingPage extends StatefulWidget {
  const ShortcutLaunchLoadingPage({super.key});

  @override
  State<ShortcutLaunchLoadingPage> createState() =>
      _ShortcutLaunchLoadingPageState();
}

class _ShortcutLaunchLoadingPageState extends State<ShortcutLaunchLoadingPage>
    with TickerProviderStateMixin {
  late final AnimationController _flowController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _LaunchPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: palette.backgroundGradient),
        child: AnimatedBuilder(
          animation: _flowController,
          builder: (context, child) {
            return CustomPaint(
              painter: _LaunchBackgroundPainter(
                progress: _flowController.value,
                palette: palette,
              ),
              child: child,
            );
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.pagePadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _LaunchPanel(
                    flow: _flowController,
                    pulse: _pulseController,
                    palette: palette,
                    title: context.l10n.homeTitle,
                    message: context.l10n.launchingCodex,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LaunchPalette {
  const _LaunchPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.text,
    required this.mutedText,
    required this.cyan,
    required this.blue,
    required this.green,
    required this.backgroundGradient,
    required this.isDark,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color text;
  final Color mutedText;
  final Color cyan;
  final Color blue;
  final Color green;
  final Gradient backgroundGradient;
  final bool isDark;

  static _LaunchPalette of(BuildContext context) {
    if (context.isDark) {
      const cyan = Color(0xFF37D7FF);
      const blue = Color(0xFF5B7CFF);
      const green = Color(0xFF43F0B0);
      return const _LaunchPalette(
        background: Color(0xFF060913),
        surface: Color(0xCC0B1020),
        surfaceHigh: Color(0xFF11172A),
        border: Color(0x334E668F),
        text: Color(0xFFF4F8FF),
        mutedText: Color(0xFF95A1B8),
        cyan: cyan,
        blue: blue,
        green: green,
        isDark: true,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF060913),
            Color(0xFF0A1222),
            Color(0xFF070A12),
          ],
          stops: [0, 0.54, 1],
        ),
      );
    }

    const cyan = Color(0xFF0CBAD3);
    const blue = Color(0xFF4268F5);
    const green = Color(0xFF16B886);
    return const _LaunchPalette(
      background: Color(0xFFF6F9FC),
      surface: Color(0xEFFFFFFF),
      surfaceHigh: Color(0xFFFFFFFF),
      border: Color(0x2233495F),
      text: Color(0xFF151A24),
      mutedText: Color(0xFF687286),
      cyan: cyan,
      blue: blue,
      green: green,
      isDark: false,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8FBFE),
          Color(0xFFEFF5FA),
          Color(0xFFF7FAFD),
        ],
        stops: [0, 0.58, 1],
      ),
    );
  }
}

class _LaunchPanel extends StatelessWidget {
  const _LaunchPanel({
    required this.flow,
    required this.pulse,
    required this.palette,
    required this.title,
    required this.message,
  });

  final Animation<double> flow;
  final Animation<double> pulse;
  final _LaunchPalette palette;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([flow, pulse]),
      builder: (context, child) {
        final lift = math.sin(flow.value * math.pi * 2) * 2;

        return Transform.translate(offset: Offset(0, lift), child: child);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 34.cw(min: 24, max: 42),
          vertical: 36.ch(min: 28, max: 44),
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28.cr(min: 22, max: 30)),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: palette.isDark ? 0.26 : 0.08),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
            BoxShadow(
              color: palette.cyan.withValues(
                alpha: palette.isDark ? 0.07 : 0.10,
              ),
              blurRadius: 42,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LaunchGlyph(flow: flow, pulse: pulse, palette: palette),
            SizedBox(height: 28.ch(min: 22, max: 34)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            SizedBox(height: 10.ch(min: 8, max: 12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.mutedText,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            SizedBox(height: 24.ch(min: 18, max: 28)),
            _LaunchStatusBar(animation: flow, palette: palette),
          ],
        ),
      ),
    );
  }
}

class _LaunchStatusBar extends StatelessWidget {
  const _LaunchStatusBar({required this.animation, required this.palette});

  final Animation<double> animation;
  final _LaunchPalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          width: 188.cw(min: 154, max: 214),
          height: 16.ch(min: 14, max: 18),
          child: CustomPaint(
            painter: _LaunchStatusBarPainter(
              progress: animation.value,
              palette: palette,
            ),
          ),
        );
      },
    );
  }
}

class _LaunchStatusBarPainter extends CustomPainter {
  const _LaunchStatusBarPainter({
    required this.progress,
    required this.palette,
  });

  final double progress;
  final _LaunchPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = Rect.fromLTWH(0, size.height / 2 - 2, size.width, 4);
    final track = RRect.fromRectAndRadius(trackRect, const Radius.circular(999));
    final trackPaint = Paint()
      ..color = palette.border.withValues(alpha: palette.isDark ? 0.9 : 0.72);
    canvas.drawRRect(track, trackPaint);

    final sweepWidth = size.width * 0.32;
    final sweepX = (size.width + sweepWidth) * progress - sweepWidth;
    final sweepRect = Rect.fromLTWH(sweepX, trackRect.top, sweepWidth, 4);
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          palette.cyan.withValues(alpha: 0.95),
          palette.green.withValues(alpha: 0.78),
          Colors.transparent,
        ],
      ).createShader(sweepRect);
    canvas.save();
    canvas.clipRRect(track);
    canvas.drawRect(sweepRect, sweepPaint);
    canvas.restore();

    final dotPaint = Paint()
      ..color = palette.green.withValues(alpha: palette.isDark ? 0.92 : 0.85);
    canvas.drawCircle(
      Offset(size.width - 4, size.height / 2),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LaunchStatusBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.palette != palette;
  }
}

class _LaunchGlyph extends StatelessWidget {
  const _LaunchGlyph({
    required this.flow,
    required this.pulse,
    required this.palette,
  });

  final Animation<double> flow;
  final Animation<double> pulse;
  final _LaunchPalette palette;

  @override
  Widget build(BuildContext context) {
    final size = 108.cr(min: 88, max: 118);

    return AnimatedBuilder(
      animation: Listenable.merge([flow, pulse]),
      builder: (context, child) {
        final scale = 0.985 + pulse.value * 0.025;

        return Transform.scale(
          scale: scale,
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _LaunchGlyphPainter(
                progress: flow.value,
                pulse: pulse.value,
                palette: palette,
              ),
              child: Center(child: child),
            ),
          ),
        );
      },
      child: Container(
        width: 68.cr(min: 56, max: 74),
        height: 68.cr(min: 56, max: 74),
        padding: EdgeInsets.all(10.cr(min: 8, max: 11)),
        decoration: BoxDecoration(
          color: palette.surfaceHigh.withValues(
            alpha: palette.isDark ? 0.86 : 0.96,
          ),
          borderRadius: BorderRadius.circular(20.cr(min: 16, max: 22)),
          border: Border.all(color: palette.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.cr(min: 11, max: 16)),
          child: Image.asset(
            'assets/images/icon.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _LaunchBackgroundPainter extends CustomPainter {
  const _LaunchBackgroundPainter({
    required this.progress,
    required this.palette,
  });

  final double progress;
  final _LaunchPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          palette.cyan.withValues(alpha: palette.isDark ? 0.11 : 0.16),
          palette.blue.withValues(alpha: palette.isDark ? 0.055 : 0.08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: size.shortestSide * 0.52),
      );
    canvas.drawCircle(center, size.shortestSide * 0.52, glowPaint);

    final railPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.border.withValues(alpha: palette.isDark ? 0.30 : 0.34);
    final railY = size.height * 0.86;
    canvas.drawLine(
      Offset(size.width * 0.18, railY),
      Offset(size.width * 0.82, railY),
      railPaint,
    );

    final sweepWidth = size.width * 0.18;
    final sweepX = (size.width + sweepWidth) * progress - sweepWidth;
    final sweepPaint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          palette.cyan.withValues(alpha: palette.isDark ? 0.28 : 0.45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sweepX, railY - 1, sweepWidth, 2));
    canvas.drawLine(
      Offset(sweepX, railY),
      Offset(sweepX + sweepWidth, railY),
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LaunchBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.palette != palette;
  }
}

class _LaunchGlyphPainter extends CustomPainter {
  const _LaunchGlyphPainter({
    required this.progress,
    required this.pulse,
    required this.palette,
  });

  final double progress;
  final double pulse;
  final _LaunchPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          palette.cyan.withValues(alpha: palette.isDark ? 0.16 : 0.18),
          palette.blue.withValues(alpha: palette.isDark ? 0.06 : 0.10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius, haloPaint);

    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.border.withValues(alpha: palette.isDark ? 0.95 : 0.72);
    canvas.drawCircle(center, radius - 5, outerRingPaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(progress * math.pi * 2),
        colors: [
          palette.cyan.withValues(alpha: 0.08),
          palette.cyan.withValues(alpha: 0.92),
          palette.green.withValues(alpha: 0.74),
          palette.cyan.withValues(alpha: 0.08),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 12),
      -math.pi / 2 + progress * math.pi * 2,
      math.pi * 1.12,
      false,
      arcPaint,
    );

    final innerPaint = Paint()
      ..color = palette.surface.withValues(alpha: palette.isDark ? 0.70 : 0.80);
    canvas.drawCircle(center, radius - 26, innerPaint);

    final pinPaint = Paint()
      ..color = palette.green.withValues(
        alpha: palette.isDark ? 0.62 + pulse * 0.24 : 0.50 + pulse * 0.18,
      );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.58, center.dy - radius * 0.48),
      3.2,
      pinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LaunchGlyphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.palette != palette;
  }
}
