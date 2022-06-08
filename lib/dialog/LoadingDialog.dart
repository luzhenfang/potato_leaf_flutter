import 'package:flutter/material.dart';

class LoadingDialog extends Dialog {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Container(
              decoration: const ShapeDecoration(
                  color: Color(0xffffffff),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                  )
              ),
              child: Column(
                children: const [
                  SizedBox(
                    height: 30,
                  ),
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Text("推理中...")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}