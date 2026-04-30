import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// The real Wellet wordmark, rendered from official path data on getwellet.com.
/// Source viewBox: "0 138 150 42" (width 150, height 42, offset y=138).
class WelletWordmark extends StatelessWidget {
  final double height;
  final Color color;

  /// Default wordmark color in Connect = cream (lives on moss surfaces).
  /// Override on cream-led screens to `WelletTheme.moss`.
  const WelletWordmark({
    super.key,
    this.height = 32,
    this.color = WelletTheme.cream,
  });

  @override
  Widget build(BuildContext context) {
    final aspect = 150 / 42; // viewBox width / height
    return SizedBox(
      width: height * aspect,
      height: height,
      child: CustomPaint(
        painter: _WelletWordmarkPainter(color),
      ),
    );
  }
}

class _WelletWordmarkPainter extends CustomPainter {
  final Color color;
  _WelletWordmarkPainter(this.color);

  // The 6 SVG paths that make up "Wellet" (W e l l e t)
  // Pulled verbatim from https://getwellet.com/ logo SVG.
  static const List<String> _paths = [
    // W
    'M45.5,142c.94.94,1.4,2.08,1.4,3.42,0,.89-.19,1.73-.58,2.52-.65-.1-1.33-.14-2.05-.14-3.07,0-5.56.97-7.45,2.9-1.9,1.93-3.36,4.34-4.39,7.22-1.03,2.88-2.17,6.86-3.42,11.95l-.47,1.94-.11-.25v.29h-5.15l-4.43-11.2-4.03,11.2h-5.15l-5.69-14.44c-.67-1.34-1.28-2.24-1.82-2.7-.54-.46-1.27-.73-2.18-.83l.25-2.56h12.56l-.04,2.56c-.53.07-1.01.26-1.44.58-.43.31-.65.76-.65,1.33,0,.17.04.38.11.65l3.71,9.47,3.1-8.5c-.48-.96-.88-1.67-1.21-2.14s-.67-.8-1.04-.99c-.37-.19-.87-.32-1.49-.4v-2.56h12.82v2.56c-.86.02-1.49.13-1.87.32-.38.19-.58.55-.58,1.08,0,.34.07.74.22,1.22l3.06,7.78c1.54-7.46,3.49-13.28,5.85-17.44,2.36-4.16,5.15-6.25,8.37-6.25,1.58,0,2.84.47,3.78,1.4Z',
    // e
    'M57.31,168.14c-1.13,1.44-2.57,2.56-4.32,3.37-1.75.8-3.61,1.21-5.58,1.21s-3.92-.49-5.65-1.48c-1.73-.98-3.1-2.32-4.1-4.01-1.01-1.69-1.51-3.55-1.51-5.56s.5-3.87,1.51-5.56c1.01-1.69,2.38-3.03,4.1-4.01,1.73-.98,3.61-1.48,5.65-1.48,1.92,0,3.62.28,5.09.83s2.62,1.31,3.42,2.29c.8.97,1.21,2.06,1.21,3.26,0,2.62-1.68,4.46-5.04,5.54-1.49.46-3.06.68-4.72.68-1.08,0-2.24-.11-3.49-.32.02,1.13.35,2.16.99,3.1.64.94,1.46,1.67,2.47,2.21s2.05.81,3.13.81c.96,0,1.94-.2,2.93-.61,1-.41,1.82-.98,2.47-1.73l1.44,1.48ZM45.7,155.59c-.8,1.26-1.34,2.86-1.6,4.81.84.17,1.64.25,2.41.25,1.61,0,2.87-.34,3.78-1.01.91-.67,1.51-1.5,1.8-2.48.1-.29.14-.59.14-.9,0-.86-.32-1.56-.95-2.09-.64-.53-1.36-.76-2.18-.68-1.46.14-2.6.85-3.4,2.11Z',
    // l
    'M58.21,170.23c.7-.12,1.26-.52,1.69-1.21.43-.68.65-1.9.65-3.65v-14.26c0-1.18-.13-2.08-.38-2.72s-.5-1.06-.76-1.26-.71-.51-1.39-.92c.65-.84,1.61-1.47,2.9-1.89,1.28-.42,2.59-.63,3.91-.63,1.15,0,2.04.14,2.66.43v21.24c0,1.75.22,2.97.65,3.65.43.68,1,1.09,1.69,1.21l.11,1.62h-11.84l.11-1.62Z',
    // l
    'M70.85,170.23c.7-.12,1.26-.52,1.69-1.21.43-.68.65-1.9.65-3.65v-14.26c0-1.18-.13-2.08-.38-2.72s-.5-1.06-.76-1.26-.71-.51-1.39-.92c.65-.84,1.61-1.47,2.9-1.89,1.28-.42,2.59-.63,3.91-.63,1.15,0,2.04.14,2.66.43v21.24c0,1.75.22,2.97.65,3.65.43.68,1,1.09,1.69,1.21l.11,1.62h-11.84l.11-1.62Z',
    // e
    'M104.11,168.14c-1.13,1.44-2.57,2.56-4.32,3.37-1.75.8-3.61,1.21-5.58,1.21s-3.92-.49-5.65-1.48c-1.73-.98-3.1-2.32-4.1-4.01-1.01-1.69-1.51-3.55-1.51-5.56s.5-3.87,1.51-5.56c1.01-1.69,2.38-3.03,4.1-4.01,1.73-.98,3.61-1.48,5.65-1.48,1.92,0,3.62.28,5.09.83,1.48.55,2.62,1.31,3.42,2.29.8.97,1.21,2.06,1.21,3.26,0,2.62-1.68,4.46-5.04,5.54-1.49.46-3.06.68-4.72.68-1.08,0-2.24-.11-3.49-.32.02,1.13.35,2.16.99,3.1.64.94,1.46,1.67,2.47,2.21,1.01.54,2.05.81,3.13.81.96,0,1.94-.2,2.93-.61s1.82-.98,2.47-1.73l1.44,1.48ZM92.5,155.59c-.8,1.26-1.34,2.86-1.6,4.81.84.17,1.64.25,2.41.25,1.61,0,2.87-.34,3.78-1.01s1.51-1.5,1.8-2.48c.09-.29.14-.59.14-.9,0-.86-.32-1.56-.95-2.09-.64-.53-1.36-.76-2.18-.68-1.46.14-2.6.85-3.4,2.11Z',
    // t
    'M139.93,141.71c.46.5.76,1.14.86,1.81.17,1.09-.14,2.07-.91,2.95s-1.69,1.36-2.84,1.51c-.83.11-1.71.14-2.64.09-1.17-.04-2.31,0-3.43.15-1.24.16-2.36.49-3.36,1-1,.5-1.5.85-2.29,1.37-1.25.83-.64.51-2.68,1.64-1.7.75-1.02.47-2.27.96-2.92,1.15-5.84,1.04-6.2,1.21v12.12c0,.86.13,1.51.38,1.93s.58.63.99.63c.26,0,.55-.09.86-.27.31-.18.6-.43.86-.74l1.44,1.48c-.98,1.1-1.96,1.87-2.92,2.3-.96.43-2.08.65-3.35.65-1.58,0-2.89-.4-3.92-1.21-1.03-.8-1.55-1.95-1.55-3.44v-13c-.74-.07-1.58-.18-2.5-.32l.32-2.59,2.27-.07v-3.85c.79-.65,1.83-1.18,3.13-1.6,1.3-.42,2.63-.63,4-.63v6.16c1.83.06,3.93-.04,6.31-.31,2.83-.32,5.18-1.17,7.06-2.55,2.62-1.87,4.32-2.81,5.11-2.81.9,0,1.59.25,2.05.76Z',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox is "0 138 150 42" — translate so y=138 maps to 0, then scale to fit.
    final scaleX = size.width / 150.0;
    final scaleY = size.height / 42.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    canvas.translate(0, -138);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final pathString in _paths) {
      final path = _parseSvgPath(pathString);
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WelletWordmarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Minimal SVG path parser supporting M, m, L, l, H, h, V, v, C, c, S, s,
/// Q, q, T, t, A (treated as line), Z, z. Sufficient for the Wellet
/// wordmark (which uses M, c, l, s, v, z).
Path _parseSvgPath(String d) {
  final path = Path();
  final tokens = _tokenize(d);
  double cx = 0, cy = 0; // current point
  double sx = 0, sy = 0; // subpath start
  double lastCx2 = 0, lastCy2 = 0; // for S/s smooth curves
  String? lastCommand;

  int i = 0;
  while (i < tokens.length) {
    final token = tokens[i];
    String cmd;
    if (token is String) {
      cmd = token;
      i++;
    } else {
      // Implicit repeat of previous command.
      cmd = lastCommand ?? 'L';
    }

    switch (cmd) {
      case 'M':
        cx = (tokens[i++] as num).toDouble();
        cy = (tokens[i++] as num).toDouble();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        lastCommand = 'L';
        break;
      case 'm':
        cx += (tokens[i++] as num).toDouble();
        cy += (tokens[i++] as num).toDouble();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        lastCommand = 'l';
        break;
      case 'L':
        cx = (tokens[i++] as num).toDouble();
        cy = (tokens[i++] as num).toDouble();
        path.lineTo(cx, cy);
        lastCommand = 'L';
        break;
      case 'l':
        cx += (tokens[i++] as num).toDouble();
        cy += (tokens[i++] as num).toDouble();
        path.lineTo(cx, cy);
        lastCommand = 'l';
        break;
      case 'H':
        cx = (tokens[i++] as num).toDouble();
        path.lineTo(cx, cy);
        lastCommand = 'H';
        break;
      case 'h':
        cx += (tokens[i++] as num).toDouble();
        path.lineTo(cx, cy);
        lastCommand = 'h';
        break;
      case 'V':
        cy = (tokens[i++] as num).toDouble();
        path.lineTo(cx, cy);
        lastCommand = 'V';
        break;
      case 'v':
        cy += (tokens[i++] as num).toDouble();
        path.lineTo(cx, cy);
        lastCommand = 'v';
        break;
      case 'C':
        {
          final x1 = (tokens[i++] as num).toDouble();
          final y1 = (tokens[i++] as num).toDouble();
          final x2 = (tokens[i++] as num).toDouble();
          final y2 = (tokens[i++] as num).toDouble();
          final x = (tokens[i++] as num).toDouble();
          final y = (tokens[i++] as num).toDouble();
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCx2 = x2;
          lastCy2 = y2;
          cx = x;
          cy = y;
          lastCommand = 'C';
          break;
        }
      case 'c':
        {
          final x1 = cx + (tokens[i++] as num).toDouble();
          final y1 = cy + (tokens[i++] as num).toDouble();
          final x2 = cx + (tokens[i++] as num).toDouble();
          final y2 = cy + (tokens[i++] as num).toDouble();
          final x = cx + (tokens[i++] as num).toDouble();
          final y = cy + (tokens[i++] as num).toDouble();
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCx2 = x2;
          lastCy2 = y2;
          cx = x;
          cy = y;
          lastCommand = 'c';
          break;
        }
      case 'S':
        {
          // Reflect previous control point.
          final reflectsCubic =
              lastCommand == 'C' || lastCommand == 'c' || lastCommand == 'S' || lastCommand == 's';
          final x1 = reflectsCubic ? 2 * cx - lastCx2 : cx;
          final y1 = reflectsCubic ? 2 * cy - lastCy2 : cy;
          final x2 = (tokens[i++] as num).toDouble();
          final y2 = (tokens[i++] as num).toDouble();
          final x = (tokens[i++] as num).toDouble();
          final y = (tokens[i++] as num).toDouble();
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCx2 = x2;
          lastCy2 = y2;
          cx = x;
          cy = y;
          lastCommand = 'S';
          break;
        }
      case 's':
        {
          final reflectsCubic =
              lastCommand == 'C' || lastCommand == 'c' || lastCommand == 'S' || lastCommand == 's';
          final x1 = reflectsCubic ? 2 * cx - lastCx2 : cx;
          final y1 = reflectsCubic ? 2 * cy - lastCy2 : cy;
          final x2 = cx + (tokens[i++] as num).toDouble();
          final y2 = cy + (tokens[i++] as num).toDouble();
          final x = cx + (tokens[i++] as num).toDouble();
          final y = cy + (tokens[i++] as num).toDouble();
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCx2 = x2;
          lastCy2 = y2;
          cx = x;
          cy = y;
          lastCommand = 's';
          break;
        }
      case 'Z':
      case 'z':
        path.close();
        cx = sx;
        cy = sy;
        lastCommand = 'z';
        break;
      default:
        // Unknown command — skip one token to avoid infinite loop.
        i++;
        break;
    }
  }
  return path;
}

/// Tokenize an SVG path into commands (String) and numbers (double).
List<dynamic> _tokenize(String d) {
  final tokens = <dynamic>[];
  final buffer = StringBuffer();

  void flushNumber() {
    if (buffer.isNotEmpty) {
      final str = buffer.toString();
      final n = double.tryParse(str);
      if (n != null) tokens.add(n);
      buffer.clear();
    }
  }

  for (int i = 0; i < d.length; i++) {
    final ch = d[i];
    final code = ch.codeUnitAt(0);
    final isLetter = (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);
    if (isLetter) {
      flushNumber();
      tokens.add(ch);
    } else if (ch == ',' || ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
      flushNumber();
    } else if (ch == '-' || ch == '+') {
      // Sign starts a new number unless it's the exponent sign.
      if (buffer.isNotEmpty) {
        final last = buffer.toString();
        final lastChar = last[last.length - 1];
        if (lastChar == 'e' || lastChar == 'E') {
          buffer.write(ch);
        } else {
          flushNumber();
          buffer.write(ch);
        }
      } else {
        buffer.write(ch);
      }
    } else if (ch == '.') {
      // A second '.' starts a new number.
      if (buffer.toString().contains('.')) {
        flushNumber();
      }
      buffer.write(ch);
    } else {
      buffer.write(ch);
    }
  }
  flushNumber();
  return tokens;
}

/// "Wellet · CONNECT" lockup: real Wellet wordmark + the CONNECT submark pill.
///
/// Defaults to the moss-led variant: cream wordmark + cream pill with
/// moss-dark text. On cream-led surfaces, set `surface` to
/// [ConnectSurface.cream] to invert.
class WelletConnectLockup extends StatelessWidget {
  final double wordmarkHeight;
  final ConnectSurface surface;

  const WelletConnectLockup({
    super.key,
    this.wordmarkHeight = 32,
    this.surface = ConnectSurface.moss,
  });

  @override
  Widget build(BuildContext context) {
    final onMoss = surface == ConnectSurface.moss;
    final wordmarkColor = onMoss ? WelletTheme.cream : WelletTheme.moss;
    final pillFill = onMoss ? WelletTheme.cream : WelletTheme.mossDark;
    final pillText = onMoss ? WelletTheme.mossDark : WelletTheme.cream;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WelletWordmark(height: wordmarkHeight, color: wordmarkColor),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: pillFill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'CONNECT',
            style: GoogleFonts.dmSans(
              color: pillText,
              fontSize: wordmarkHeight * 0.36,
              fontWeight: FontWeight.w500,
              letterSpacing: wordmarkHeight * 0.36 * 0.12, // 0.12em
            ),
          ),
        ),
      ],
    );
  }
}
