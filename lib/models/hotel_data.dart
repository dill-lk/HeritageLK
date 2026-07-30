class HotelData {
  final String name;
  final String nearSite;
  final double rating;
  final String price;
  final int stars;
  final String imageUrl;
  final String bookingUrl;
  final String region;
  final String description;
  final bool isPartner;
  final List<String> galleryImages;
  final List<String> amenities;

  const HotelData(
    this.name,
    this.nearSite,
    this.rating,
    this.price,
    this.stars,
    this.imageUrl,
    this.bookingUrl,
    this.region,
    this.description, {
    this.isPartner = false,
    this.galleryImages = const [],
    this.amenities = const [],
  });
}
