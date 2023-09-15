import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int num = 1;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text(
              "ActionStore",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,  // 글꼴 두께 (볼드)
                fontStyle: FontStyle.italic,  // 글꼴 스타일 (이탤릭)
              )
          )
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children : [
          TextButton(
            onPressed: (){
              setState(() {
                num = 1;
              });
            },
            child: Text("$num"),
          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              onPressed: (){
                setState((){
                  num++;
                });
              },
              icon: Icon(Icons.card_travel)),
          IconButton(onPressed:(){
            setState(() {
              num = num + num;
            });
          },
              icon: Icon(Icons.account_circle)
          )
        ],
      ),
    );
  }
}
