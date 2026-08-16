import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoverArt extends StatelessWidget {
  final String assetPath;
  final double size;
  final BorderRadius? borderRadius;

  const CoverArt({
    super.key,
    required this.assetPath,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: _CoverImage(assetPath: assetPath),
      ),
    );
  }
}

class _CoverImage extends StatefulWidget {
  final String assetPath;
  const _CoverImage({required this.assetPath});

  @override
  State<_CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<_CoverImage> {
  late Future<String?> _resolvedPath;

  @override
  void initState() {
    super.initState();
    _resolvedPath = _findExisting(widget.assetPath);
  }

  Future<String?> _findExisting(String path) async {
    final candidates = [
      path,
      path.endsWith('.jpg') ? path.replaceAll('.jpg', '.png') : path.replaceAll('.png', '.jpg'),
    ];
    for (final p in candidates) {
      try {
        await rootBundle.load(p);
        return p;
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolvedPath,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || snap.data == null) {
          return _Placeholder();
        }
        return Image.asset(
          snap.data!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _Placeholder(),
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white54, size: 28),
      ),
    );
  }
}
