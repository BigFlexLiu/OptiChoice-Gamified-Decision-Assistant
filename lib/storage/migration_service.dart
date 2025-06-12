import 'base_storage_service.dart';
import 'storage_constants.dart';
import 'roulette_storage_service.dart';

class MigrationService extends BaseStorageService {
  /// Migrate old single roulette data to new multi-roulette format
  static Future<bool> migrateOldData() async {
    try {
      // Check if old data exists
      final oldOptionsString = await BaseStorageService.getString(
        StorageConstants.oldOptionsKey,
      );
      if (oldOptionsString != null && oldOptionsString.isNotEmpty) {
        // Parse old string list format (if it was stored as JSON)
        List<String>? oldOptions;
        try {
          final parsed = await BaseStorageService.getJson(
            StorageConstants.oldOptionsKey,
          );
          if (parsed is List) {
            oldOptions = List<String>.from(parsed);
          }
        } catch (e) {
          // If JSON parsing fails, try comma-separated format
          oldOptions = oldOptionsString
              .split(',')
              .map((e) => e.trim())
              .toList();
        }

        if (oldOptions != null && oldOptions.isNotEmpty) {
          // Check if new format doesn't exist yet
          final existingRoulettesString = await BaseStorageService.getString(
            StorageConstants.roulettesKey,
          );
          if (existingRoulettesString == null) {
            // Migrate old data to new format
            final roulettes = {
              StorageConstants.defaultRouletteName: oldOptions,
            };
            await RouletteStorageService.saveAllRoulettes(roulettes);
            await RouletteStorageService.setActiveRoulette(
              StorageConstants.defaultRouletteName,
            );

            // Remove old data
            await BaseStorageService.remove(StorageConstants.oldOptionsKey);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if migration is needed
  static Future<bool> needsMigration() async {
    final hasOldData =
        await BaseStorageService.getString(StorageConstants.oldOptionsKey) !=
        null;
    final hasNewData =
        await BaseStorageService.getString(StorageConstants.roulettesKey) !=
        null;
    return hasOldData && !hasNewData;
  }

  /// Perform all necessary migrations
  static Future<void> performMigrations() async {
    if (await needsMigration()) {
      await migrateOldData();
    }
  }
}
