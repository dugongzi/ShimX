import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';

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
    required this.text,
    required this.mutedText,
    required this.cyan,
    required this.blue,
    required this.violet,
    required this.magenta,
    required this.backgroundGradient,
    required this.isDark,
  });

  final Color background;
  final Color surface;
  final Color text;
  final Color mutedText;
  final Color cyan;
  final Color blue;
  final Color violet;
  final Color magenta;
  final Gradient backgroundGradient;
  final bool isDark;

  static _LaunchPalette of(BuildContext context) {
    if (context.isDark) {
      const cyan = Color(0xFF28F4FF);
      const blue = Color(0xFF256BFF);
      const violet = Color(0xFF7A35FF);
      const magenta = Color(0xFFFF4DFF);
      return const _LaunchPalette(
        background: Color(0xFF050712),
        surface: Color(0xFF0D1230),
        text: Color(0xFFEFF7FF),
        mutedText: Color(0xFF9DA7C8),
        cyan: cyan,
        blue: blue,
        violet: violet,
        magenta: magenta,
        isDark: true,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF070A18),
            Color(0xFF0C1330),
            Color(0xFF110924),
            Color(0xFF050712),
          ],
          stops: [0, 0.36, 0.72, 1],
        ),
      );
    }

    const cyan = Color(0xFF00DDF4);
    const blue = Color(0xFF2463FF);
    const violet = Color(0xFF7143FF);
    const magenta = Color(0xFFE843FF);
    return const _LaunchPalette(
      background: Color(0xFFF5FAFF),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF171B34),
      mutedText: Color(0xFF68718F),
      cyan: cyan,
      blue: blue,
      violet: violet,
      magenta: magenta,
      isDark: false,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8FDFF),
          Color(0xFFEFF6FF),
          Color(0xFFF8F0FF),
          Color(0xFFF6FBFF),
        ],
        stops: [0, 0.38, 0.76, 1],
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
        final lift = math.sin(flow.value * math.pi * 2) * 5;

        return Transform.translate(offset: Offset(0, lift), child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LaunchGlyph(flow: flow, pulse: pulse, palette: palette),
          SizedBox(height: 26.ch(min: 20, max: 34)),
          _GradientText(
            title,
            palette: palette,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          SizedBox(height: 14.ch(min: 10, max: 18)),
          AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final textColor = Color.lerp(
                palette.cyan,
                palette.magenta,
                pulse.value,
              )!;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.cw(min: 6, max: 10)),
                  _LoadingDots(animation: flow, palette: palette),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.palette,
    required this.style,
  });

  final String text;
  final _LaunchPalette palette;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            palette.cyan,
            palette.blue,
            palette.violet,
            palette.magenta,
          ],
        ).createShader(bounds);
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style?.copyWith(
          color: Colors.white,
          shadows: [
            Shadow(
              color: palette.cyan.withValues(
                alpha: palette.isDark ? 0.28 : 0.18,
              ),
              blurRadius: palette.isDark ? 18 : 12,
            ),
            Shadow(
              color: palette.magenta.withValues(
                alpha: palette.isDark ? 0.16 : 0.10,
              ),
              blurRadius: palette.isDark ? 22 : 14,
            ),
          ],
        ),
      ),
    );
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
    final size = 112.cr(min: 88, max: 128);

    return AnimatedBuilder(
      animation: Listenable.merge([flow, pulse]),
      builder: (context, child) {
        final scale = 0.96 + pulse.value * 0.055;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.cr(min: 14, max: 20)),
        child: Image.asset(
          'assets/images/icon.png',
          width: 58.cr(min: 44, max: 66),
          height: 58.cr(min: 44, max: 66),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.animation, required this.palette});

  final Animation<double> animation;
  final _LaunchPalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (animation.value + index * 0.18) % 1;
            final opacity = 0.28 + (math.sin(phase * math.pi * 2) + 1) * 0.34;
            final y = -math.sin(phase * math.pi * 2) * 3;

            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                width: 5.cr(min: 4, max: 6),
                height: 5.cr(min: 4, max: 6),
                margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    palette.cyan,
                    palette.magenta,
                    index / 2,
                  )!.withValues(alpha: opacity),
                ),
              ),
            );
          }),
        );
      },
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
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.cyan.withValues(alpha: palette.isDark ? 0.035 : 0.075);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = palette.magenta.withValues(alpha: palette.isDark ? 0.055 : 0.12);

    final spacing = 42.0;
    final offset = progress * spacing * 2;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x + offset, 0),
        Offset(x + offset + size.height * 0.45, size.height),
        linePaint,
      );
    }

    final path = Path();
    final baseY = size.height * 0.72;
    path.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x += 28) {
      final wave = math.sin(
        (x / size.width * 2 * math.pi) + progress * 2 * math.pi,
      );
      path.lineTo(x, baseY + wave * 14);
    }
    canvas.drawPath(path, accentPaint);

    _drawVitalLine(
      canvas,
      size,
      yFactor: 0.36,
      amplitude: 18,
      phase: progress * math.pi * 2,
      color: palette.cyan,
    );
    _drawVitalLine(
      canvas,
      size,
      yFactor: 0.62,
      amplitude: 12,
      phase: progress * math.pi * 2 + math.pi * 0.82,
      color: palette.magenta,
    );

    final sweepWidth = size.width * 0.42;
    final sweepX = (size.width + sweepWidth) * progress - sweepWidth;
    final railY = size.height * 0.88;
    final railPaint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          palette.cyan.withValues(alpha: palette.isDark ? 0.26 : 0.52),
          palette.magenta.withValues(alpha: palette.isDark ? 0.22 : 0.46),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sweepX, railY - 1, sweepWidth, 2));
    canvas.drawLine(
      Offset(sweepX, railY),
      Offset(sweepX + sweepWidth, railY),
      railPaint,
    );
  }

  void _drawVitalLine(
    Canvas canvas,
    Size size, {
    required double yFactor,
    required double amplitude,
    required double phase,
    required Color color,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: palette.isDark ? 0.10 : 0.16);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: palette.isDark ? 0.025 : 0.045);

    final path = Path();
    final baseY = size.height * yFactor;
    path.moveTo(size.width * 0.08, baseY);
    for (double x = size.width * 0.08; x <= size.width * 0.92; x += 22) {
      final normalized = x / size.width;
      final wave =
          math.sin(normalized * math.pi * 2.4 + phase) * amplitude +
          math.sin(normalized * math.pi * 5.2 - phase * 0.72) * amplitude * 0.34;
      path.lineTo(x, baseY + wave);
    }
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
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

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          palette.cyan.withValues(alpha: palette.isDark ? 0.14 : 0.22),
          palette.violet.withValues(alpha: palette.isDark ? 0.06 : 0.14),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius, fillPaint);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = palette.cyan.withValues(
        alpha: palette.isDark ? 0.12 + pulse * 0.08 : 0.20 + pulse * 0.16,
      );
    canvas.drawCircle(center, radius - 5, outerPaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(progress * math.pi * 2),
        colors: [
          palette.cyan.withValues(alpha: 0.12),
          palette.magenta.withValues(alpha: 0.85),
          palette.blue.withValues(alpha: 0.92),
          palette.cyan.withValues(alpha: 0.12),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 12),
      -math.pi / 2 + progress * math.pi * 2,
      math.pi * 1.35,
      false,
      arcPaint,
    );

    final innerPaint = Paint()
      ..color = palette.surface.withValues(alpha: palette.isDark ? 0.58 : 0.76);
    canvas.drawCircle(center, radius - 26, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _LaunchGlyphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.palette != palette;
  }
}
