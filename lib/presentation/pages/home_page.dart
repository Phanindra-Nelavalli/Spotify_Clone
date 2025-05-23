import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/basic_app_bar.dart';
import 'package:spotify/core/configs/assets/app_images.dart';
import 'package:spotify/core/configs/assets/app_vectors.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/presentation/pages/profile_page.dart';
import 'package:spotify/presentation/widgets/latest_songs.dart';
import 'package:spotify/presentation/widgets/play_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: SvgPicture.asset(AppVectors.logo, height: 35, width: 35),
        hideBack: true,
        action: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ProfilePage(),
              ),
            );
          },
          icon: Icon(Icons.person),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _homeTopCard(),
            _tabBar(),
            SizedBox(
              height: 195,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: LatestSongs(),
                  ),
                 
                ],
              ),
            ),
            SizedBox(height: 40),
            PlayList(),
          ],
        ),
      ),
    );
  }

  Widget _homeTopCard() {
    return Center(
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(AppVectors.homeTopCard),
            ),
            Padding(
              padding: EdgeInsets.only(right: 60),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(AppImages.homeArtist),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      dividerColor: Colors.transparent,
      indicatorColor: AppColors.primary,
      labelColor: context.isDarkMode ? Colors.white : Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      dragStartBehavior: DragStartBehavior.down,
      tabs: [
        Text(
          'Latest',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        ),
        // Text(
        //   'Video',
        //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        // ),
        // Text(
        //   'Artist',
        //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        // ),
        // Text(
        //   'Podcast',
        //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        // ),
      ],
    );
  }
}
