import 'package:app_movil/screens/profile_list_screen.dart';
import 'package:app_movil/screens/user_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menú'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ExpansionTile(
              title: Text('Seguridad'),
              children: <Widget>[
                ListTile(
                  title: Text('Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileListScreen()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Usuarios'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserListScreen()),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.pop(context); // Vuelve a la pantalla de login
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Pantalla de Inicio'),
      ),
    );
  }
}
