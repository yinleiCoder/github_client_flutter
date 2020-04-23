import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:githubclientapp/common/global.dart';

/**
 * 网络接口缓存:
 * 简单的缓存策略：
 * 将请求的uri作为Key，在一个指定的时间段内对请求的返回值进行缓存，
 * 再设置一个最大缓存数，若超过这个最大缓存数则移除最早的一条缓存，
 * 且还可以提供一种针对特定接口或请求决定是否启用缓存的机制，这个机制
 * 指定哪些请求或哪次请求不应用缓存。
*/

//保存缓存信息
class CacheObject{
  int timeStamp;
  Response response;

  CacheObject(this.response) : timeStamp = DateTime.now().millisecondsSinceEpoch;

  @override
  bool operator ==(other) {
    return response.hashCode==other.hashCode;
  }

  //将请求uri作为缓存key
  @override
  int get hashCode => response.realUri.hashCode;
}

//具体的缓存策略：通过dio的拦截器直接实现缓存策略
//dio包的option.extra是专门用于扩展请求参数的
class NetCache extends Interceptor{
  //为确保迭代器顺序和对象插入时间顺序相同，使用LinkedHashmap
  var cache = LinkedHashMap<String, CacheObject>();

  @override
  Future onRequest(RequestOptions options) async {
    if (!Global.profile.cache.enable) return options;
    //refresh白哦及是否是“下拉刷新”
    bool refresh = options.extra["refresh"] == true;
    //如果是下拉刷新，先删除相关缓存
    if (refresh) {
      if (options.extra["list"]==true) {
        //如果是列表，则只要url中包含当前path的缓存全部删除
        cache.removeWhere((key,v) => key.contains(options.path));
      }else{
        //如果不是列表，则只删除uri相同的缓存
        delete(options.uri.toString());
      }
      return options;
    }
    if (options.extra["noCache"] != true && options.method.toLowerCase() == 'get') {
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      var ob = cache[key];
      if (ob != null) {
        //若缓存未过期，则返回缓存内容
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 < Global.profile.cache.maxAge) {
          return cache[key].response;
        }  else{
          //缓存过期了，删除缓存，继续向服务器请求
          cache.remove(key);
        }
      }
    }
  }

  @override
  Future onResponse(Response response) async {
    //如果启用缓存，将返回结果保存到缓存
    if (Global.profile.cache.enable) {
      _saveCache(response);
    }
  }

  _saveCache(Response obj) {
    RequestOptions options = obj.request;
    if (options.extra["noCache"] != true && options.method.toLowerCase() == "get") {
      //如果缓存数量超过最大数量限制，则应该先移除最早的一条记录
      if (cache.length == Global.profile.cache.maxCount) {
        cache.remove(cache[cache.keys.first]);
      }
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      cache[key] = CacheObject(obj);
    }
  }

  void delete(String key){
    cache.remove(key);
  }
}

