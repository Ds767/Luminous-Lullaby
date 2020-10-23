import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'dart:async';
import 'readPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luminous Lullaby',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new ShelfPage(),
      locale: Locale('en', 'US'),
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('zh', 'CN'),
      ],
    );
  }
}

class ShelfPage extends StatefulWidget {
  @override
  ShelfPageState createState() => new ShelfPageState();
}

class ShelfPageState extends State<ShelfPage> {
  //存储网址
  List<String> url = <String>[];
  //是否删除网址
  bool flag = true;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    //url.add('https://www.zaohuatu.com/book/5/427.html');
    return new Scaffold(
      appBar: new AppBar(
          title: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: const Text('shelf'),
          ),
          Expanded(
            flex: 4,
            child: TextField(
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'Input url here!',
                hintStyle: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20.0,
                ),
                //fillColor: Colors.black12,
                //filled: true,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (String string) {
                setState(() {
                  url.add(string);
                });
              },
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(flag == true ? Icons.add : Icons.delete),
        onPressed: () {
          setState(() {
            flag = !flag;
          });
        },
      ),
      body: new GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: url.length,
        itemBuilder: (context, int i) {
          if (i < url.length) {
            return new GridTile(
              child: new FlatButton(
                child: Text(url[i]),
                onPressed: () async {
                  if (flag == true) {
                    url[i] = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ReadPage(
                        url: url[i],
                      );
                    }));
                    setState(() {});
                  } else {
                    setState(() {
                      url.removeAt(i);
                    });
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
