import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:potato_leaf/dialog/LoadingDialog.dart';
import 'package:potato_leaf/entity/LeafColor.dart';
import 'package:potato_leaf/entity/Result.dart';
import 'package:potato_leaf/router/DialogRouter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isOpen = false;
  String _imgPath = "";

  static Result result = Result("", "", "", "");

  late AnimationController _rotateController;
  late AnimationController _shakeController;

  @override
  initState() {
    _rotateController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 10));
    super.initState();
  }

  @override
  dispose() {
    _rotateController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  _predict() async {
    var formData =
        FormData.fromMap({"file": await MultipartFile.fromFile(_imgPath)});
    var dio = Dio();
    Result res;
    try {
      Navigator.push(context, DialogRouter(const LoadingDialog()));
      var response = await dio.post("https://potato.lzfblog.cn:8080/predict",
          data: formData);
      var jsonObj = json.decode(response.toString());
      res = Result.parse(jsonObj);
      // 设置颜色
      switch (res.type ?? "") {
        case "早疫病":
          res.color = LeafColor.EARELY;
          break;
        case "晚疫病":
          res.color = LeafColor.LATELY;
          break;
        case "健康":
          res.color = LeafColor.NORMAL;
          break;
        default:
          res.color = Colors.transparent;
      }
      if (res.code != 200) {
        throw Exception("服务器出现错误");
      }
      setState(() {
        result = res;
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "服务器异常，请求出现错误!");
    } finally {
      Navigator.pop(context);
    }
  }



/*拍照*/
  _takePhoto() async {
    var image = await ImagePicker.platform.getImage(source: ImageSource.camera);
    setState(() {
      _imgPath = image!.path;
    });
    _predict();
  }

  // 浮动按钮组
  _floatButtons() {
    Animation rotateAnimation = Tween(begin: 0.0, end: -6.28)
        .chain(
          CurveTween(curve: Curves.easeIn),
        )
        .animate(_rotateController);

    Animation shakeAnimation = Tween(begin: -3.0, end: 3.0)
        .chain(CurveTween(curve: Curves.linear))
        .animate(_shakeController);

    return SizedBox(
      width: double.infinity,
      height: 150,
      // color: Colors.grey[200],
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
              onEnd: () async {
                if (isOpen) {
                  _rotateController.forward();
                } else {
                  _shakeController.repeat();
                  await Future.delayed(const Duration(milliseconds: 200));
                  _shakeController.reset();
                  _rotateController.reset();
                }
              },
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticIn,
              alignment: Alignment(isOpen ? -0.4 : 0, isOpen ? -0.3 : 0.6),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                curve: Curves.bounceOut,
                opacity: isOpen ? 1 : 0,
                child: AnimatedBuilder(
                  animation: rotateAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.rotate(
                      angle: rotateAnimation.value,
                      child: FloatingActionButton(
                          heroTag: '_penGallery',
                          onPressed: () {
                            _openGallery();
                          },
                          child: const Icon(Icons.photo)),
                    );
                  },
                ),
              )),
          AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            alignment: Alignment(isOpen ? 0.4 : 0, isOpen ? -0.3 : 0.6),
            child: AnimatedOpacity(
              curve: Curves.bounceOut,
              duration: const Duration(milliseconds: 800),
              opacity: isOpen ? 1 : 0,
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (BuildContext context, Widget? child) {
                  return Transform.rotate(
                    angle: -rotateAnimation.value,
                    child: FloatingActionButton(
                        heroTag: '_takePhoto',
                        onPressed: () {
                          _takePhoto();
                        },
                        child: const Icon(Icons.camera)),
                  );
                },
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _shakeController,
            builder: (BuildContext context, Widget? child) {
              return Transform.translate(
                offset: Offset(shakeAnimation.value, 0),
                child: Align(
                  alignment: const Alignment(0, 0.6),
                  child: FloatingActionButton(
                    heroTag: '_setState',
                    onPressed: () {
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    child: AnimatedSwitcher(
                        transitionBuilder: (child, anim) {
                          return RotationTransition(
                            child: child,
                            turns: anim,
                          );
                        },
                        duration: const Duration(milliseconds: 500),
                        child: isOpen
                            ? Icon(
                                Icons.highlight_off,
                                key: UniqueKey(),
                              )
                            : const Icon(Icons.mood)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /*相册*/
  _openGallery() async {
    var image =
        await ImagePicker.platform.getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    setState(() {
      _imgPath = image.path;
    });
    _predict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: _floatButtons(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          title: const Text("首页"),
        ),
        body: Center(
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 400,
              height: 500,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35.0),
                          color: Colors.grey[100],
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0.0, 10.0),
                                blurRadius: 20.0,
                                spreadRadius: 1.0)
                          ]),
                      child: Container(
                        constraints:
                            const BoxConstraints(minHeight: 240, maxWidth: 240),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: 220,
                            constraints: const BoxConstraints(
                              maxHeight: 240,
                            ),
                            child: _imgPath != ""
                                ? Image.file(
                                    File(_imgPath),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    "https://pic3.zhimg.com/v2-08a5b40e2082c29441cd176ee4eafdee_b.jpg",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(15.0),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    // Text(_debug ? result:""),
                    Text(
                      "${result.type},${result.conf}",
                      style: TextStyle(
                        fontSize: 28.0,
                        color: result.color ?? Colors.transparent,
                      ),
                    )
                  ],
                ),
              )),
        ));
  }
}
// http://172.17.60.44:8080
