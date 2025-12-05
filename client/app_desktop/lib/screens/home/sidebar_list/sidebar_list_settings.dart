import 'package:flutter/widgets.dart';

import 'sidebar_list_core.dart';
import 'package:app_desktop/app_state.dart';

class SidebarListSettings extends StatelessWidget {
  const SidebarListSettings({super.key, required this.contacts, required this.onTap});

  final List<Contact> contacts;
  final void Function(Contact contact) onTap;

  @override
  Widget build(BuildContext context) {
    return SidebarListCore(contacts: contacts, onTap: onTap);
  }
}
