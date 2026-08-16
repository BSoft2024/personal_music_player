import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../services/playlist_service.dart';

enum SortBy { title, album, year, type, length }

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  List<Song> _playQueue = [];

  int _currentIndex = -1;
  bool _shuffle = false;
  bool _isLoading = true;
  String? _error;

  // Filters
  final Set<String> _selectedInstruments = {};
  final Set<String> _selectedAlbums = {};
  final Set<String> _selectedTypes = {};
  final Set<int> _selectedYears = {};
  bool _showFavoritesOnly = false;

  // Favorites (saved on device)
  final Set<String> _favoriteTitles = {};

  SortBy _sortBy = SortBy.year;
  bool _sortAscending = false;

  // Public getters
  AudioPlayer get player => _player;
  List<Song> get songs => List.unmodifiable(_filteredSongs);
  List<Song> get allSongs => List.unmodifiable(_allSongs);
  Song? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _playQueue.length)
          ? _playQueue[_currentIndex]
          : null;
  bool get shuffle => _shuffle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _player.playing;
  bool get showFavoritesOnly => _showFavoritesOnly;

  Set<String> get selectedInstruments => Set.unmodifiable(_selectedInstruments);
  Set<String> get selectedAlbums => Set.unmodifiable(_selectedAlbums);
  Set<String> get selectedTypes => Set.unmodifiable(_selectedTypes);
  Set<int> get selectedYears => Set.unmodifiable(_selectedYears);
  SortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  List<String> get availableAlbums {
    final set = _allSongs.map((s) => s.album).where((a) => a.isNotEmpty).toSet().toList()..sort();
    return set;
  }

  List<int> get availableYears {
    final set = _allSongs.map((s) => s.year).where((y) => y > 0).toSet().toList()..sort();
    return set;
  }

  List<String> get availableTypes {
    final set = _allSongs.map((s) => s.type).toSet().toList()..sort();
    return set;
  }

  List<String> get availableInstruments => PlaylistService.instrumentsFromSongs(_allSongs);

  bool isFavorite(Song song) => _favoriteTitles.contains(song.title);

  PlayerProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      await _loadFavorites();
      _allSongs = await PlaylistService.loadSongs();
      _applyFiltersAndSort();
      _isLoading = false;
      notifyListeners();

      _loadDurationsInBackground();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? [];
    _favoriteTitles.addAll(list);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteTitles.toList());
  }

  Future<void> toggleFavorite(Song song) async {
    if (_favoriteTitles.contains(song.title)) {
      _favoriteTitles.remove(song.title);
    } else {
      _favoriteTitles.add(song.title);
    }
    await _saveFavorites();
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> _loadDurationsInBackground() async {
    for (var i = 0; i < _allSongs.length; i++) {
      try {
        final temp = AudioPlayer();
        await temp.setAsset(_allSongs[i].audioAsset);
        final d = temp.duration;
        if (d != null) {
          _allSongs[i] = _allSongs[i].copyWith(duration: d);
          final idxF = _filteredSongs.indexWhere((s) => s.title == _allSongs[i].title);
          if (idxF >= 0) _filteredSongs[idxF] = _allSongs[i];
          final idxQ = _playQueue.indexWhere((s) => s.title == _allSongs[i].title);
          if (idxQ >= 0) _playQueue[idxQ] = _allSongs[i];
        }
        await temp.dispose();
      } catch (_) {}
    }
    notifyListeners();
  }

  // ── Filters ──

  void toggleInstrument(String instrument) {
    if (_selectedInstruments.contains(instrument)) {
      _selectedInstruments.remove(instrument);
    } else {
      _selectedInstruments.add(instrument);
    }
    _applyFiltersAndSort();
  }

  void toggleAlbum(String album) {
    if (_selectedAlbums.contains(album)) {
      _selectedAlbums.remove(album);
    } else {
      _selectedAlbums.add(album);
    }
    _applyFiltersAndSort();
  }

  void toggleType(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    _applyFiltersAndSort();
  }

  void toggleYear(int year) {
    if (_selectedYears.contains(year)) {
      _selectedYears.remove(year);
    } else {
      _selectedYears.add(year);
    }
    _applyFiltersAndSort();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFiltersAndSort();
  }

  void clearAllFilters() {
    _selectedInstruments.clear();
    _selectedAlbums.clear();
    _selectedTypes.clear();
    _selectedYears.clear();
    _showFavoritesOnly = false;
    _applyFiltersAndSort();
  }

  void setSort(SortBy by, {bool? ascending}) {
    if (_sortBy == by && ascending == null) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = by;
      if (ascending != null) _sortAscending = ascending;
    }
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    var list = List<Song>.from(_allSongs);

    if (_showFavoritesOnly) {
      list = list.where((s) => _favoriteTitles.contains(s.title)).toList();
    }
    if (_selectedInstruments.isNotEmpty) {
      list = list.where((s) => _selectedInstruments.every((i) => s.instruments.contains(i))).toList();
    }
    if (_selectedAlbums.isNotEmpty) {
      list = list.where((s) => _selectedAlbums.contains(s.album)).toList();
    }
    if (_selectedTypes.isNotEmpty) {
      list = list.where((s) => _selectedTypes.contains(s.type)).toList();
    }
    if (_selectedYears.isNotEmpty) {
      list = list.where((s) => _selectedYears.contains(s.year)).toList();
    }

    list.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case SortBy.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortBy.album:
          cmp = a.album.toLowerCase().compareTo(b.album.toLowerCase());
          break;
        case SortBy.year:
          cmp = a.year.compareTo(b.year);
          break;
        case SortBy.type:
          cmp = a.type.compareTo(b.type);
          break;
        case SortBy.length:
          final da = a.duration?.inMilliseconds ?? 0;
          final db = b.duration?.inMilliseconds ?? 0;
          cmp = da.compareTo(db);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    _filteredSongs = list;
    _rebuildPlayQueue();
    notifyListeners();
  }

  void _rebuildPlayQueue() {
    final currentTitle = currentSong?.title;
    _playQueue = List<Song>.from(_filteredSongs);
    if (_shuffle && _playQueue.length > 1) {
      _playQueue.shuffle(Random());
    }
    if (currentTitle != null) {
      final newIdx = _playQueue.indexWhere((s) => s.title == currentTitle);
      _currentIndex = newIdx >= 0 ? newIdx : (_playQueue.isEmpty ? -1 : 0);
    } else {
      _currentIndex = _playQueue.isEmpty ? -1 : 0;
    }
  }

  // ── Playback ──

  Future<void> playSong(Song song) async {
    final idx = _playQueue.indexWhere((s) => s.title == song.title);
    if (idx < 0) return;
    _currentIndex = idx;
    await _loadAndPlay(_playQueue[_currentIndex]);
    notifyListeners();
  }

  Future<void> _loadAndPlay(Song song) async {
    try {
      await _player.setAsset(song.audioAsset);
      await _player.play();
    } catch (e) {
      debugPrint('Could not play ${song.audioAsset}: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_currentIndex < 0 && _playQueue.isNotEmpty) {
        _currentIndex = 0;
        await _loadAndPlay(_playQueue[0]);
      } else {
        await _player.play();
      }
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playQueue.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playQueue.length;
    await _loadAndPlay(_playQueue[_currentIndex]);
    notifyListeners();
  }

  Future<void> previous() async {
    if (_playQueue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playQueue.length) % _playQueue.length;
      await _loadAndPlay(_playQueue[_currentIndex]);
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    _rebuildPlayQueue();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
