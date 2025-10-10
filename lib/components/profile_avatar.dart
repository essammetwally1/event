import 'package:cached_network_image/cached_network_image.dart';
import 'package:event/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  const ProfileAvatar({
    super.key,
    required this.radius,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final double inner = radius - 2;

    return CircleAvatar(
      radius: radius,

      child: ClipOval(
        child: SizedBox(
          width: inner * 2,
          height: inner * 2,
          child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,

                  errorWidget: (context, url, error) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      'assets/icons/addprofile.svg',
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    'assets/icons/addprofile.svg',
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
