import 'dart:ffi';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod/riverpod.dart';
import 'firebase_options.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

int Screen = 0;
String? userUid = "";
String? userName = "";
String? userEmail = "";
int? userCoin = 0;
int itemLength = 0;
String addUser = "";

Future<int> itemsLength(String trade) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance.collection(trade).get();

    final documentCount = querySnapshot.docs.length;
    print('컬렉션 내의 문서 수: $documentCount');
    return itemLength = documentCount;
  } catch (e) {
    print('문서 수 확인 오류: $e');
    return 0;
  }
}

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

Future<void> signInWithGoogle(BuildContext context) async {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _account = await _googleSignIn.signIn();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  itemsLength("allitem");
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
  //List<String> items = List.generate(itemLength, (index) => "물건 $index");
  List<String> items = []; // 아이템 리스트를 저장할 변수
  List<String> price = [];
  List<String> detail= [];
  @override
  void initState() {
    super.initState();
    // initState에서 데이터 가져오기
    fetchItems();
    print(fetchItems());
    print("타이틀 : $items\n가격 : $price\n상세설명 : $detail");
  }
  Future<void> fetchItems() async {
    final itemsList = await getTitle("title");
    final itemsPrice = await getTitle("price");
    final itemsDetail = await getTitle("detail");

    setState(() {
      items = itemsList;
      price = itemsPrice;
      detail = itemsDetail;
    });
  }
  Future<List<String>> getTitle(String item) async {
    List<String> documentsList = [];

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("allitem").get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        documentsList.add(doc.get(item));
        print(documentsList);
      }
    }

    return documentsList;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppView(),
      body: BodyView(),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                Screen = 0;
                itemsLength("allitem");
                print("itemLength 값 : $itemLength");
                print("기존 num = $userCoin");
                //itemLength++;
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
  PreferredSizeWidget AppView() {
    if (Screen == 0) {
      return AppBar(
        backgroundColor: Colors.green[900],
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.legal,
                ),
                Text(
                  "방구석 경매",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$userName 님",
                  style: TextStyle(
                    color: Colors.green[300],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.logout,
                    size: 20,
                  ),
                  style: ButtonStyle(
                    iconSize: MaterialStateProperty.all(1),
                  ),
                  onPressed: () {
                    _handleSignOut(context);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return AppBar(
        backgroundColor: Colors.green[900],
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.user,
                ),
                Text(
                  "내 정보",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$userName 님",
                  style: TextStyle(
                    color: Colors.green[300],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.logout,
                    size: 20,
                  ),
                  style: ButtonStyle(
                    iconSize: MaterialStateProperty.all(1),
                  ),
                  onPressed: () {
                    _handleSignOut(context);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget BodyView() {
    if (Screen == 0) {
      return Stack( // Stack으로 감싸서 리스트뷰와 버튼 겹치게 배치
        children: [
          ListView.builder(
            itemCount: itemLength,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => detailItem(items[index], detail[index], price[index])));
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
                        child: ListTile (
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text(items[index]),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(detail[index]),
                          Text(price[index]),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 50, // 아래 여백 조절
            right: 16, // 오른쪽 여백 조절
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => addItem()));
                print('Button Pressed');
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(), // 원 모양으로 버튼 모양을 변경
                padding: EdgeInsets.all(16.0), // 버튼 내부 여백 조정
                primary: Colors.green[900], // 버튼의 배경색 설정
              ),
              child: Icon(
                Icons.add,
                size: 40, // 아이콘 크기 조정
                color: Colors.white, // 아이콘 색상 설정
              ),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 120,
                  height: 120,
                  color: Colors.grey,
                  child: Icon(
                    FontAwesomeIcons.user,
                    size: 70,
                  )
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "$userName",
                          style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text("$userEmail"),
                      ),
                      Container(
                        child: Text("보유 코인 : $userCoin C"),
                      )
                    ],
                  ),
                )

              ],
            )
          ],
        )
      );
    }
  }

}
class detailItem extends StatelessWidget {
  String? title;
  String? detail;
  String? price;
  String? uid;
  TextEditingController bid = TextEditingController();

  detailItem(String? title, String? detail, String? price){
    this.title = title;
    this.detail = detail;
    this.price = price;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Row(
          children: [
            Icon(Icons.add_shopping_cart),
            Text(
                "상품 상세 정보",
              style: TextStyle(
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        )
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "$title",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 50,
            ),
          ),
          Text(
            "가격 : $price",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 20
            ),
          ),
          Text(
            "$detail",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 30
            ),
          ),
          // Row(
          //   children: [
          //     TextField(
          //       controller: bid,
          //       decoration: InputDecoration(
          //           labelText: '입찰하기', // 텍스트 필드 위에 나타날 레이블
          //           hintText: '입찰 가격을 입력 하세요', // 사용자에게 힌트를 제공할 텍스트
          //           border: OutlineInputBorder()
          //       ),
          //     ),
          //     ElevatedButton(onPressed:() async {
          //
          //     }, child: Text("등록"))
          //   ],
          // )
        ],
      ),
    );
  }
}


