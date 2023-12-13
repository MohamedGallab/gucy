import 'package:flutter/material.dart';
import 'package:gucy/main_widgets/main_drawer.dart';

import 'nav_bar.dart';
import 'tab_bar_views.dart';
import 'tab_bars.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  var tabControllers = <TabController>[];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < tabBars.length; i++) {
      tabControllers.add(TabController(vsync: this, length: tabBars[i].length));
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < tabControllers.length; i++) {
      tabControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        child: MainDrawer(),
      ),
      appBar: AppBar(
          title: Text('Gucy'),
          bottom: TabBar(
            controller: tabControllers[_currentPageIndex],
            tabs: tabBars[_currentPageIndex],
          )),
      body: TabBarView(
        controller: tabControllers[_currentPageIndex],
        children: tabBarViews[_currentPageIndex],
      ),
      bottomNavigationBar: NavBar(
        currentPageIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
}
