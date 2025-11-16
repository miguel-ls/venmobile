import 'package:app_movil/screens/maestros/catalogo_screen.dart';
import 'package:app_movil/screens/maestros/clientes_screen.dart';
import 'package:app_movil/screens/maestros/precios_screen.dart';
import 'package:app_movil/screens/maestros/punto_venta_screen.dart';
import 'package:app_movil/screens/maestros/tipo_cambio_screen.dart';
import 'package:app_movil/screens/operaciones/nota_credito_screen.dart';
import 'package:app_movil/screens/operaciones/ventas_screen.dart';
import 'package:app_movil/screens/profile_list_screen.dart';
import 'package:app_movil/screens/seguridad/usuarios_pv_screen.dart';
import 'package:app_movil/screens/user_list_screen.dart';
import 'package:app_movil/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlutterLogo(size: 40.0), // Logo
                  SizedBox(height: 10),
                  Text(
                    'Menú Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.folder),
              title: const Text('Maestros'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Tipo de Cambio'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TipoCambioScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Clientes'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ClientesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text('Catálogo'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatalogoScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Precios'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PreciosScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('Punto de venta'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PuntoVentaScreen()),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.business_center),
              title: const Text('Operaciones'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Ventas'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VentasScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Nota de Crédito'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotaCreditoScreen()),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.security),
              title: const Text('Seguridad'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.storefront),
                  title: const Text('Usuarios x PV'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UsuariosPvScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileListScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Usuarios'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserListScreen()),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar sesión'),
              onTap: () {
                authService.clearSessionCookie();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Pantalla de Inicio'),
      ),
    );
  }
}
