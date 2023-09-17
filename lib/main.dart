import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

int Screen = 0;
int num = 0;
List<String> items = List.generate(100, (index) => "물건 $index");
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ActionStore",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: BodyView(),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                num++;
                Screen = 0;
              });
            },
            icon: Icon(Icons.card_travel),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                num = num + num;
                Screen = 1;
              });
            },
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }
  Widget BodyView(){
    if(Screen == 0){
      return ListView.builder(
            itemCount: num, // 항목의 수
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    if(items[index] == "물건 클릭") items[index] = "물건 $index";
                    else items[index] = "물건 클릭";
                  });
                },
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.7,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text(items[index]),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("물건"),
                          Text("가격")
                        ],
                      )
                    ],
                  ),

                ),
              );
            },
          );
    }else return Scaffold(
      body: Text("아이템 등록 할거임"),
    );
  }
}
