import '../utils/app_prefs.dart';
import 'local_data_cleaner.dart';

/// Keeps one person's local data from leaking to the next person to use the
/// same device. The device remembers whose data it holds; when a different
/// account signs in, the previous person's local data is cleared first.
class AccountGuard {
  final LocalDataCleaner cleaner;
  final Future<String?> Function() readOwner;
  final Future<void> Function(String? uid) writeOwner;

  AccountGuard(
    this.cleaner, {
    Future<String?> Function()? readOwner,
    Future<void> Function(String? uid)? writeOwner,
  }) : readOwner = readOwner ?? (() => AppPrefs.dataOwnerUid),
       writeOwner = writeOwner ?? AppPrefs.setDataOwnerUid;

  /// Call when the signed-in account is known. Returns true if another person's
  /// data was cleared. A device with no recorded owner (installed before this
  /// check existed) is treated as belonging to the first account that signs in.
  Future<bool> reconcile(String? uid) async {
    if (uid == null) return false;
    final owner = await readOwner();
    if (owner == uid) return false;
    var cleared = false;
    if (owner != null) {
      await cleaner.clearUserData();
      cleared = true;
    }
    await writeOwner(uid);
    return cleared;
  }

  /// Clears everything and forgets the owner, for an explicit sign-out.
  Future<void> clearForSignOut() async {
    await cleaner.clearUserData();
    await writeOwner(null);
  }
}
