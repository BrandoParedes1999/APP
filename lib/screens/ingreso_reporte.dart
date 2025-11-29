import 'package:flutter/material.dart';

class IngresoReporte extends StatefulWidget {
  const IngresoReporte({super.key});

  @override
  State<IngresoReporte> createState() => _IngresoReporteState();
}

class _IngresoReporteState extends State<IngresoReporte> {
  // Datos Falsos (Imitando que vienen de alguna parte)
  final String diaReporte = "lunes";
  final int cantPedicure = 3;
  final int cantManicure = 7;
  final double totalDia = 2350.00; // Total de los servicios del día

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 

      // 1. APPBAR: Encabezado simple, imitando el diseño de la imagen
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), 
        child: Padding(
          padding: const EdgeInsets.only(top: 35.0, left: 10.0), 
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              SizedBox(width: 15), 
              // Título principal
              const Text(
                "REPORTES",
                style: TextStyle(
                  fontSize: 27, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black, 
                ),
              ),
            ],
          ),
        ),
      ),
      // 2. BODY: ListView para permitir scroll
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              Container(
                width: double.infinity, 
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20), 
                padding: EdgeInsets.all(30), 
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(30), 
                  border: Border.all(width: 2, color: Colors.black), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Text(
                      diaReporte, 
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "SERVICIOS",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      "Pedicure", 
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Cant.", 
                      style: TextStyle(fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                         print("Dato falso: Cantidad de Pedicure vendida: $cantPedicure");
                      },
                      child: Text(
                        "-> ${cantPedicure.toString()} unidades vendidas ", 
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 20),
                    // DETALLE MANICURE
                    Text(
                      "Manicure", 
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Cant.", 
                      style: TextStyle(fontSize: 16),
                    ),
                     // Dato falso bebe
                     InkWell(
                      onTap: () {
                         print("Dato falso: Cantidad de Manicure vendida: $cantManicure");
                      },
                      child: Text(
                        "-> ${cantManicure.toString()} unidades vendidas ", 
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 100), 
                    // TOTAL
                    Text(
                      "TOTAL",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$", // Símbolo de moneda
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      totalDia.toStringAsFixed(2), 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 50),
                    // BOTÓN PDF
                    Center( 
                      child: InkWell(
                        onTap: () {
                          // Dato Falso: el cual Imprime en la consola
                          print("Generando PDF para el día $diaReporte. Total: \$${totalDia.toStringAsFixed(2)}");
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 100, 
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black, 
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "PDF",
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), 
                  ],
                ),
              ),
              SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }
}