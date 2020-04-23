import 'package:flutter/material.dart';
import 'package:githubclientapp/common/global.dart';
import 'package:githubclientapp/i10n/localization_intl.dart';
import 'package:githubclientapp/states/profile_change_notifier.dart';
import 'package:provider/provider.dart';
class ThemeChangeRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GmLocalizations.of(context).theme),
      ),
      body: ListView(
        //显示主题色块
        children: Global.themes.map<Widget>((color){
          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 16),
              child: Container(
                color: color,
                height: 40,
              ),
            ),
            onTap: (){
              //主题更新后，materialApp会重新build
              Provider.of<ThemeModel>(context).theme = color;
            },
          );
        }).toList(),
      ),
    );
  }
}
