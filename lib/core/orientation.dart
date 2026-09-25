import 'package:flutter/services.dart';

/// The app is portrait-only. Landscape is allowed only while the player is
/// in fullscreen, which the student enters with the fullscreen button.
///
/// Landscape isn't unlocked for rotate-to-fullscreen: when a screen allows
/// it, the system first jumps to the last orientation it remembers and only
/// then corrects to the real one, so screens visibly flip on their own.
const appOrientations = [DeviceOrientation.portraitUp];
