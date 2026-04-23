import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';
import 'package:weather_app/widgets/weather_loading_shimmer.dart';

void main() {
  testWidgets('app shows responsive loading state on startup', (tester) async {
    await tester.pumpWidget(const WeatherApp());

    expect(find.byType(WeatherLoadingShimmer), findsOneWidget);
  });
}
