import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:souvenir/screens/journal_writing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu'),
              ),
              ListTile(title: const Text('Item 1'), onTap: () {}),
              ListTile(title: const Text('Item 2'), onTap: () {}),
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              snap: false,
              stretch: true,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                // centerTitle: true,
                // titlePadding: EdgeInsets.only(bottom: 100),
                title: const Text(
                  'Folders',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                background: Container(
                  color: Colors.blue,
                  child: Positioned(
                    bottom: -50,
                    left: 10,
                    child: Text(
                      "41 notes",
                      // ignore: deprecated_member_use
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                return ListTile(title: Text('Item $index'));
              }, childCount: 50),
            ),
          ],
        ),
      
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit),
          onPressed: () {
            Get.to(JournalWritingScreen(title: "",));
          },
        ),
      ),
    );
  }
}
