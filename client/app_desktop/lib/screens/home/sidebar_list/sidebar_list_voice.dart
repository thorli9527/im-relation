import 'package:app_desktop/app_state.dart';
import 'package:flutter/widgets.dart';

import 'sidebar_list_core.dart';

class SidebarListVoice extends StatelessWidget {
  const SidebarListVoice({super.key, required this.contacts, required this.onTap});

  final List<Contact> contacts;
  final void Function(Contact contact) onTap;

  @override
  Widget build(BuildContext context) {
    return SidebarListCore(
      contacts: contacts,
      onTap: onTap,
      topArea: SidebarSearchBox(
        hintText: 'Search',
        onChanged: (_) {},
      ),
    );
  }
}
