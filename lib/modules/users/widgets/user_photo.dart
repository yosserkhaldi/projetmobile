import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Photo protégée d'un compte, téléchargée avec le jeton de l'utilisateur.
class UserPhotoView extends StatefulWidget {
  const UserPhotoView({
    required this.user,
    required this.photo,
    required this.placeholder,
    this.fit = BoxFit.cover,
    super.key,
  });

  final AppUser user;
  final UserPhoto photo;
  final Widget placeholder;
  final BoxFit fit;

  @override
  State<UserPhotoView> createState() => _UserPhotoViewState();
}

class _UserPhotoViewState extends State<UserPhotoView> {
  Future<Uint8List?>? _bytes;
  String? _loadedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(UserPhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load();
  }

  void _load() {
    final id = widget.photo.idOf(widget.user);
    if (id == _loadedId) return;
    _loadedId = id;
    _bytes = id == null
        ? null
        : AppScope.of(context).users.photoBytes(widget.photo, widget.user);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _bytes,
    builder: (context, snapshot) {
      final bytes = snapshot.data;
      if (bytes != null) {
        return Image.memory(
          bytes,
          fit: widget.fit,
          gaplessPlayback: true,
          // Fichier illisible : on garde l'initiale plutôt qu'une erreur.
          errorBuilder: (_, _, _) => widget.placeholder,
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      return widget.placeholder;
    },
  );
}

/// Propose l'appareil photo ou la galerie, puis envoie l'image.
Future<void> changePhoto(BuildContext context, UserPhoto photo) async {
  final users = AppScope.of(context).users;
  final messenger = ScaffoldMessenger.of(context);
  final hasPhoto = photo.idOf(users.currentUser!) != null;
  final saved = context.t.photoSaved;
  String describe(Object error) => errorMessage(context, error);

  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(context.t.takePhoto),
            onTap: () => Navigator.pop(sheet, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(context.t.chooseFromGallery),
            onTap: () => Navigator.pop(sheet, 'gallery'),
          ),
          if (hasPhoto)
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: context.palette.errorText,
              ),
              title: Text(
                context.t.deletePhoto,
                style: TextStyle(color: context.palette.errorText),
              ),
              onTap: () => Navigator.pop(sheet, 'delete'),
            ),
        ],
      ),
    ),
  );
  if (choice == null) return;

  try {
    if (choice == 'delete') {
      await users.deletePhoto(photo);
      return;
    }
    // Réduite sur le téléphone : envoi rapide en 4G, sous la limite de 5 Mo.
    final file = await ImagePicker().pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    await users.uploadPhoto(photo, await file.readAsBytes(), file.name);
    messenger.showSnackBar(SnackBar(content: Text(saved)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(describe(e))));
  }
}
