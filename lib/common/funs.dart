import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
/**
 * 全局工具函数，专门用于获取头像图片
*/

Widget gmAvatar(String url, {
  double width = 30,
  double height = 30,
  BoxFit fit,
  BorderRadius borderRadius,
}){
  var placeholder = Image.asset(
      "imgs/avatar-default.png", //头像默认值
      width: width,
      height: height
  );
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.circular(2),
    child: CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    ),
  );
}

//弹出toast

void showToast(String text, {
  gravity: ToastGravity.CENTER,
  toastLength: Toast.LENGTH_SHORT,
}) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    backgroundColor: Colors.grey[600],
    fontSize: 16.0,
  );
}


//显示等待框
void showLoading(context, [String text]) {
  text = text ?? "Loading...";
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
                boxShadow: [
                  //阴影
                  BoxShadow(
                    color: Colors.black12,
                    //offset: Offset(2.0,2.0),
                    blurRadius: 10.0,
                  )
                ]),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            constraints: BoxConstraints(minHeight: 120, minWidth: 180),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    text,
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2,
                  ),
                ),
              ],
            ),
          ),
        );
      });
}