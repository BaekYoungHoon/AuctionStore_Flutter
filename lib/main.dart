import 'dart:ffi';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod/riverpod.dart';
import 'firebase_options.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

int Screen = 0;
String? userUid = "";
String? userName = "";

List<String> items = List.generate(100, (index) => "물건 $index");

Future<void> signInWithGoogle(BuildContext context) async {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _account = await _googleSignIn.signIn();
}

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
        home: MyAuthPage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int num = 0; // int로 변경
  List<String> items = List.generate(100, (index) => "물건 $index");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text (
          "방구석 경매        $userName",
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
                Screen = 0;
                num++;
              });
            },
            icon: Icon(Icons.card_travel),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                Screen = 1;
              });
            },
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  Widget BodyView() {
    if (Screen == 0) {
      return ListView.builder(
        itemCount: num,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              setState(() {
                if (items[index] == "물건 클릭")
                  items[index] = "물건 $index";
                else
                  items[index] = "물건 클릭";
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
                      Text("가격"),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Scaffold(
        body: Column(
          children: [
            Text("내정보 만들거임"),
            Row(
              children: [
                Text("로그아웃"),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    _handleSignOut(context);
                  },
                )
              ],
            )
          ],
        ),
      );
    }
  }
}
class MyAuthPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<User?> _handleSignIn(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        return user;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 화면'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final User? user = await _handleSignIn(context);

            if (user != null) {
              // 로그인 성공 시 처리
              await _googleSignIn.signOut();

              Users User = Users(user.displayName, user.uid);
              User.add(user.uid);
              userUid = user.uid;
              userName = user.displayName;
              print('Signed in: ${user.displayName}');
              Navigator.of(context).push(
                  MaterialPageRoute(
                  builder: (context) => MyHomePage()));
            } else {
              // 로그인 실패 시 처리
              print('Sign-in failed.');
            }
          },
          child: Text('구글 로그인'),
        ),
      ),
    );
  }
}
void _handleSignOut(BuildContext context) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MyAuthPage(),
      ),
          (route) => false,
    );
  } catch (e) {
    print("로그아웃 오류: $e");
  }
}

class Users {
  // 멤버 변수 (인스턴스 변수)
  String? name;
  String? Uid;

  // 생성자
  Users(this.name, this.Uid);

  void add(String user) async{
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();

    if (querySnapshot.docs.isNotEmpty) {
      // 컬렉션에 문서가 존재하면 각 문서의 데이터를 출력합니다.
      for (final documentSnapshot in querySnapshot.docs) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        print('사용자 데이터: $data');
        if(documentSnapshot.id == userUid) {
          print("이미 가입된 계정 입니다. \nUID : ${documentSnapshot.id}");
        }else {
          firestore.collection('users').doc(user).set({
            'name': name,
            'Uid': Uid,
          });
        }
      }
    }
  }
  void Read() async{
    final document = await firestore.collection('users').doc('documentId').get();
    if (document.exists) {
      print('Document data: ${document.data()}');
    } else {
      print('Document does not exist');
    }
  }
  void Update() async{
    await firestore.collection('users').doc('documentId').update({
      'name': 'Jane Doe',
    });
  }
  void Delete() async{

  }
}