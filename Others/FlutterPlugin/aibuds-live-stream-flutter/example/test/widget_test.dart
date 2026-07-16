import 'package:aibuds_live_stream_flutter/aibuds_live_stream_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aibuds_live_stream_flutter_example/main.dart';

void main() {
  testWidgets('shows ordered player and streamer workflow', (tester) async {
    await tester.pumpWidget(const LiveStreamExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('AIBuds Live Stream'), findsOneWidget);
    expect(find.byType(AIBudsLiveStreamPlayerView), findsOneWidget);
    expect(find.text('RTSP status: Idle'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Connect RTSP Address'), findsOneWidget);
    expect(find.text('RTSP address'), findsOneWidget);
    expect(find.text('RTMP address'), findsOneWidget);
    expect(find.text('Start Push Stream'), findsOneWidget);
    expect(find.byIcon(Icons.cell_tower), findsAtLeastNWidgets(1));

    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('fits compact phone width without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LiveStreamExampleApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AIBudsLiveStreamPlayerView), findsOneWidget);
  });
}
