import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/sgrkannada/Mr.Smart/releases/latest';

  Future<Map<String, String>?> checkForUpdate({Function(String)? onStatus}) async {
    try {
      onStatus?.call('Checking for updates...');
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        final latestVersion = release['tag_name'];
        final changelog = release['body'];

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewerVersion(latestVersion, currentVersion)) {
          onStatus?.call('New version found!');
          return {
            'latestVersion': latestVersion,
            'changelog': changelog,
            'release': json.encode(release),
          };
        } else {
          onStatus?.call('No new updates available.');
          return null;
        }
      }
    } catch (e) {
      onStatus?.call('Failed to check for updates.');
      print('Failed to check for updates: $e');
    }
    return null;
  }

  Future<void> downloadAndInstallUpdate(
    Map<String, dynamic> release, {
    Function(String)? onStatus,
    Function(double)? onProgress,
  }) async {
    try {
      final asset = release['assets']
          .firstWhere((asset) => asset['name'].endsWith('.apk'));
      final downloadUrl = asset['browser_download_url'];

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      final contentLength = response.contentLength;
      if (contentLength == null) {
        onStatus?.call('Cannot determine download size.');
        return;
      }

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/app-release.apk';
      final file = File(filePath);
      final sink = file.openWrite();

      int bytesReceived = 0;
      response.stream.listen(
        (List<int> chunk) {
          bytesReceived += chunk.length;
          final progress = bytesReceived / contentLength;
          onProgress?.call(progress);
          sink.add(chunk);
        },
        onDone: () async {
          await sink.close();
          client.close();
          onStatus?.call('Download complete. Installing...');
          OtaUpdate()
              .execute(filePath,
                  androidProviderAuthority: 'com.example.smart_bro.provider')
              .listen(
            (OtaEvent event) {
              onStatus?.call('Update status: ${event.status}');
            },
          );
        },
        onError: (e) {
          onStatus?.call('Failed to download update.');
          print('Failed to download update: $e');
          sink.close();
          client.close();
        },
        cancelOnError: true,
      );
    } catch (e) {
      onStatus?.call('Failed to download and install update.');
      print('Failed to download and install update: $e');
    }
  }

  bool _isNewerVersion(String latestVersion, String currentVersion) {
    final latest = latestVersion.split('.').map(int.parse).toList();
    final current = currentVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < latest.length; i++) {
      if (i >= current.length) {
        return true;
      }
      if (latest[i] > current[i]) {
        return true;
      }
      if (latest[i] < current[i]) {
        return false;
      }
    }
    return false;
  }
}