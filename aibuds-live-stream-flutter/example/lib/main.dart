import 'dart:async';

import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const LiveStreamExampleApp());

class LiveStreamExampleApp extends StatelessWidget {
  const LiveStreamExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8B5CF6);
    const background = Color(0xFF090814);
    const surface = Color(0xFF151326);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIBuds Live Stream',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('ja'),
        Locale('hi'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
          primary: purple,
          secondary: const Color(0xFFA78BFA),
          tertiary: const Color(0xFFF59E0B),
          surface: surface,
          surfaceContainerLowest: const Color(0xFF0D0B1B),
          surfaceContainerLow: const Color(0xFF131123),
          surfaceContainer: surface,
          surfaceContainerHigh: const Color(0xFF1C1930),
          surfaceContainerHighest: const Color(0xFF26213D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Color(0xFFF7F4FF),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF100E20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF302A4D)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF302A4D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: purple, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEDE7FF),
            side: const BorderSide(color: Color(0xFF3A315C)),
            minimumSize: const Size(48, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoText {
  DemoText(this.locale);

  final Locale locale;

  static DemoText of(BuildContext context) {
    return DemoText(Localizations.localeOf(context));
  }

  static const _values = <String, Map<String, String>>{
    'en': {
      'title': 'AIBuds Live Stream',
      'status': 'Status',
      'player': 'Player',
      'streamer': 'Streamer',
      'audio': 'Audio',
      'idle': 'Idle',
      'opening': 'Opening',
      'playing': 'Playing',
      'paused': 'Paused',
      'stopped': 'Stopped',
      'buffering': 'Buffering',
      'error': 'Error',
      'muted': 'Muted',
      'play': 'Play',
      'stop': 'Stop',
      'stopPlayer': 'Stop Player',
      'connectRtsp': 'Connect RTSP Address',
      'disconnectRtsp': 'Disconnect RTSP live streaming',
      'goLive': 'Start Push Stream',
      'endLive': 'Stop Push Stream',
      'rtspStatus': 'RTSP status: {state}',
      'rtsp': 'RTSP address',
      'rtmp': 'RTMP address',
      'save': 'Save',
      'saved': 'Saved',
    },
    'zh': {
      'title': 'AIBuds 直播',
      'status': '状态',
      'player': '播放器',
      'streamer': '推流器',
      'audio': '音频',
      'idle': '空闲',
      'opening': '打开中',
      'playing': '播放中',
      'paused': '已暂停',
      'stopped': '已停止',
      'buffering': '缓冲中',
      'error': '错误',
      'muted': '静音',
      'play': '播放',
      'stop': '停止',
      'stopPlayer': '停止播放',
      'connectRtsp': '连接 RTSP 地址',
      'disconnectRtsp': '断开 RTSP 直播',
      'goLive': '开始推流',
      'endLive': '停止推流',
      'rtspStatus': 'RTSP 状态：{state}',
      'rtsp': 'RTSP 地址',
      'rtmp': 'RTMP 地址',
      'save': '保存',
      'saved': '已保存',
    },
    'ja': {
      'title': 'AIBuds ライブ配信',
      'status': '状態',
      'player': 'プレイヤー',
      'streamer': '配信',
      'audio': '音声',
      'idle': '待機中',
      'opening': '開始中',
      'playing': '再生中',
      'paused': '一時停止',
      'stopped': '停止',
      'buffering': 'バッファ中',
      'error': 'エラー',
      'muted': 'ミュート',
      'play': '再生',
      'stop': '停止',
      'stopPlayer': '再生停止',
      'connectRtsp': 'RTSP アドレスに接続',
      'disconnectRtsp': 'RTSP ライブ配信を切断',
      'goLive': 'プッシュ配信開始',
      'endLive': 'プッシュ配信停止',
      'rtspStatus': 'RTSP 状態：{state}',
      'rtsp': 'RTSP アドレス',
      'rtmp': 'RTMP アドレス',
      'save': '保存',
      'saved': '保存済み',
    },
    'hi': {
      'title': 'AIBuds लाइव स्ट्रीम',
      'status': 'स्थिति',
      'player': 'प्लेयर',
      'streamer': 'स्ट्रीमर',
      'audio': 'ऑडियो',
      'idle': 'निष्क्रिय',
      'opening': 'खुल रहा है',
      'playing': 'चल रहा है',
      'paused': 'रुका हुआ',
      'stopped': 'बंद',
      'buffering': 'बफरिंग',
      'error': 'त्रुटि',
      'muted': 'म्यूट',
      'play': 'चलाएं',
      'stop': 'बंद करें',
      'stopPlayer': 'प्लेयर बंद करें',
      'connectRtsp': 'RTSP पते से कनेक्ट करें',
      'disconnectRtsp': 'RTSP लाइव स्ट्रीमिंग डिस्कनेक्ट करें',
      'goLive': 'पुश स्ट्रीम शुरू करें',
      'endLive': 'पुश स्ट्रीम बंद करें',
      'rtspStatus': 'RTSP स्थिति: {state}',
      'rtsp': 'RTSP पता',
      'rtmp': 'RTMP पता',
      'save': 'सहेजें',
      'saved': 'सहेजा गया',
    },
  };

  String t(String key) {
    final language = _values[locale.languageCode] ?? _values['en']!;
    return language[key] ?? _values['en']![key] ?? key;
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  static const _rtspKey = 'aibuds_demo_rtsp_url';
  static const _rtmpKey = 'aibuds_demo_rtmp_url';

  final _playerController = AIBudsLiveStreamPlayerController();
  final _streamerController = AIBudsLiveStreamStreamerController();
  final _rtspController = TextEditingController(text: 'rtsp://');
  final _rtmpController = TextEditingController(text: 'rtmp://');

  StreamSubscription<AIBudsLiveStreamPlayerEvent>? _playerSubscription;
  StreamSubscription<AIBudsLiveStreamStreamerEvent>? _streamerSubscription;

  final AIBudsLiveStreamFormat _format = AIBudsLiveStreamFormat.rtsp;
  final AIBudsLiveStreamGravityMode _gravity =
      AIBudsLiveStreamGravityMode.resizeAspect;
  final AIBudsLiveStreamPreset _preset = AIBudsLiveStreamPreset.defaultConfig;
  String _sdkInfo = '';
  String _playerStateKey = 'idle';
  final double _volume = 1;
  final bool _muted = false;
  final bool _publishAudio = true;
  final bool _adaptiveBitrate = true;
  bool _streaming = false;
  bool _rtspSaved = false;
  bool _rtmpSaved = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _streamerSubscription?.cancel();
    _playerController.disposePlayer();
    _streamerController.dispose();
    _rtspController.dispose();
    _rtmpController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await _safeSdkInfo();
    if (!mounted) return;
    setState(() {
      _rtspController.text = prefs.getString(_rtspKey) ?? _rtspController.text;
      _rtmpController.text = prefs.getString(_rtmpKey) ?? _rtmpController.text;
      _sdkInfo = info;
    });
  }

  Future<String> _safeSdkInfo() async {
    try {
      final info = await AIBudsLiveStreamFlutter.getSDKInfo();
      return '${info['version'] ?? '-'} ${info['releaseDate'] ?? ''}'.trim();
    } catch (_) {
      return '';
    }
  }

  void _listenPlayerEvents() {
    _playerSubscription ??= _playerController.events.listen((event) {
      final state = event.stateDescription;
      setState(() {
        if (state != null && state.isNotEmpty) {
          _playerStateKey = _stateKey(state);
        }
        if (event.event == 'buffer') _playerStateKey = 'buffering';
        if (event.event == 'error') _playerStateKey = 'error';
      });
    });
  }

  void _listenStreamerEvents() {
    _streamerSubscription ??= _streamerController.events.listen((event) {
      final state = event.stateDescription;
      setState(() {
        _streaming = event.isStreaming ?? _streaming;
        if (state == 'stopped' || event.event == 'stop') _streaming = false;
      });
    });
  }

  String _stateKey(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized.contains('buffer')) return 'buffering';
    if (normalized.contains('play')) return 'playing';
    if (normalized.contains('open') ||
        normalized.contains('connect') ||
        normalized.contains('prepare')) {
      return 'opening';
    }
    if (normalized.contains('pause')) return 'paused';
    if (normalized.contains('stop') || normalized.contains('close')) {
      return 'stopped';
    }
    if (normalized.contains('error') || normalized.contains('fail')) {
      return 'error';
    }
    if (normalized.contains('idle')) return 'idle';
    return normalized.isEmpty ? 'idle' : normalized;
  }

  String _localizedState(DemoText text, String key) {
    return text.t(_stateKey(key));
  }

  String _rtspStatusText(DemoText text) {
    return text
        .t('rtspStatus')
        .replaceAll('{state}', _localizedState(text, _playerStateKey));
  }

  Future<void> _saveRtspAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rtspKey, _rtspController.text.trim());
    if (!mounted) return;
    setState(() => _rtspSaved = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _rtspSaved = false);
    });
  }

  Future<void> _saveRtmpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rtmpKey, _rtmpController.text.trim());
    if (!mounted) return;
    setState(() => _rtmpSaved = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _rtmpSaved = false);
    });
  }

  Future<void> _play() async {
    _listenPlayerEvents();
    await _saveRtspAddress();
    setState(() => _playerStateKey = 'opening');
    await _playerController.play(
      _rtspController.text.trim(),
      format: _format,
      gravityMode: _gravity,
    );
  }

  Future<void> _stopPlayer() async {
    await _playerController.stop();
    setState(() => _playerStateKey = 'stopped');
  }

  AIBudsLiveStreamStreamerConfig get _streamerConfig {
    return AIBudsLiveStreamStreamerConfig(
      preset: _preset,
      publishAudio: _publishAudio,
      adaptiveBitrate: _adaptiveBitrate,
    );
  }

  Future<void> _startStreaming() async {
    _listenStreamerEvents();
    await _saveRtspAddress();
    await _saveRtmpAddress();
    setState(() => _streaming = true);
    await _streamerController.startStreaming(
      inputURL: _rtspController.text.trim(),
      outputURL: _rtmpController.text.trim(),
      config: _streamerConfig,
    );
  }

  Future<void> _stopStreaming() async {
    await _streamerController.stopStreaming();
    setState(() => _streaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final text = DemoText.of(context);
    final playerStateKey = _stateKey(_playerStateKey);
    final isPlaying = playerStateKey == 'playing';
    final showPlayerStateLabel =
        playerStateKey != 'idle' && playerStateKey != 'playing';
    final playerStateLabel = _localizedState(text, playerStateKey);
    return Scaffold(
      appBar: AppBar(
        title: Text(text.t('title')),
        actions: [
          if (_sdkInfo.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Text(
                  _sdkInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _PlayerStage(
                  controller: _playerController,
                  format: _format,
                  gravity: _gravity,
                  volume: _volume,
                  muted: _muted,
                  stateLabel: playerStateLabel,
                  showStateLabel: showPlayerStateLabel,
                ),
                const SizedBox(height: 12),
                _StatusLine(text: _rtspStatusText(text)),
                const SizedBox(height: 12),
                _AddressPanel(
                  controller: _rtspController,
                  label: text.t('rtsp'),
                  saved: _rtspSaved,
                  saveLabel: text.t(_rtspSaved ? 'saved' : 'save'),
                  onSave: _saveRtspAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: isPlaying ? _stopPlayer : _play,
                  style: isPlaying
                      ? FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        )
                      : null,
                  icon: Icon(
                    isPlaying ? Icons.stop_circle_outlined : Icons.link_rounded,
                  ),
                  label: Text(
                    isPlaying
                        ? text.t('disconnectRtsp')
                        : text.t('connectRtsp'),
                  ),
                ),
                const SizedBox(height: 18),
                _AddressPanel(
                  controller: _rtmpController,
                  label: text.t('rtmp'),
                  saved: _rtmpSaved,
                  saveLabel: text.t(_rtmpSaved ? 'saved' : 'save'),
                  onSave: _saveRtmpAddress,
                ),
                const SizedBox(height: 12),
                _streaming
                    ? OutlinedButton.icon(
                        onPressed: _stopStreaming,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: Text(text.t('endLive')),
                      )
                    : FilledButton.tonalIcon(
                        onPressed: _startStreaming,
                        icon: const Icon(Icons.cell_tower),
                        label: Text(text.t('goLive')),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerStage extends StatelessWidget {
  const _PlayerStage({
    required this.controller,
    required this.format,
    required this.gravity,
    required this.volume,
    required this.muted,
    required this.stateLabel,
    required this.showStateLabel,
  });

  final AIBudsLiveStreamPlayerController controller;
  final AIBudsLiveStreamFormat format;
  final AIBudsLiveStreamGravityMode gravity;
  final double volume;
  final bool muted;
  final String stateLabel;
  final bool showStateLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AIBudsLiveStreamPlayerView(
                controller: controller,
                options: AIBudsLiveStreamPlayerOptions(
                  format: format,
                  gravityMode: gravity,
                  volume: volume,
                  muted: muted,
                ),
              ),
              if (showStateLabel)
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.56),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Text(
                        stateLabel,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _AddressPanel extends StatelessWidget {
  const _AddressPanel({
    required this.controller,
    required this.label,
    required this.saved,
    required this.saveLabel,
    required this.onSave,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool saved;
  final String saveLabel;
  final VoidCallback onSave;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final field = TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
            decoration: InputDecoration(labelText: label),
          );
          final button = OutlinedButton.icon(
            onPressed: onSave,
            icon: Icon(saved ? Icons.check_circle : Icons.save_outlined),
            label: Text(saveLabel),
          );

          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [field, const SizedBox(height: 10), button],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: 10),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2B2444)),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}
