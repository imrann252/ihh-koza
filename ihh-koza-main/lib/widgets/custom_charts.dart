import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─── Pie Chart (CustomPaint) ──────────────────────────────────────────────────

class PieChartData {
  final String label;
  final double value;
  final Color color;
  const PieChartData({required this.label, required this.value, required this.color});
}

class KozaPieChart extends StatefulWidget {
  final List<PieChartData> data;
  final double size;
  final String? centerLabel;
  final String? centerValue;
  final Function(PieChartData)? onSliceTap;

  const KozaPieChart({
    super.key,
    required this.data,
    this.size = 180,
    this.centerLabel,
    this.centerValue,
    this.onSliceTap,
  });

  @override
  State<KozaPieChart> createState() => _KozaPieChartState();
}

class _KozaPieChartState extends State<KozaPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.fold(0.0, (s, d) => s + d.value);
    if (total == 0) return const SizedBox();

    return Column(
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: GestureDetector(
                onTapUp: (details) {
                  if (widget.onSliceTap != null && _anim.isCompleted) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final Offset localOffset = box.globalToLocal(details.globalPosition);
                    final center = Offset(widget.size / 2, widget.size / 2);
                    
                    final double dx = localOffset.dx - center.dx;
                    final double dy = localOffset.dy - center.dy;
                    double tapAngle = atan2(dy, dx);
                    if (tapAngle < -pi / 2) tapAngle += 2 * pi;
                    
                    double startAngle = -pi / 2;
                    for (final d in widget.data) {
                      final sweep = (d.value / total) * 2 * pi;
                      if (tapAngle >= startAngle && tapAngle <= startAngle + sweep) {
                        widget.onSliceTap!(d);
                        break;
                      }
                      startAngle += sweep;
                    }
                  }
                },
                child: CustomPaint(
                  painter: _PiePainter(
                    data: widget.data,
                    total: total,
                    progress: _anim.value,
                    centerLabel: widget.centerLabel,
                    centerValue: widget.centerValue,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.map((d) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                  '${d.label} (${(d.value / total * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<PieChartData> data;
  final double total;
  final double progress;
  final String? centerLabel;
  final String? centerValue;

  _PiePainter({required this.data, required this.total, required this.progress, this.centerLabel, this.centerValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    double startAngle = -pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt;

    for (final d in data) {
      final sweep = (d.value / total) * 2 * pi * progress;
      paint.color = d.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }

    // Ortada metin
    if (centerValue != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: centerValue,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2 + 6));
    }
    if (centerLabel != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: centerLabel,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, -12));
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.progress != progress;
}

// ─── Bar Chart (CustomPaint) ──────────────────────────────────────────────────

class BarChartData {
  final String label;
  final double value;
  final Color color;
  const BarChartData({required this.label, required this.value, required this.color});
}

class KozaBarChart extends StatefulWidget {
  final List<BarChartData> data;
  final double maxValue;
  final double height;
  final String? unit;

  const KozaBarChart({
    super.key,
    required this.data,
    required this.maxValue,
    this.height = 180,
    this.unit = '',
  });

  @override
  State<KozaBarChart> createState() => _KozaBarChartState();
}

class _KozaBarChartState extends State<KozaBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return SizedBox(
          height: widget.height + 40,
          child: CustomPaint(
            painter: _BarPainter(
              data: widget.data,
              maxValue: widget.maxValue,
              progress: _anim.value,
              unit: widget.unit ?? '',
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<BarChartData> data;
  final double maxValue;
  final double progress;
  final String unit;

  _BarPainter({required this.data, required this.maxValue, required this.progress, required this.unit});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final barWidth = (size.width / data.length) * 0.55;
    final spacing = size.width / data.length;
    final chartHeight = size.height - 36;

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final barH = (d.value / maxValue) * chartHeight * progress;
      final left = spacing * i + (spacing - barWidth) / 2;
      final top = chartHeight - barH;

      final paint = Paint()
        ..color = d.color
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barH),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rrect, paint);

      // Value label
      final valueTp = TextPainter(
        text: TextSpan(
          text: '${d.value.toStringAsFixed(0)}$unit',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: d.color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valueTp.paint(canvas, Offset(left + barWidth / 2 - valueTp.width / 2, top - 14));

      // X label
      final labelTp = TextPainter(
        text: TextSpan(
          text: d.label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(left + barWidth / 2 - labelTp.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.progress != progress;
}

// ─── Mini İlerleme Göstergesi ─────────────────────────────────────────────────

class MiniProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final Color color;
  final double height;

  const MiniProgressBar({super.key, required this.value, required this.color, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: color.withAlpha(30),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
