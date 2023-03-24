import 'package:flutter/material.dart';
import 'package:mynotes/router/routes.dart';
import 'package:mynotes/views/home/home_view.dart';
import 'package:mynotes/views/notes/archived_note_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/deleted_note_view.dart';
import 'package:mynotes/views/settings/settings_view.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case createUpdateNoteRoute:
        return MaterialPageRoute(builder: (_) => const CreateUpdateNoteView());
      case archivedViewRoute:
        return MaterialPageRoute(builder: (_) => const ArchivedNoteView());
      case deletedViewRoute:
        return MaterialPageRoute(builder: (_) => const DeletedNoteView());
      case settingsViewRoute:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      default:
        return MaterialPageRoute(builder: (_) => const HomeView());
    }
  }
}
