import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:githubclientapp/common/funs.dart';
import 'package:githubclientapp/common/git_api.dart';
import 'package:githubclientapp/i10n/localization_intl.dart';
import 'package:githubclientapp/models/index.dart';
import 'package:githubclientapp/states/profile_change_notifier.dart';
import 'package:githubclientapp/widgets/repo_item.dart';
import 'package:provider/provider.dart';

/**
 * 主页
 */
class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GmLocalizations.of(context).home),
      ),
      body: _buildBody(),
      drawer: MyDrawer(),
    );
  }

  Widget _buildBody() {
    UserModel userModel = Provider.of<UserModel>(context);
    if (!userModel.isLogin) {
      //用户未登录，显示登录按钮
      return Center(
        child: RaisedButton(
          onPressed: () => Navigator.of(context).pushNamed("login"),
          child: Text(GmLocalizations.of(context).login),
        ),
      );
    }else {
      //已经登录，显示列表项目
      return InfiniteListView<Repo>(
        onRetrieveData: (int page, List<Repo> items, bool refresh) async {
          var data = await Git(context).getRepos(
            refresh: refresh,
            queryParameters: {
              'page': page,
              'page_size': 20,
            },
          );
          //把请求到的新数据添加到items中
          items.addAll(data);
          return data.length>0 && data.length % 20 == 0;
        },
        itemBuilder: (List list, int index, BuildContext ctx){
          //项目信息列表项
          return RepoItem(repo: list[index],);
        },
      );
    }
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(),
              Expanded(
                child:_buildMenus(),
              )
            ],
          ),
      ),
    );
  }

  /**
   * 构建抽屉菜单头部
   */
  Widget _buildHeader() {
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel value, Widget child){
        return GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(top: 40,bottom: 20),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipOval(
                    //如果已经登录，则显示用户头像，否则显示默认头像
                    child: value.isLogin ? gmAvatar(value.user.avatar_url, width: 80,height: 80)
                    : Image.asset(
                      "imgs/avatar-default.png",
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                Text(
                  value.isLogin ? value.user.login : GmLocalizations.of(context).login,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          onTap: (){
            if (!value.isLogin) {
              Navigator.of(context).pushNamed("login");
            }  
          },
        );
      },
    );
  }

/**
 * 构建功能菜单
 */
  Widget _buildMenus(){
      return Consumer<UserModel>(
        builder: (BuildContext context, UserModel userModel, Widget child){
          var gm = GmLocalizations.of(context);
          return ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text(gm.theme),
                onTap: () => Navigator.pushNamed(context, "themes"),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(gm.language),
                onTap: () => Navigator.pushNamed(context, "language"),
              ),
              if (userModel.isLogin) ListTile(
                leading: const Icon(Icons.power_settings_new),
                title: Text(gm.logout),
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (ctx){
                      //退出账号前的2次确认
                      return AlertDialog(
                        content: Text(gm.logoutTip),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(gm.cancel),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text(gm.yes),
                            onPressed: () {
                              //该赋值语句会触发MaterialApp rebuild
                              userModel.user = null;
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
            ],
          );
        },
      );
  }

}


