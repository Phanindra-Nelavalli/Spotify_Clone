import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/basic_app_bar.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/presentation/bloc/profile_info_cubit.dart';
import 'package:spotify/presentation/bloc/profile_info_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Scaffold(
        appBar: BasicAppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff2C2B2B),
          action: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 29),
          ),
        ),
        body: Column(
          children: [
            _profileInfo(context),
            // Add other parts of profile body here
          ],
        ),
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
        builder: (context, state) {
          if (state is ProfileInfoLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileInfoLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        state.userEntity.imageURL ?? AppUrls.defaultImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(state.userEntity.email!),
                const SizedBox(height: 10),
                Text(
                  state.userEntity.fullName!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ],
            );
          }
          if (state is ProfileInfoLoadingfailure) {
            return const Center(child: Text("Please try again rlater"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
