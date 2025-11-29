import 'package:flutter/material.dart';
import 'package:paulette/services/auth_service.dart';

class Registre extends StatefulWidget {
  const Registre({super.key});

  @override
  State<Registre> createState() => _RegistreState();
}

class _RegistreState extends State<Registre> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  
  // Variables para dropdowns
  String? _tieneDiabetes;
  String? _tieneAlergia;
  
  // Estados
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      nombre: _nameController.text,
      telefono: _phoneController.text,
      telefono2: _phone2Controller.text.isEmpty ? null : _phone2Controller.text,
      tieneDiabetes: _tieneDiabetes!,
      tieneAlergia: _tieneAlergia!,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Registro exitoso! Ya puedes iniciar sesión'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Regresar al login
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al registrarse'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 25),
              
              Center(
                child: Text("Nombre", style: TextStyle(fontSize: 17)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              Center(child: Text("Correo", style: TextStyle(fontSize: 17))),
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              Center(
                child: Text("Contraseña", style: TextStyle(fontSize: 17)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              Center(
                child: Text("Teléfono", style: TextStyle(fontSize: 17)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu teléfono';
                        }
                        if (value.length < 10) {
                          return 'Ingresa un teléfono válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              Center(
                child: Text("Teléfono 2 (opcional)", style: TextStyle(fontSize: 17)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: TextFormField(
                      controller: _phone2Controller,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Text("¿Tiene diabetes?", style: TextStyle(fontSize: 17)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
                      value: _tieneDiabetes,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      hint: Text("Seleccione una opción"),
                      items: ['Sí', 'No'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _tieneDiabetes = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona una opción';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              Center(
                child: Text("¿Tiene alguna alergia?", style: TextStyle(fontSize: 17)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
                      value: _tieneAlergia,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      hint: Text("Seleccione una opción"),
                      items: ['Sí', 'No'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _tieneAlergia = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona una opción';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.all(25),
                child: Center(
                  child: SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Registrar",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("¿Ya tienes cuenta? Inicia sesión"),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}