class addItem extends StatelessWidget {
String itemName = "";
String price = "";
String detail = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Icon(Icons.add_shopping_cart),
            Text("상품 등록")
          ],
        ),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: '상품 명', // 텍스트 필드 위에 나타날 레이블
              hintText: '상품 명을 입력하세요', // 사용자에게 힌트를 제공할 텍스트
              border: OutlineInputBorder(), // 텍스트 필드 주위에 테두리를 만듦
            ),
            onChanged: (text) {
              // 텍스트가 변경될 때 호출되는 콜백 함수
              itemName = text;
              print('입력된 텍스트: $text');
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '가격', // 텍스트 필드 위에 나타날 레이블
              hintText: '가격을 입력하세요', // 사용자에게 힌트를 제공할 텍스트
              border: OutlineInputBorder(), // 텍스트 필드 주위에 테두리를 만듦
            ),
            onChanged: (text) {
              // 텍스트가 변경될 때 호출되는 콜백 함수
              price = text;
              print('입력된 텍스트: $text');
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '상품 설명', // 텍스트 필드 위에 나타날 레이블
              hintText: '상품 설명을 입력하세요', // 사용자에게 힌트를 제공할 텍스트
              border: OutlineInputBorder(), // 텍스트 필드 주위에 테두리를 만듦
            ),
            onChanged: (text) {
              // 텍스트가 변경될 때 호출되는 콜백 함수
              detail = text;
              print('입력된 텍스트: $text');
            },
          ),
          ElevatedButton(
              onPressed:(){
                itemInfo item = itemInfo(itemName, price, detail);
                item.itemSet(userUid);
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => MyHomePage()));
                print("상품 명 : $itemName\n가격 : $price\n상품설명 : $detail\n판매자 정보 : $userUid");
              },
              child: Text("등록")
          )
        ],
      ),
    );
  }
}

class MyAuthPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text('로그인 화면'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final User? user = await _handleSignIn(context);

            if (user != null) {
              // 로그인 성공 시 처리
              await _googleSignIn.signOut();


              Users User = Users(user.displayName, user.uid, user.email);
              User.addUser(user.uid);
              userUid = user.uid;
              userName = user.displayName;
              userEmail = user.email;
              final userDoc = await firestore.collection("users").doc(userUid).get();
              userCoin = userDoc.data()?['coin'];

              print("point : $userCoin");
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
class getData{
  String? uid = "";
  
}
class itemInfo{
  String? title;
  String? price;
  String? detail;
  String? myInfo;

  itemInfo(this.title, this.price, this.detail);

  void itemSet(String? UID) async{
    await firestore.collection('allitem').doc(this.title).set({
      'title' : this.title,
      'price' : this.price,
      'detail': this.detail,
      'uid'   : UID
    });
  }
  void Update(String title, String price, String detail, String docID) async{
    await firestore.collection('allitem').doc(docID).update({
      'title': title,
      'price': price,
      'detail': detail
    });
  }

}
class Users {
  // 멤버 변수 (인스턴스 변수)
  String? name;
  String? Uid;
  String? email;
  int? coin = userCoin;
  // 생성자
  Users(this.name, this.Uid, this.email);

  void addUser(String user) async{
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();

    if (querySnapshot.docs.isNotEmpty) {
      // 컬렉션에 문서가 존재하면 각 문서의 데이터를 출력합니다.
      for (final documentSnapshot in querySnapshot.docs) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        print('사용자 데이터: $data');
        if(documentSnapshot.id == userUid) {
          print("이미 가입된 계정 입니다. \nUID : ${documentSnapshot.id}");
        }else {
          if(coin == null){
            coin = 0;
          }
          firestore.collection('users').doc(user).set({
            'name': name,
            'Uid': Uid,
            'email' : email,
            'coin' : userCoin
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
  //UID 비교 함수
  void getData(String itemKey) async{
    final UID = await firestore.collection("allitem");
  }
  void itemSet(String title, String price, String detail) async{
    await firestore.collection('allitem').doc(title).set({
      'title' : title,
      'price' : price,
      'detail': detail
    });
  }
  void Update() async{
    await firestore.collection('users').doc('documentId').update({
      'name': 'Jane Doe',
    });
  }
  void Delete() async{

  }
}
