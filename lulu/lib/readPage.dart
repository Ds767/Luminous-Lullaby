import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
//import 'dart:async';

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
    return new WillPopScope(
        child: new Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              _htmlDownload(widget.url);
              return WebView(
                //file:///storage/emulated/0/Android/data/com.ds767.lulu/cache/html.html
                initialUrl:
                    "file:///data/user/0/com.ds767.lulu/cache/html.html",
                javascriptMode: JavascriptMode.unrestricted,
              );
            },
          ),
          floatingActionButton: vActionButton(),
          bottomNavigationBar: vBottomBar(),
        ),
        onWillPop: (){Navigator.pop(context, widget.url);});
  }

  void _htmlDownload(String url) async {
    String string = "";
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.headers.add("uesr-agent", UA);
    HttpClientResponse response = await request.close();
    string = await response.transform(utf8.decoder).join();
//    print(response.headers);
    httpClient.close();

    string = htmlFilter(string);

    await _dataSave(string);

    print('load ok');
  }

  String htmlFilter(String string) {
    string = string.replaceAll(
        RegExp(reg, multiLine: true, caseSensitive: true), ' ');
    string = string.replaceFirst(
        RegExp(reg1, multiLine: true, caseSensitive: true), myJs);
    print('filter ok');
    return string;
  }

  void _dataSave(String string) async {
    Directory directory = await getTemporaryDirectory();
    String dir = directory.path;
    File file = new File('$dir/html.html');
    await file.writeAsString(string);
    print('save ok');
  }
}
