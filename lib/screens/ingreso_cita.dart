import 'package:flutter/material.dart';

class IngresoCita extends StatefulWidget {
  const IngresoCita({super.key});

  @override
  State<IngresoCita> createState() => _IngresoCitaState();
}

class _IngresoCitaState extends State<IngresoCita> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          // Bloque de la Imagen / Diseño
          Container(
            height: 180,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: Color(0xFFE6E3E3), 
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                "assets/images/logo_principal.png",
                height: 150,
              ),
            ),
          ),

          // Contenedor de los Textos 
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nombre: Raúl Jiménez Sanches Rodriguez", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Servicio: Aplicación Acrílico", 
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Horario: 11:00 AM - 12:30 PM", 
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Alergias: No aplica", 
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "Diabetes: Sí", 
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 40), 
          // Sección Inferior (Personalizado, Uña Natural y Botón)
          Container(
            padding: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFF000000), width: 8.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Personalizado",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                
                Text(
                  "Uña Natural (Color: Rojo Cereza)", // Dato Falso
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 80), 

                // Botón "Finalizar Cita"
                Container(
                  width: double.infinity, 
                  margin: EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      print("aqui va el enlace");//tambien se puede usar otro tipo de boton o una clase nueva void y hacer el llamado aqui solamente
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF000000), // Fondo negro como en el diseño
                      foregroundColor: const Color(0xFFFFFFFF),
                      elevation: 5,
                    ),
                    child: Text(
                      "Finalizar Cita",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
