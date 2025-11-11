import 'dart:math';
import 'package:flutter/material.dart';

class CustomShapeBorder extends ShapeBorder {
  const CustomShapeBorder({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    this.cutOutBottomOffset = 0,
  })  : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final double width = rect.width;
    final double height = rect.height;
    final double borderOffset = borderWidth / 2;

    // ✅ Renommer les variables locales pour éviter conflit avec propriétés
    final double safeCutOutWidth =
        cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final double safeCutOutHeight =
        cutOutHeight < height ? cutOutHeight : height - borderOffset;

    final double safeBorderLength = borderLength >
            min(safeCutOutWidth, safeCutOutHeight) / 2 + borderWidth * 2
        ? min(safeCutOutWidth, safeCutOutHeight) / 4
        : borderLength;

    final Paint backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final Paint boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final Rect cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - safeCutOutWidth / 2 + borderOffset,
      rect.top +
          height / 2 -
          safeCutOutHeight / 2 -
          cutOutBottomOffset +
          borderOffset,
      safeCutOutWidth - borderOffset * 2,
      safeCutOutHeight - borderOffset * 2,
    );

    // ✅ Utilisation d’un layer pour le blendMode
    canvas.saveLayer(rect, backgroundPaint);

    // Dessiner le fond semi-transparent
    canvas.drawRect(rect, backgroundPaint);

    // Dessiner les coins (encadrement)
    // Top-right
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.right - safeBorderLength,
        cutOutRect.top,
        cutOutRect.right,
        cutOutRect.top + safeBorderLength,
        topRight: Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Top-left
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.left,
        cutOutRect.top,
        cutOutRect.left + safeBorderLength,
        cutOutRect.top + safeBorderLength,
        topLeft: Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Bottom-right
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.right - safeBorderLength,
        cutOutRect.bottom - safeBorderLength,
        cutOutRect.right,
        cutOutRect.bottom,
        bottomRight: Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Bottom-left
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.left,
        cutOutRect.bottom - safeBorderLength,
        cutOutRect.left + safeBorderLength,
        cutOutRect.bottom,
        bottomLeft: Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Découper la zone intérieure
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      boxPaint,
    );

    canvas.restore();
  }

  @override
  ShapeBorder scale(double t) {
    return CustomShapeBorder(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutWidth: cutOutWidth * t,
      cutOutHeight: cutOutHeight * t,
      cutOutBottomOffset: cutOutBottomOffset * t,
    );
  }
}
