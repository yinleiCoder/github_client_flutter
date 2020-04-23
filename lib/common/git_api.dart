import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:githubclientapp/common/global.dart';
import 'package:githubclientapp/models/index.dart';

/**
 * 封装网络请求：
 * 一个完整的app可能涉及很多网络请求，为了便于管理，收敛请求入口。
 * 最好的做法就是将所有的网络请求都放到同一个源代码中。
 * 定义了Git类，用于GitHubApi的调用。
 *
 * 调试过程中，需要一些工具来查看网络请求、响应报文，使用网络代理工具
 * 来调试网络相互据问题是主流。
 * 配置代理需要在应用中指定代理服务器的地址和端口，
 * 对于Github使用的https协议，在配置完代理后还应该禁用证书校验。
*/

class Git {

  BuildContext context;
  Options _options;
  //网络请求过程中，可能需要使用当前的context信息，如请求失败时打开一个新路由
  Git([this.context]){
    _options = Options(extra: {"context": context});
  }

  /**
   * 所有的网络请求通过同一个dio实例静态变量发出，
   * 创建dio实例时将github api的基地址和api支持的header进行了全局配置，
   * 所有通过改dio实例发出的请求都会默认使用这些配置。
   */
  static Dio dio = new Dio(BaseOptions(
    baseUrl: 'https://api.github.com/',
    headers: {
      HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
          "application/vnd.github.symmetra-preview+json",
    },
  ));

  /**
   * 哦按段是否为调试环境，做了一些针对调试环境的网络配置（设置代理和禁用证书校验）
   * 这个方法是启动时被调用的Global.init()中会调用的Git.init():
   */
  static void init(){
    //添加缓存插件
    dio.interceptors.add(Global.netCache);
    //设置用户token（可能额外null,代表未登录）
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;

    //调试模式下需要抓包调试，使用代理，并禁用https证书校验
//    if (!Global.isRelease) {
//      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate=
//      (client){
//        client.findProxy = (uri){
//          return "PROXY 10.95.241.180:8888";
//        };
//        //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以需要禁用证书校验
//        client.badCertificateCallback =  (X509Certificate cert, String host, int port) => true;
//      };
//    }
  }

  //登录接口,登录成功后返会用户信息
  Future<User> login(String login, String pwd) async{
    String basic = 'Basic ' + base64.encode(utf8.encode('$login:$pwd'));
    var r = await dio.get(
      "users/$login",
      options: _options.merge(headers: {
        HttpHeaders.authorizationHeader: basic
      }, extra: {
        "noCache": true, //本接口禁用缓存
      }),
    );
    //登录成功后更新公共头（authorization），此后的所有请求都会带上用户身份信息
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    //情况所有缓存
    Global.netCache.cache.clear();
    //更新profile中的token信息
    Global.profile.token = basic;
    return User.fromJson(r.data);
  }

  //获取用户项目列表
  Future<List<Repo>> getRepos({Map<String, dynamic> queryParameters,
  refresh = false}) async{
    if (refresh) {
      //列表下拉刷新，需要删除缓存，拦截器会读取这些信息
      _options.extra.addAll({"refresh": true, "list": true});
    }
    var r = await dio.get<List>(
      "user/repos",
      queryParameters: queryParameters,
      options: _options,
    );
    return r.data.map((e) => Repo.fromJson(e)).toList();
  }
}
