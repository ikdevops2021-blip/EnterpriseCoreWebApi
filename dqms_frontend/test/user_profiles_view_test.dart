import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/admin/widgets/user_profiles_view.dart';

// Transparent 1x1 PNG image for image mocks
final _transparentPixel = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpRequest();
}

class _MockHttpRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpResponse();
}

class _MockHttpResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPixel.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPixel]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    HttpOverrides.global = _TestHttpOverrides();
  });

  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bgCanvas,
          body: UserProfilesView(),
        ),
      ),
    );
  }

  group('UserProfilesView — Modernized UI & Avatar Upload Tests', () {
    testWidgets('Renders Master Table with Clean Headers and User List', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // Master table headers
      expect(find.text('USER CODE'), findsOneWidget);
      expect(find.text('FULL NAME & TITLE'), findsOneWidget);
      expect(find.text('PRIMARY EMAIL & MOBILE'), findsOneWidget);
      expect(find.text('ROLE ASSIGNMENT'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);

      // Default user present in table
      expect(find.text('admin@dqms.org'), findsWidgets);
      expect(find.text('Dr. System Admin'), findsWidgets);
      expect(find.text('Create User Account'), findsOneWidget);
    });

    testWidgets('Renders Inspector with Avatar Hero and 3 Segmented Section Cards', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // Avatar Hero Card
      expect(find.text('Change Profile Photo'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // 3 Clean Segmented Cards
      expect(find.text('Identity & Role'), findsOneWidget);
      expect(find.text('Primary Address'), findsOneWidget);
      expect(find.text('Contact & Emergency Info'), findsOneWidget);

      // Clean labels without raw DB annotations
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Assigned Role'), findsOneWidget);
      expect(find.text('Address Type'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Contact Type'), findsOneWidget);
      expect(find.text('Relationship'), findsOneWidget);

      // Save & Action Buttons
      expect(find.text('Save Full User Profile'), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('Opens Create User Account Dialog on Button Press', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Create User Account button
      final createBtn = find.text('Create User Account');
      expect(createBtn, findsOneWidget);
      await tester.tap(createBtn);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Modal rendered
      expect(find.text('Create User Account'), findsWidgets);
      expect(find.text('User Handle / Code (Defaults to Email)'), findsOneWidget);
      expect(find.text('First Name *'), findsOneWidget);
      expect(find.text('Last Name *'), findsOneWidget);
      expect(find.text('Save User Account'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
