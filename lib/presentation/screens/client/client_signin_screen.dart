import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientSignInScreen extends StatelessWidget {
  const ClientSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Cliente'),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text == confirmPasswordController.text) {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                    // Navegar a la pantalla principal del cliente
                    Navigator.of(
                      context,
                    ).pushReplacementNamed('/client-dashboard');
                  } catch (e) {
                    print(e);
                    // Mostrar mensaje de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al registrar')),
                    );
                  }
                } else {
                  // Mostrar mensaje de error si las contraseñas no coinciden
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Las contraseñas no coinciden')),
                  );
                }
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
