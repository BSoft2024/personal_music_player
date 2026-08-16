class Song {
  final String title;
  final String album;
  final String type; // Single, EP, Album, etc.
  final int year;
  final Set<String> instruments;
  final String audioAsset;
  final String coverAsset;
  Duration? duration;

  Song({
    required this.title,
    required this.album,
    required this.type,
    required this.year,
    required this.instruments,
    required this.audioAsset,
    required this.coverAsset,
    this.duration,
  });

  Song copyWith({Duration? duration}) {
    return Song(
      title: title,
      album: album,
      type: type,
      year: year,
      instruments: instruments,
      audioAsset: audioAsset,
      coverAsset: coverAsset,
      duration: duration ?? this.duration,
    );
  }

  String get formattedDuration {
    if (duration == null) return '--:--';
    final m = duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  String toString() => '$title ($album, $year)';
}
