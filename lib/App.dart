import 'package:flutter/material.dart';

import 'package:redux_dev_tools/redux_dev_tools.dart';

import 'views/user-view.dart';
import 'bottom_navigation_widget.dart';
import 'model/Store.dart';
import 'common/theme.dart';
import 'views/home/home-view.dart';
import 'views/login/login-view.dart';

class App extends StatelessWidget {
  final DevToolsStore<Store> store;

  App(this.store);

  Widget buildLoginViewPage(BuildContext context) {
    return LoginView();
  }

  Widget buildUserViewPage(BuildContext context) {
    return UserView();
  }

  Widget buildHomeViewPage(BuildContext context) {
    return HomeView();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Provider Demo',
      theme: appTheme,
//        initialRoute: '/',
      home: BottomNavigationWidget(),
      routes: {
        '/home': (context) => buildHomeViewPage(context),
        '/user': (context) => buildUserViewPage(context),
        '/login': (context) => buildLoginViewPage(context),
      },
    );
  }
}
