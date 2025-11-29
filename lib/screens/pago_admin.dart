import 'package:flutter/material.dart';

class FormasPago extends StatelessWidget {
  const FormasPago({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5.0,
        title: Text(
          "Formas de Pago",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8.0),
        child: ListView(
          children: [

            Padding(
              padding: EdgeInsets.all(50),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text("EN EFECTIVO"),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    
                    children: [
                      Text("TRANSFERENCIAS"),
                      const SizedBox(height: 20),
                      Text("5522 4455 3355 8855"),
                      Text("MARCOS MARTINEZ SALAZAR"),
                      const SizedBox(height: 20),
                      Text("MANDAR EL COMPROBANTE AL:"),
                      Text("9382222222"),

                    ],
                  )
              

                ),
              ),
            ),


          ],
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Spacer(),
            InkWell(
              onTap: (){},
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit),
                    Text("Cambiar Tarjeta", style: TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ),
            Spacer(),
          ],
          
        )
      ],
    );
  }
}
