import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/controllers/home_controller.dart';
import 'package:user/models/businessLayer/baseRoute.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/app_drawer_wrapper_screen.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/order_history_screen.dart';
import 'package:user/screens/search_screen.dart';
import 'package:user/screens/user_profile_screen.dart';
import 'package:user/widgets/my_bottom_navigation_bar.dart';

class HomeScreen extends BaseRoute {
  final int? screenId;
  final Function? onAppDrawerButtonPressed;
  HomeScreen({super.analytics, super.observer, super.routeName = 'HomeScreen', this.onAppDrawerButtonPressed, this.screenId});
  @override
  _HomeScreenState createState() => _HomeScreenState(onAppDrawerButtonPressed: onAppDrawerButtonPressed, screenId: screenId);
}

class _HomeScreenState extends BaseRouteState {
  int? screenId;
  Function? onAppDrawerButtonPressed;
  final CartController cartController = Get.put(CartController());
  final HomeController homeController = Get.put(HomeController());

  _HomeScreenState({this.onAppDrawerButtonPressed, this.screenId});

  @override
  Widget build(BuildContext context) {
    final List<Widget> _homeScreenItems = [
      AppDrawerWrapperScreen(
        analytics: widget.analytics,
        observer: widget.observer,
      ),
      Container(),
      OrderHistoryScreen(analytics: widget.analytics, observer: widget.observer),
      UserProfileScreen(analytics: widget.analytics, observer: widget.observer),
    ];

    return WillPopScope(
      onWillPop: () async {
        exitAppDialog();
        return false;
      },
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return Scaffold(
            body: IndexedStack(
              index: controller.tabIndex,
              children: _homeScreenItems,
            ),
            bottomNavigationBar: MyBottomNavigationBar(
              onTap: (value) {
                if (value == 1) return Get.to(() => SearchScreen(analytics: widget.analytics, observer: widget.observer));
                if (value == 2) {
                  if (global.currentUser?.id == null) {
                    return Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                  }
                }
                if (value == 3) {
                  if (global.currentUser?.id == null) {
                    return Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                  }
                }

                if (value == 4) {
                  if (global.currentUser?.id == null) {
                    return Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                  }
                }
                controller.changeTabIndex(value);
              },
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add_shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  if (global.currentUser?.id == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(analytics: widget.analytics, observer: widget.observer),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(analytics: widget.analytics, observer: widget.observer),
                      ),
                    );
                  }
                }),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('uID ${global.currentUser!.id}');
    if (screenId == 1) {
      homeController.changeTabIndex(4);
    } else if (screenId == 2) {
      homeController.changeTabIndex(3);
    } else {
      homeController.changeTabIndex(0);
    }
    global.isNavigate = false;
  }
}
