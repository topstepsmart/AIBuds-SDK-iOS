import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(aibudsLiveStreamChannelName);
  final binding = TestDefaultBinaryMessengerBinding.instance;

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getSDKVersion forwards to native method channel', () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        expect(call.method, 'getSDKVersion');
        return '1.0.0-test';
      },
    );

    expect(
      await AIBudsLiveStreamFlutter.getSDKVersion(),
      '1.0.0-test',
    );
  });

  test('streamer configure sends expected method shape', () async {
    final controller = AIBudsLiveStreamStreamerController(
      streamerId: 'test-streamer',
    );

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        expect(call.method, 'streamer');
        final args = Map<String, dynamic>.from(call.arguments as Map);
        expect(args['streamerId'], 'test-streamer');
        expect(args['method'], 'configure');
        expect(args['arguments'], containsPair('inputURL', 'rtsp://input'));
        expect(args['arguments'], containsPair('outputURL', 'rtmp://output'));
        return <String, dynamic>{
          'streamerId': 'test-streamer',
          'stateDescription': 'Idle',
          'isStreaming': false,
        };
      },
    );

    final state = await controller.configure(
      inputURL: 'rtsp://input',
      outputURL: 'rtmp://output',
    );

    expect(state['stateDescription'], 'Idle');
    expect(state['isStreaming'], false);
  });
}
