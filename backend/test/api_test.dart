import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/src/routes/api_routes.dart';

void main() {
  group('API Routes Tests', () {
    late Router router;

    setUp(() {
      router = ApiRoutes().router;
    });

    test('Health check endpoint returns 200', () async {
      final request = Request('GET', Uri.parse('http://localhost/health'));
      final response = await router(request);

      expect(response.statusCode, equals(200));
    });

    test('GET /api/users returns users list', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/users'));
      final response = await router(request);

      expect(response.statusCode, equals(200));
      expect(response.headers['content-type'], contains('application/json'));
    });

    test('POST /api/auth/login requires email and password', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/auth/login'),
        body: '{}',
      );
      final response = await router(request);

      expect(response.statusCode, equals(400));
    });
  });
}
