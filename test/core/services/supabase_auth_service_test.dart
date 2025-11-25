import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_auth_service_test.mocks.dart';

@GenerateMocks([
  SupabaseClient,
  GoTrueClient,
  AuthResponse,
  Session,
  User,
])
void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late SupabaseAuthService service;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(mockClient.auth).thenReturn(mockAuth);
    service = SupabaseAuthService(client: mockClient);
  });

  test('signIn delegates to Supabase client', () async {
    final response = MockAuthResponse();
    when(mockAuth.signInWithPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => response);

    final result = await service.signIn(email: 'user@foo.com', password: 'secret');

    expect(result, same(response));
    verify(mockAuth.signInWithPassword(email: 'user@foo.com', password: 'secret'))
        .called(1);
  });

  test('signOut delegates to Supabase client', () async {
    when(mockAuth.signOut()).thenAnswer((_) async {});

    await service.signOut();

    verify(mockAuth.signOut()).called(1);
  });

  test('resetPassword delegates to Supabase client', () async {
    when(mockAuth.resetPasswordForEmail(any)).thenAnswer((_) async {});

    await service.resetPassword('someone@foo.com');

    verify(mockAuth.resetPasswordForEmail('someone@foo.com')).called(1);
  });

  test('getCurrentSession and isAuthenticated read from client', () {
    final session = MockSession();
    when(mockAuth.currentSession).thenReturn(session);

    expect(service.getCurrentSession(), same(session));
    expect(service.isAuthenticated(), isTrue);
  });

  test('getCurrentUser reads from client', () {
    final user = MockUser();
    when(mockAuth.currentUser).thenReturn(user);

    expect(service.getCurrentUser(), same(user));
  });

  Future<T> _withoutDelay<T>(Future<T> Function() run) {
    return runZoned(
      run,
      zoneSpecification: ZoneSpecification(
        createTimer: (self, parent, zone, duration, callback) =>
            parent.createTimer(zone, Duration.zero, callback),
        createPeriodicTimer: (self, parent, zone, duration, callback) =>
            parent.createPeriodicTimer(zone, Duration.zero, callback),
      ),
    );
  }

  test('signUp retries on rate limit responses', () async {
    final response = MockAuthResponse();
    var callCount = 0;

    when(mockAuth.signUp(
      email: anyNamed('email'),
      password: anyNamed('password'),
      data: anyNamed('data'),
    )).thenAnswer((_) {
      callCount += 1;
      if (callCount < 3) {
        throw Exception('429 rate limit');
      }
      return Future.value(response);
    });

    final result = await _withoutDelay(
      () => service.signUp(email: 'rate@foo.com', password: 'secret'),
    );

    expect(result, same(response));
    expect(callCount, 3);
  });

  test('signUp rethrows original after retries exhausted', () async {
    when(mockAuth.signUp(
      email: anyNamed('email'),
      password: anyNamed('password'),
      data: anyNamed('data'),
    )).thenAnswer((_) => throw Exception('over_email_send_rate_limit'));

    await expectLater(
      _withoutDelay(() => service.signUp(email: 'fail@foo.com', password: 'secret')),
      throwsA(isA<Exception>().having(
        (err) => err.toString(),
        'message',
        contains('over_email_send_rate_limit'),
      )),
    );
  });

  test('signUp rethrows non rate limit errors immediately', () {
    when(mockAuth.signUp(
      email: anyNamed('email'),
      password: anyNamed('password'),
      data: anyNamed('data'),
    )).thenAnswer((_) => throw Exception('internal error'));

    expect(
      () => service.signUp(email: 'error@foo.com', password: 'secret'),
      throwsA(isA<Exception>()),
    );
  });
}
