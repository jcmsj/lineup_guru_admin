import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'page_title_widget.dart';
import 'queue_list.dart';
import 'server_url_widget.dart';
import 'second_route.dart';
import 'package:provider/provider.dart';
import 'q_r_view_example.dart';
import 'settings_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => QueueNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ServerUrlNotifier(),
        ),
      ],
      child: MaterialApp(
        theme: customTheme(),
        home: BottomNavBar(),
      ),
    );
  }

  ThemeData customTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 255, 189, 89),
        surface: const Color.fromARGB(255, 64, 55, 52),
        onSurface: Colors.white,
        background: const Color.fromARGB(255, 255, 247, 207),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 255, 235, 150),
        foregroundColor: Colors.black,
      ),
      primaryColor: const Color.fromARGB(255, 255, 189, 89),
      useMaterial3: true,
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.qr_code),
            SizedBox(width: 10),
            Text(
              "Line-Up Guru | Admin",
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTitleWidget(title: "Services"),
        Expanded(
          child: buildFutureBuilderQueues(),
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String serviceName;
  final String iconName;
  const ServiceCard(this.serviceName, this.iconName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: SizedBox(
        height: 150.0, // Adjust the height here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dont use an Icon/IconData since we cant generate a list of available icons in the app. Also The admin needs to visit the google material icons page for the available icons and names
            Text(
              iconName,
              style: const TextStyle(
                fontFamily: "MaterialIcons",
                color: Colors.yellowAccent,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              serviceName,
              style: const TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(height: 125),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          tabIndex = v;
        },
        children: const [
          HomePage(),
          QRViewExample(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.home_outlined, color: Colors.white, size: 35),
          Icon(Icons.qr_code_sharp, color: Colors.white, size: 35),
          Icon(Icons.settings_outlined, color: Colors.white, size: 35),
        ],
        inactiveIcons: const [
          Icon(Icons.home_outlined, color: Colors.black, size: 35),
          Icon(Icons.qr_code_sharp, color: Colors.black, size: 35),
          Icon(Icons.settings_outlined, color: Colors.black, size: 35),
        ],
        color: const Color.fromARGB(255, 255, 235, 150),
        circleColor: const Color.fromARGB(255, 64, 55, 52),
        circleShadowColor: Colors.black,
        elevation: 10,
        height: 90,
        circleWidth: 70,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
    );
  }
}
