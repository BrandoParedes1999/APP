import 'package:flutter/material.dart';

class Payment extends StatelessWidget {
  const Payment({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'FORMAS DE PAGO',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EFECTIVO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'EN EFECTIVO',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Cuadro de transferencia
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Column(
                  children: [
                    Text(
                      //POR AHORA ES POR TEXTO, AQUI MISMO SE PUEDE PEGAR LA CONEXION DE LA BD.
                      'TRANSFERENCIA',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text('9845 9632 5965 4896'),
                    Text('MARCOS MARTÍNEZ SALAZAR'),
                    SizedBox(height: 10),
                    Text('MANDAR COMPROBANTE AL:'),
                    Text('938 125 4635'),
                  ],
                ),
              ),


            SizedBox(height: 300),
              // Botón INICIO
             Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {},
                    child: Text(
                      "Inicio",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
             ),
            ],
          ),
        ),
      ),
    );
  }
}