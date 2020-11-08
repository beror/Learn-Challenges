import 'package:flutter/material.dart'; 
  
void main() { 
  runApp(GeeksForGeeks());
} 
  
class GeeksForGeeks extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp( 
      home: Center( 
        child: Text('Hello World') 
      ),
    );
  }
}
