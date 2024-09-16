//import 'dart:async';
//import 'package:provider/provider.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmap/location_services.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
void main(){
  runApp(const MyApp());
  //runApp(const MyApp(homeScreen: MapSample()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>LocationService()),
      ],
      child: const MaterialApp(
        title:"  Google Map ",
        home: TestPage(),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> const  MapSample())
              );
            }, child: Text('GoTO'))
          ],
        ),
      ),

    );

  }
}

//-----------USING PROVIDER------------------//
/*
class MyApp extends StatefulWidget {
  final Widget? homeScreen;
  const MyApp({Key? key, this.homeScreen}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => MapSample()),
    ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: widget.homeScreen,
      ),
    );

  }

}*/

