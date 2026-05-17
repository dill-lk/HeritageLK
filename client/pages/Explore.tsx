import { useEffect, useRef } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import BottomNav from "@/components/BottomNav";

const heritagePlaces = [
  { name: "Galle Fort", lat: 6.026, lng: 80.217, distance: "1.2 km" },
  { name: "Yatagala Temple", lat: 6.027, lng: 80.247, distance: "3.5 km" },
  { name: "Sigiriya", lat: 7.957, lng: 80.76, distance: "154 km" },
];

export default function Explore() {
  const mapContainerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<L.Map | null>(null);

  useEffect(() => {
    if (!mapContainerRef.current || mapRef.current) {
      return;
    }

    const map = L.map(mapContainerRef.current, {
      zoomControl: false,
    }).setView([6.9271, 79.8612], 7);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(map);

    heritagePlaces.forEach((place) => {
      L.circleMarker([place.lat, place.lng], {
        radius: 8,
        color: "#F4A261",
        weight: 2,
        fillColor: "#F4A261",
        fillOpacity: 0.4,
      })
        .addTo(map)
        .bindPopup(`<b>${place.name}</b><br/>${place.distance}`);
    });

    mapRef.current = map;
    window.setTimeout(() => map.invalidateSize(), 0);

    return () => {
      map.remove();
      mapRef.current = null;
    };
  }, []);

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-[440px] bg-[#100E0A] pb-32 px-6 pt-12">
        <div className="mb-5">
          <h1 className="text-[#FEFBE0] text-[32px] font-extrabold leading-[48px] tracking-[-0.8px]">
            Explore
          </h1>
          <p className="text-[#FEFAE0]/60 text-sm font-medium leading-5">
            Discover nearby heritage places
          </p>
        </div>

        <div className="rounded-[24px] border border-[#52B788]/20 overflow-hidden h-[52vh] mb-5">
          <div ref={mapContainerRef} className="w-full h-full" />
        </div>

        <div className="space-y-3">
          {heritagePlaces.map((place) => (
            <div
              key={place.name}
              className="rounded-2xl border border-[#52B788]/15 bg-white/5 p-4 flex items-center justify-between"
            >
              <span className="text-[#FEFBE0] text-sm font-semibold">{place.name}</span>
              <span className="text-[#52B788] text-xs font-bold uppercase tracking-[0.5px]">
                {place.distance}
              </span>
            </div>
          ))}
        </div>

        <BottomNav />
      </div>
    </div>
  );
}
