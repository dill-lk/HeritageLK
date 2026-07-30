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
    // ── UNESCO & Major Heritage ─────────────────────────────────────────────
    HeritageLocation(name: 'Galle Dutch Fort', lat: 6.0264, lon: 80.2170, emoji: '🏰', category: 'History'),
    HeritageLocation(name: 'Sigiriya Rock Fortress', lat: 7.9570, lon: 80.7603, emoji: '🗿', category: 'History'),
    HeritageLocation(name: 'Temple of the Tooth', lat: 7.2936, lon: 80.6415, emoji: '🛕', category: 'History'),
    HeritageLocation(name: 'Dambulla Cave Temple', lat: 7.8566, lon: 80.6483, emoji: '🗿', category: 'History'),
    HeritageLocation(name: 'Ruwanwelisaya Stupa', lat: 8.3500, lon: 80.3965, emoji: '🏛️', category: 'History'),
    HeritageLocation(name: 'Polonnaruwa Vatadage', lat: 7.9472, lon: 81.0016, emoji: '🏛️', category: 'History'),
    HeritageLocation(name: 'Anuradhapura Sacred City', lat: 8.3354, lon: 80.4037, emoji: '🏛️', category: 'History'),
    HeritageLocation(name: 'Sinharaja Forest Reserve', lat: 6.2111, lon: 80.4044, emoji: '🌿', category: 'Nature'),
    HeritageLocation(name: 'Mihintale', lat: 8.3486, lon: 80.5896, emoji: '🏛️', category: 'History'),
    HeritageLocation(name: 'Yapahuwa Rock Fortress', lat: 7.8285, lon: 80.3204, emoji: '🗿', category: 'History'),
    // ── Nature & Wildlife ───────────────────────────────────────────────────
    HeritageLocation(name: 'Yala National Park', lat: 6.3686, lon: 81.5165, emoji: '🐆', category: 'Nature'),
    HeritageLocation(name: 'Minneriya National Park', lat: 8.0410, lon: 80.8523, emoji: '🐘', category: 'Nature'),
    HeritageLocation(name: 'Horton Plains', lat: 6.8028, lon: 80.8066, emoji: '🏔️', category: 'Nature'),
    HeritageLocation(name: 'Wilpattu National Park', lat: 8.3988, lon: 80.0117, emoji: '🐆', category: 'Nature'),
    HeritageLocation(name: 'Udawalawe National Park', lat: 6.4396, lon: 80.8793, emoji: '🐘', category: 'Nature'),
    HeritageLocation(name: 'Pinnawala Elephant Orphanage', lat: 7.3013, lon: 80.3873, emoji: '🐘', category: 'Nature'),
    HeritageLocation(name: 'Royal Botanical Gardens Peradeniya', lat: 7.2687, lon: 80.5966, emoji: '🌸', category: 'Nature'),
    HeritageLocation(name: 'Bundala National Park', lat: 6.1976, lon: 81.2235, emoji: '🦜', category: 'Nature'),
    HeritageLocation(name: 'Wasgamuwa National Park', lat: 7.7636, lon: 80.8968, emoji: '🐘', category: 'Nature'),
    // ── Beaches ─────────────────────────────────────────────────────────────
    HeritageLocation(name: 'Mirissa Beach', lat: 5.9483, lon: 80.4572, emoji: '🏖️', category: 'Nature'),
    HeritageLocation(name: 'Unawatuna Beach', lat: 6.0101, lon: 80.2490, emoji: '🏖️', category: 'Nature'),
    HeritageLocation(name: 'Arugam Bay', lat: 6.8427, lon: 81.8266, emoji: '🏄', category: 'Nature'),
    HeritageLocation(name: 'Bentota Beach', lat: 6.4226, lon: 80.0019, emoji: '🏖️', category: 'Nature'),
    HeritageLocation(name: 'Hikkaduwa Beach', lat: 6.1427, lon: 80.0983, emoji: '🤿', category: 'Nature'),
    HeritageLocation(name: 'Nilaveli Beach', lat: 8.7205, lon: 81.2075, emoji: '🏖️', category: 'Nature'),
    HeritageLocation(name: 'Tangalle Beach', lat: 6.0266, lon: 80.7948, emoji: '🏖️', category: 'Nature'),
    HeritageLocation(name: 'Passikudah Bay', lat: 7.9311, lon: 81.5583, emoji: '🏖️', category: 'Nature'),
    // ── Hill Country ────────────────────────────────────────────────────────
    HeritageLocation(name: 'Nine Arches Bridge', lat: 6.8767, lon: 81.0608, emoji: '🌉', category: 'Nature'),
    HeritageLocation(name: 'Ella Rock', lat: 6.8647, lon: 81.0483, emoji: '⛰️', category: 'Nature'),
    HeritageLocation(name: 'Rawana Falls', lat: 6.8407, lon: 81.0543, emoji: '💧', category: 'Nature'),
    HeritageLocation(name: 'Gregory Lake Nuwara Eliya', lat: 6.9582, lon: 80.7725, emoji: '🏞️', category: 'Nature'),
    HeritageLocation(name: "Adam's Peak", lat: 6.8096, lon: 80.4994, emoji: '⛰️', category: 'Nature'),
    HeritageLocation(name: 'Pidurangala Rock', lat: 7.9636, lon: 80.7565, emoji: '🧗', category: 'Nature'),
    HeritageLocation(name: 'Dunhinda Falls', lat: 7.0542, lon: 81.0565, emoji: '💧', category: 'Nature'),
    HeritageLocation(name: 'Baker Falls Horton Plains', lat: 6.7982, lon: 80.7930, emoji: '💧', category: 'Nature'),
    HeritageLocation(name: 'Knuckles Mountain Range', lat: 7.4167, lon: 80.7833, emoji: '🏔️', category: 'Nature'),
    // ── Colombo & West ──────────────────────────────────────────────────────
    HeritageLocation(name: 'Colombo Lotus Tower', lat: 6.9271, lon: 79.8588, emoji: '🗼', category: 'Knowledge'),
    HeritageLocation(name: 'Gangarama Temple Colombo', lat: 6.9167, lon: 79.8580, emoji: '🛕', category: 'History'),
    HeritageLocation(name: 'Galle Face Green', lat: 6.9234, lon: 79.8447, emoji: '🌊', category: 'Knowledge'),
    HeritageLocation(name: 'Independence Memorial Hall', lat: 6.9044, lon: 79.8674, emoji: '🏛️', category: 'History'),
    HeritageLocation(name: 'Viharamahadevi Park', lat: 6.9167, lon: 79.8608, emoji: '🌳', category: 'Knowledge'),
    HeritageLocation(name: 'Pettah Market', lat: 6.9374, lon: 79.8576, emoji: '🛍️', category: 'Knowledge'),
    // ── North & East ────────────────────────────────────────────────────────
    HeritageLocation(name: 'Jaffna Fort', lat: 9.6615, lon: 80.0074, emoji: '🏰', category: 'History'),
    HeritageLocation(name: 'Nallur Kandaswamy Temple', lat: 9.6749, lon: 80.0264, emoji: '🛕', category: 'History'),
    HeritageLocation(name: 'Koneswaram Temple Trincomalee', lat: 8.5857, lon: 81.2342, emoji: '🛕', category: 'History'),
    HeritageLocation(name: 'Pigeon Island Trincomalee', lat: 8.7378, lon: 81.2207, emoji: '🐠', category: 'Nature'),
    HeritageLocation(name: 'Dutch Bay Trincomalee', lat: 8.5736, lon: 81.2204, emoji: '⚓', category: 'History'),
    HeritageLocation(name: 'Yatagala Temple', lat: 6.0150, lon: 80.2450, emoji: '🛕', category: 'History'),
    // ── Galle & South ──────────────────────────────────────────────────────
    HeritageLocation(name: 'Galle Lighthouse', lat: 6.0249, lon: 80.2195, emoji: '🗼', category: 'History'),
    HeritageLocation(name: 'Jungle Beach Galle', lat: 6.0150, lon: 80.2370, emoji: '🏖️', category: 'Nature'),
    HeritageLocation(name: 'Hummanaya Blowhole', lat: 5.9834, lon: 80.5479, emoji: '🌊', category: 'Nature'),
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

      // Always request fresh current GPS position first to avoid stale mock / last known coords
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        // Fallback to last known position if real-time GPS fix times out
        Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) return lastKnown;

        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      }
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

    if (nearest != null && minMeters < 50000) {
      final distStr = formatDistance(minMeters);
      return '${nearest.name} Area ($distStr) - $latStr, $lonStr';
    }

    return 'Current GPS: $latStr, $lonStr';
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
