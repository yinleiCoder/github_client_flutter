import 'package:flutter/material.dart';
import 'package:githubclientapp/common/global.dart';
import 'package:githubclientapp/i10n/localization_intl.dart';
import 'package:githubclientapp/routes/home_page.dart';
import 'package:githubclientapp/routes/language.dart';
import 'package:githubclientapp/routes/login.dart';
import 'package:githubclientapp/routes/theme_change.dart';
import 'package:githubclientapp/states/profile_change_notifier.dart';
import 'package:provider/provider.dart';


//确保Global.init()不能抛出异常，否则程序执行不到runApp()
void main() => Global.init().then((e) => {
  runApp(MyApp()),
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider.value(value: ThemeModel()),
        ChangeNotifierProvider.value(value: UserModel()),
        ChangeNotifierProvider.value(value: LocalModel()),
      ],
      child: Consumer2<ThemeModel, LocalModel>(//material app消费依赖了ThemeModel, LocalModel，所以当app主题或语言发生改变时material app会重建。
        builder: (BuildContext context, themeModel, localeModel, Widget child){
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: themeModel.theme,
            ),
            onGenerateTitle: (context){
              return GmLocalizations.of(context).title;
            },
            home: HomeRoute(),
            locale: localeModel.getLocale(),
            supportedLocales: [
              const Locale('en', 'US'), // 美国英语
              const Locale('zh', 'CN'), // 中文简体
              //其它Locales
            ],
            localizationsDelegates: [
              // 本地化的代理类
//              GlobalMaterialLocalizations.delegate,
//              GlobalWidgetsLocalizations.delegate,
              GmLocalizationsDelegate()
            ],
            localeResolutionCallback: (Locale _locale, Iterable<Locale> supportedLocales) {
              if (localeModel.getLocale() != null) {
                //如果已经选定语言，则不跟随系统
                return localeModel.getLocale();
              } else {
                //跟随系统
                Locale locale;
                if (supportedLocales.contains(_locale)) {
                  locale= _locale;
                } else {
                  //如果系统语言不是中文简体或美国英语，则默认使用美国英语
                  locale= Locale('en', 'US');
                }
                return locale;
              }
            },
            //注册路由表
            routes: <String, WidgetBuilder>{
              "login": (context) => LoginRoute(),
              "themes": (context) => ThemeChangeRoute(),
              "language": (context) => LanguageRoute(),
            },
          );
        },
      ),
    );
  }
}
