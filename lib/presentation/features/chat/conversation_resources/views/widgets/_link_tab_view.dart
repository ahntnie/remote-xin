part of '../conversation_resources_view.dart';

class _LinkTabView extends StatelessWidget {
  const _LinkTabView({
    required this.controller,
  });

  final ConversationResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.links.isEmpty) {
        return Center(
          child: Text(
            context.l10n.conversation_resources__no_links,
            style: AppTextStyles.s16w500,
          ),
        );
      }

      return ListView.separated(
        padding: AppSpacing.edgeInsetsH20,
        itemCount: controller.links.length,
        separatorBuilder: (context, index) => AppSpacing.gapH16,
        itemBuilder: (context, index) {
          final link = controller.links[index];

          return AnyLinkPreview(
            link: link,
            cache: const Duration(days: 5),
            bodyMaxLines: 5,
            backgroundColor: Colors.white,
            titleStyle: AppTextStyles.s16w600.text2Color,
            bodyStyle: AppTextStyles.s12w400.subText2Color,
          );
        },
      );
    });
  }
}
