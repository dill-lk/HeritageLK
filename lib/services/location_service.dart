import 'package:geolocator/geolocator.dart';

class HeritageLocation {
  final String name;
  final double lat;
  final double lon;
  final String emoji;
  final String category;

  const HeritageLocation({
    required this.name,
    required this.lat,
    required this.lon,
    required this.emoji,
    required this.category,
  });
}

class LocationService {
  static const List<HeritageLocation> knownSites = [
    HeritageLocation(name: 'Galle Dutch Fort', lat: 6.0264, lon: 80.2170, emoji: '🏰', category: 'History'),
    HeritageLocation(name: 'Yatagala Temple', lat: 6.0150, lon: 80.2450, emoji: '🛕', category: 'History'),
    HeritageLocation(name: 'Sigiriya Rock Fortress', lat: 7.9570, lon: 80.7603, emoji: '🗿', category: 'History'),
    HeritageLocation(name: 'Yala National Park', lat: 6.3686, lon: 81.5165, emoji: '🐆', category: 'Nature'),
    HeritageLocation(name: 'Temple of the Tooth', lat: 7.2936, lon: 80.6415, emoji: '🛕', category: 'History'),
    HeritageLocation(name: 'Dambulla Cave Temple', lat: 7.8566, lon: 80.6483, emoji: '🗿', category: 'History'),
    HeritageLocation(name: 'Nine Arches Bridge', lat: 6.8767, lon: 81.0608, emoji: '🌉', category: 'Nature'),
    HeritageLocation(name: 'Colombo Lotus Tower', lat: 6.9271, lon: 79.8588, emoji: '🗼', category: 'Knowledge'),
    HeritageLocation(name: 'Ruwanwelisaya Stupa', lat: 8.3500, lon: 80.3965, emoji: '🏛️', category: 'History'),
    HeritageLocation(name: 'Mirissa Beach', lat: 5.9483, lon: 80.4572, emoji: '🏖️', category: 'Nature'),
  ];

  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // Try fast last known position first
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) return position;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m away';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km away';
    }
  }

  static String getDistanceToSite(Position? userPos, HeritageLocation site) {
    if (userPos == null) {
      // Default reference from Colombo city center if GPS unavailable
      final meters = Geolocator.distanceBetween(6.9271, 79.8588, site.lat, site.lon);
      return '${(meters / 1000).toStringAsFixed(0)} km from Colombo';
    }
    final meters = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, site.lat, site.lon);
    return formatDistance(meters);
  }

  static String getNearestSiteDescription(double lat, double lon) {
    HeritageLocation? nearest;
    double minMeters = double.infinity;

    for (final site in knownSites) {
      final d = Geolocator.distanceBetween(lat, lon, site.lat, site.lon);
      if (d < minMeters) {
        minMeters = d;
        nearest = site;
      }
    }

    final latStr = '${lat.toStringAsFixed(4)}° N';
    final lonStr = '${lon.toStringAsFixed(4)}° E';

    if (nearest != null && minMeters < 15000) {
      final distStr = formatDistance(minMeters);
      return 'Near ${nearest.name} ($distStr) - $latStr, $lonStr';
    }

    return 'Location: $latStr, $lonStr';
  }

  static List<Map<String, String>> getPlacesToExplore(Position? userPos) {
    final list = knownSites.map((site) {
      final double meters = userPos != null
          ? Geolocator.distanceBetween(userPos.latitude, userPos.longitude, site.lat, site.lon)
          : Geolocator.distanceBetween(6.9271, 79.8588, site.lat, site.lon);
      return {
        'emoji': site.emoji,
        'name': site.name,
        'distance': userPos != null ? formatDistance(meters) : '${(meters / 1000).toStringAsFixed(0)} km away',
        'meters': meters.toString(),
      };
    }).toList();

    // If live GPS position is available, sort places by distance from user
    if (userPos != null) {
      list.sort((a, b) => double.parse(a['meters']!).compareTo(double.parse(b['meters']!)));
    }

    return list;
  }
}
