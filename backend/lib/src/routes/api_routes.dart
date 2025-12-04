import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';

class ApiRoutes {
  Router get router {
    final router = Router();

    // Auth routes
    router.post('/auth/login', AuthController.login);
    router.post('/auth/register', AuthController.register);
    router.post('/auth/refresh', AuthController.refreshToken);

    // User routes
    router.get('/users', UserController.getAll);
    router.get('/users/search', UserController.search);
    router.get('/users/<id>', UserController.getById);
    router.post('/users', UserController.create);
    router.put('/users/<id>', UserController.update);
    router.delete('/users/<id>', UserController.delete);

    // Add more routes as needed
    // Example:
    // router.mount('/posts/', PostRoutes().router);

    return router;
  }
}
