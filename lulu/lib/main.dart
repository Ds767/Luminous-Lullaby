import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//常量
const String UA =
    r"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36";

const String myJs = r"""
<script> 
var as=document.querySelectorAll("a[href]");
var i=0;
var patt=/下一/;
for(i=0;as[i];++i)
{
if(patt.test(as[i].innerHTML))
{
var res=document.createElement("a");
res.id="res";
res.style="position:fixed;z-index:1;top:300px;right:10px;";
res.href=as[i].href;
res.innerHTML="<button>翻</button>";
document.body.appendChild(res);
}
}
</script>
</html>
""";

const String reg =
    r"<script[\s\S]*?>[\s\S]*?</script>|<meta[\s\S]*?>|<link[\s\S]*?>|\n";
const String reg1 = r'</html>';
//常量

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

class ReadPage extends StatefulWidget {
  ReadPage({
    Key key,
    this.url,
  }) : super(key: key);
  @override
  ReadPageState createState() => new ReadPageState();
  String url;
}

class ReadPageState extends State<ReadPage> {
  //String url;
  bool isVisible = true;

  Widget vActionButton() {
    return Visibility(
        visible: isVisible,
        child: FloatingActionButton(
          onPressed: buttonClick,
        ));
  }

  Widget vBottomBar() {
    return Visibility(
      visible: !isVisible,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24.0,
        currentIndex: 2,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
              color: Color(0xFFA88465),
            ),
            title: const Text('shelf'),
            //backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            //backgroundColor: Colors.blue,
            icon: Icon(
              Icons.bookmark,
              color: Colors.red,
            ),
            title: const Text('note'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.move_to_inbox,
              color: Colors.green,
            ),
            title: const Text('hide'),
          ),
        ],
        onTap: (index) {
          bottomClick(index);
        },
      ),
    );
  }

  void buttonClick() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  void bottomClick(int index) {
    switch (index) {
      case 0:
        {
          Navigator.pop(context, widget.url);
        }
        break;
      case 1:
        {
          //跳转至笔记页面
          /*
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NotePage();
          }));
          */
        }
        break;
    }
    buttonClick();
  }

  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return WebView(
            //initialUrl: "data/user/0/com.ds767.lulu/cache/html.html",
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: ((WebViewController controller) {
              _htmlDownload(widget.url);
            }),
          );
        },
      ),
      floatingActionButton: vActionButton(),
      bottomNavigationBar: vBottomBar(),
    );
  }

  void _htmlDownload(String url) async {
    String string = "";
    try {
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      request.headers.add("uesr-agent", UA);
      HttpClientResponse response = await request.close();
      string = await response.transform(utf8.decoder).join();
      //print(response.headers);
      httpClient.close();
    } catch (e) {}
    string = htmlFilter(string);
    Directory directory = await getTemporaryDirectory();
    String dir = directory.path;
    File file = new File('$dir/html.html');
    await file.writeAsString(string);
    //print(dir);

    //_webViewController.loadUrl('file://$dir/html.html');
//    print(Uri.dataFromString(string,
//        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
//        .toString());

//    _webViewController.loadUrl(Uri.dataFromString(string,
//            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
//        .toString());
  }

  String htmlFilter(String string) {
    print(string.length);
    string = string.replaceAll(
        RegExp(reg, multiLine: true, caseSensitive: true), ' ');
    string = string.replaceFirst(
        RegExp(reg1, multiLine: true, caseSensitive: true), myJs);
    print(string);
    return string;
  }
}
