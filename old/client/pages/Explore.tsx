import React, { useState, useEffect } from "react";
import { MapContainer, TileLayer, Marker, Popup, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import {
  Search,
  Mic,
  MapPin,
  History,
  Map as MapIcon,
  Flag,
  Landmark,
  MoreVertical,
  RotateCcw,
  Leaf,
  ChevronDown,
  ChevronUp,
  Thermometer,
  Wind,
  CloudSun,
} from "lucide-react";
import BottomNav from "@/components/BottomNav";
import { Button } from "@/components/ui/button";
import { useQuery } from "@tanstack/react-query";

// Default icon fix for React-Leaflet
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png",
  iconUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png",
  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
});

// A custom marker icon to match the image
const customIcon = new L.Icon({
  iconUrl:
    "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-gold.png",
  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

const selectedIcon = new L.Icon({
  iconUrl:
    "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png",
  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

const ALL_SITES = [
  {
    id: 1,
    name: "Galle Dutch Fort",
    position: [6.0264, 80.217] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "Entry to the Galle Dutch Fort itself is completely free for all visitors. You can walk the ramparts, visit the lighthouse, and explore the cobblestone streets without a ticket.",
  },
  {
    id: 2,
    name: "Galle Lighthouse",
    position: [6.0249, 80.2195] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "A picturesque, historic lighthouse located inside the Galle Fort. While you cannot go inside, exploring the area around it is completely free.",
  },
  {
    id: 3,
    name: "National Museum",
    position: [6.027, 80.2185] as [number, number],
    category: "Knowledge",
    ticketPrice: "300 LKR",
    aiOverview:
      "Located inside the fort, this museum offers deep insights into the cultural history of Southern Sri Lanka. Entry is 300 LKR for foreign adults.",
  },
  {
    id: 4,
    name: "Jungle Beach",
    position: [6.015, 80.237] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      "A beautiful hidden beach near Galle. Access is free and it offers a relatively quiet swimming experience surrounded by forest.",
  },
  {
    id: 5,
    name: "Sigiriya Rock Fortress",
    position: [7.957, 80.7603] as [number, number],
    category: "History",
    ticketPrice: "$30 USD",
    aiOverview:
      "An ancient rock fortress and palace ruin surrounded by an extensive network of gardens and reservoirs. A UNESCO World Heritage site.",
  },
  {
    id: 6,
    name: "Temple of the Sacred Tooth Relic",
    position: [7.2936, 80.6415] as [number, number],
    category: "History",
    ticketPrice: "2000 LKR",
    aiOverview:
      "A Buddhist temple in the city of Kandy, housing the relic of the tooth of the Buddha.",
  },
  {
    id: 7,
    name: "Ruwanwelisaya",
    position: [8.35, 80.3965] as [number, number],
    category: "History",
    ticketPrice: "Included in Anuradhapura pass",
    aiOverview:
      "A stupa in Anuradhapura, considered one of the worlds tallest monuments and a sacred place of worship.",
  },
  {
    id: 8,
    name: "Dambulla Cave Temple",
    position: [7.8566, 80.6483] as [number, number],
    category: "History",
    ticketPrice: "2000 LKR",
    aiOverview:
      "The largest and best-preserved cave temple complex in Sri Lanka, boasting ancient Buddhist murals and statues.",
  },
  {
    id: 9,
    name: "Yala National Park",
    position: [6.3686, 81.5165] as [number, number],
    category: "Nature",
    ticketPrice: "~$35 USD",
    aiOverview:
      "A huge area of forest, grassland and lagoons bordering the Indian Ocean, in southeast Sri Lanka. Famous for its leopards.",
  },
  {
    id: 10,
    name: "Nine Arches Bridge",
    position: [6.8767, 81.0608] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      "A picturesque colonial-era railway bridge in Demodara, near Ella. Famous for its magnificent architecture set amongst lush green tea fields.",
  },
  {
    id: 11,
    name: "Adam's Peak (Sri Pada)",
    position: [6.8096, 80.4994] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      'A tall conical mountain in central Sri Lanka, known for the "sacred footprint" near its summit.',
  },
  {
    id: 12,
    name: "Polonnaruwa Vatadage",
    position: [7.9472, 81.0016] as [number, number],
    category: "History",
    ticketPrice: "Included in Polonnaruwa pass",
    aiOverview:
      "An ancient structure dating back to the Kingdom of Polonnaruwa. The best-preserved example of a vatadage in the country.",
  },
  {
    id: 13,
    name: "Royal Botanical Gardens, Peradeniya",
    position: [7.2687, 80.5966] as [number, number],
    category: "Nature",
    ticketPrice: "3000 LKR",
    aiOverview:
      "Renowned for its collection of orchids, including more than 4000 species of plants, spices, medicinal plants and palm trees.",
  },
  {
    id: 14,
    name: "Horton Plains National Park",
    position: [6.8028, 80.8066] as [number, number],
    category: "Nature",
    ticketPrice: "~$30 USD",
    aiOverview:
      "A protected area in the central highlands covered by montane grassland and cloud forest.",
  },
  {
    id: 15,
    name: "Mirissa Beach",
    position: [5.9483, 80.4572] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      "A popular tourist destination known for its beautiful beach and whale watching.",
  },
  {
    id: 16,
    name: "Pinnawala Elephant Orphanage",
    position: [7.3013, 80.3873] as [number, number],
    category: "Nature",
    ticketPrice: "3000 LKR",
    aiOverview:
      "An orphanage, nursery and captive breeding ground for wild Asian elephants.",
  },
  {
    id: 17,
    name: "Colombo Lotus Tower",
    position: [6.9271, 79.8588] as [number, number],
    category: "Knowledge",
    ticketPrice: "$20 USD",
    aiOverview:
      "A 350m-tall tower in Colombo, offering panoramic views of the city.",
  },
  {
    id: 18,
    name: "Gangarama Temple",
    position: [6.9167, 79.858] as [number, number],
    category: "History",
    ticketPrice: "400 LKR",
    aiOverview:
      "One of the most important temples in Colombo, blending modern architecture and cultural essence.",
  },
  {
    id: 19,
    name: "Arugam Bay",
    position: [6.8427, 81.8266] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      "A popular surfing destination on the southeast coast of Sri Lanka.",
  },
  {
    id: 20,
    name: "Minneriya National Park",
    position: [8.041, 80.8523] as [number, number],
    category: "Nature",
    ticketPrice: "~$25 USD",
    aiOverview:
      'A national park famous for the "Gathering" of wild elephants during the dry season.',
  },
  {
    id: 21,
    name: "St. Anthony's Shrine, Kochchikade",
    position: [6.9452, 79.854] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "A Roman Catholic church in the Archdiocese of Colombo and a national shrine.",
  },
  {
    id: 22,
    name: "Jaffna Fort",
    position: [9.6615, 80.0074] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "A fort built by the Portuguese at Jaffna in 1618 under Phillippe de Oliveira following his invasion of Jaffna.",
  },
  {
    id: 23,
    name: "Nallur Kandaswamy temple",
    position: [9.6749, 80.0264] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "One of the most significant Hindu temples in the Jaffna District.",
  },
  {
    id: 24,
    name: "Independence Memorial Hall",
    position: [6.9044, 79.8674] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "A national monument in Sri Lanka built for commemoration of the independence from British rule.",
  },
  {
    id: 25,
    name: "Galle Face Green",
    position: [6.9234, 79.8447] as [number, number],
    category: "Knowledge",
    ticketPrice: "FREE",
    aiOverview:
      "A 5 hectare ocean-side urban park, which stretches for 500 m along the coast, in the heart of Colombo.",
  },
  {
    id: 26,
    name: "Nuwara Eliya Post Office",
    position: [6.973, 80.7686] as [number, number],
    category: "History",
    ticketPrice: "FREE",
    aiOverview:
      "One of the oldest post offices in Sri Lanka, housed in a beautiful Tudor-style colonial building.",
  },
  {
    id: 27,
    name: "Gregory Lake",
    position: [6.9582, 80.7725] as [number, number],
    category: "Nature",
    ticketPrice: "250 LKR",
    aiOverview:
      "A prominent attraction in Nuwara Eliya, built in 1873 during the British period for relaxation.",
  },
  {
    id: 28,
    name: "Ella Rock",
    position: [6.8647, 81.0483] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      "A famous viewpoint offering panoramic views of the lush green valleys and mountains around Ella.",
  },
  {
    id: 29,
    name: "Rawana Falls",
    position: [6.8407, 81.0543] as [number, number],
    category: "Nature",
    ticketPrice: "FREE",
    aiOverview:
      "A beautiful and popular waterfall in Ella, linked to the Hindu epic Ramayana.",
  },
  {
    id: 30,
    name: "Yapahuwa Rock Fortress",
    position: [7.8285, 80.3204] as [number, number],
    category: "History",
    ticketPrice: "$3 USD",
    aiOverview:
      "Once a capital of Sri Lanka, this fortress features an iconic ornamental stairway that leads to the top.",
  },
];

export default function Explore() {
  const [selectedSite, setSelectedSite] = useState(ALL_SITES[0]);
  const [searchQuery, setSearchQuery] = useState("");
  const [isDetailsExpanded, setIsDetailsExpanded] = useState(true);

  const filteredSites = ALL_SITES.filter(
    (site) =>
      site.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      site.category.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  const { data: siteDetails, isLoading } = useQuery({
    queryKey: ["site-details", selectedSite.name],
    queryFn: async () => {
      try {
        const res = await fetch(
          `/api/site-details?name=${encodeURIComponent(selectedSite.name)}`,
        );
        if (!res.ok) throw new Error("Failed to fetch details");
        return res.json();
      } catch {
        return {
          description: selectedSite.aiOverview,
          status: "Open",
          ticketPrice: selectedSite.ticketPrice,
          bestTimeToVisit: "Morning",
        };
      }
    },
    retry: false,
  });

  const { data: weatherInfo, isLoading: isWeatherLoading } = useQuery({
    queryKey: ["weather", selectedSite.id],
    queryFn: async () => {
      const [lat, lon] = selectedSite.position;
      const res = await fetch(
        `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true`,
      );
      if (!res.ok) throw new Error("Failed to fetch weather");
      return res.json();
    },
  });

  return (
    <div className="min-h-[100dvh] w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif] stretch">
      <div className="relative w-full sm:max-w-[430px] h-[100dvh] bg-[#100E0A] overflow-hidden text-[#FEFBE0] shadow-[0_0_40px_rgba(0,0,0,0.5)]">
        {/* Map layer */}
        <div className="absolute inset-0 z-0">
          <MapContainer
            center={[6.0264, 80.217]} // Center around Galle Fort
            zoom={15}
            zoomControl={false}
            className="w-full h-full"
            style={{ background: "#100E0A" }}
          >
            <MapUpdater position={selectedSite.position} />
            {/* Using a dark map tile provider to match the sleek design */}
            <TileLayer
              attribution='&copy; <a href="https://carto.com/attributions">CARTO</a>'
              url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
            />
            {filteredSites.map((site) => (
              <Marker
                key={site.id}
                position={site.position}
                icon={selectedSite.id === site.id ? selectedIcon : customIcon}
                eventHandlers={{
                  click: () => {
                    setSelectedSite(site);
                    setIsDetailsExpanded(true);
                  },
                }}
              />
            ))}
          </MapContainer>
        </div>

        {/* Top overlay UI */}
        <div className="absolute top-0 left-0 right-0 z-10 safe-top pointer-events-none mt-12">
          <div className="pointer-events-auto flex flex-col items-center">
            <div className="relative w-[calc(100%-48px)] mb-4">
              {/* Search Bar */}
              <div className="flex items-center bg-[#1A1311]/90 backdrop-blur-md rounded-[20px] px-5 py-4 shadow-lg w-full z-20 relative">
                <Search className="w-5 h-5 text-[#FEFBE0]/60 mr-3" />
                <input
                  type="text"
                  placeholder="Search Heritage"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="bg-transparent border-none text-[#FEFBE0] placeholder-[#FEFBE0]/60 outline-none flex-1 text-[15px] font-medium"
                />
                {searchQuery && (
                  <button
                    onClick={() => setSearchQuery("")}
                    className="mr-2 opacity-50 hover:opacity-100 transition-opacity"
                  >
                    <div className="text-[12px] font-bold">X</div>
                  </button>
                )}
                <Mic className="w-5 h-5 text-[#FEFBE0]/60" />
              </div>

              {/* Suggestions Dropdown */}
              {searchQuery && filteredSites.length > 0 && (
                <div className="absolute top-[60px] left-0 right-0 bg-[#0F0C0A]/95 border border-white/5 rounded-[20px] shadow-xl overflow-y-auto max-h-[300px] z-10 backdrop-blur-md pb-2 pt-2 hide-scrollbar">
                  {filteredSites.map((site) => (
                    <button
                      key={site.id}
                      className="w-full px-5 py-3 text-left hover:bg-white/5 transition-colors flex items-center gap-3 border-b border-white/5 last:border-0"
                      onClick={() => {
                        setSelectedSite(site);
                        setSearchQuery("");
                        setIsDetailsExpanded(true);
                      }}
                    >
                      <MapPin className="w-4 h-4 text-[#F4A261]" />
                      <div>
                        <div className="text-[#FEFBE0] font-bold text-[14px]">
                          {site.name}
                        </div>
                        <div className="text-[#FEFBE0]/50 text-[10px] uppercase font-bold tracking-wider">
                          {site.category}
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Filter Chips */}
            <div className="flex items-center justify-center gap-3 w-full px-6">
              <button className="flex items-center gap-2 bg-[#1A1311]/90 border border-white/5 rounded-full px-5 py-2.5 text-[14px] font-bold text-white whitespace-nowrap backdrop-blur-md">
                <GlobeIcon className="w-4 h-4" /> History
              </button>
              <button className="flex items-center gap-2 bg-[#1A1311]/90 border border-white/5 rounded-full px-5 py-2.5 text-[14px] font-bold text-white whitespace-nowrap backdrop-blur-md">
                <Leaf className="w-4 h-4" /> Nature
              </button>
              <button className="flex items-center gap-2 bg-[#1A1311]/90 border border-white/5 rounded-full px-5 py-2.5 text-[14px] font-bold text-white whitespace-nowrap backdrop-blur-md">
                <Flag className="w-4 h-4" /> Quests
              </button>
            </div>
          </div>
        </div>

        {/* Bottom info card overlay */}
        <div className="absolute bottom-[108px] left-0 right-0 z-10 px-6 pointer-events-none">
          <div className="pointer-events-auto bg-[#0F0C0A]/95 border border-white/5 rounded-[32px] p-6 shadow-2xl relative transition-all duration-300">
            <div className="flex justify-between items-start mb-6">
              <div className="pr-4">
                <h2 className="text-[26px] leading-[1.2] font-bold text-white mb-2 flex items-center gap-2">
                  {selectedSite.name} 🏰
                </h2>
                <div className="flex items-center gap-1.5 text-[#10b981] text-[10px] font-bold tracking-[0.08em] uppercase">
                  <GlobeIcon className="w-3.5 h-3.5" /> UNESCO WORLD HERITAGE
                  SITE
                </div>
              </div>
              <button
                onClick={() => setIsDetailsExpanded(!isDetailsExpanded)}
                className="flex-shrink-0 w-12 h-12 rounded-full flex items-center justify-center border border-white/5 bg-transparent active:scale-95 transition-transform overflow-hidden cursor-pointer"
              >
                {isDetailsExpanded ? (
                  <ChevronDown className="w-5 h-5 text-white/70" />
                ) : (
                  <ChevronUp className="w-5 h-5 text-white/70" />
                )}
              </button>
            </div>

            <div
              className={`overflow-hidden transition-all duration-300 ${isDetailsExpanded ? "max-h-[500px] opacity-100" : "max-h-0 opacity-0"}`}
            >
            <div className="flex items-center justify-between gap-3">
                  <button className="flex-1 bg-[#F4A261] text-white rounded-[20px] py-4 text-[15px] font-bold flex items-center justify-center gap-2 transition-transform active:scale-95 shadow-[0_4px_16px_rgba(244,162,97,0.25)]">
                    <CameraIcon /> Scan Site
                  </button>
                  <button className="w-14 h-14 rounded-[20px] border border-white/5 bg-white/5 flex items-center justify-center transition-transform active:scale-95">
                    <RotateCcw className="w-[22px] h-[22px] text-white" />
                  </button>
                  <button className="w-14 h-14 rounded-[20px] border border-white/5 bg-white/5 flex items-center justify-center transition-transform active:scale-95">
                    <Flag className="w-[22px] h-[22px] text-[#c084fc]" />
                  </button>
                </div>

              <div className="mt-5 pt-5 border-t border-white/5 space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1.5 text-[9px] font-bold text-[#F4A261] uppercase tracking-[0.1em]">
                    <div className="w-1.5 h-1.5 rounded-full bg-[#F4A261] animate-pulse"></div>
                    AI Quick Insights
                  </div>
                  {!isWeatherLoading && weatherInfo?.current_weather && (
                    <div className="flex items-center gap-3">
                      <div className="flex items-center gap-1 text-[11px] font-bold text-white/80">
                        <Thermometer className="w-3.5 h-3.5 text-[#F4A261]" />
                        {weatherInfo.current_weather.temperature}°C
                      </div>
                      <div className="flex items-center gap-1 text-[11px] font-bold text-white/80">
                        <Wind className="w-3.5 h-3.5 text-[#60a5fa]" />
                        {weatherInfo.current_weather.windspeed} km/h
                      </div>
                      <CloudSun className="w-4 h-4 text-[#fbbf24]" />
                    </div>
                  )}
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-[#1A1311] rounded-[16px] p-3 border border-white/5 flex flex-col justify-center">
                    <p className="text-[11px] text-white/50 uppercase font-black tracking-wider mb-1">
                      Status
                    </p>
                    <div className="text-[12px] font-medium text-white/90 leading-tight flex items-start gap-1.5">
                      <span className="w-1.5 h-1.5 rounded-full bg-[#10b981] mt-1.5 shrink-0"></span>
                      <span>
                        {isLoading
                          ? "Loading..."
                          : siteDetails
                            ? siteDetails.status
                            : "Unknown"}
                      </span>
                    </div>
                  </div>
                  <div className="bg-[#1A1311] rounded-[16px] p-3 border border-white/5 flex flex-col justify-center">
                    <p className="text-[11px] text-white/50 uppercase font-black tracking-wider mb-1">
                      Ticket Price
                    </p>
                    <p className="text-[12px] font-medium text-white/90 leading-tight">
                      {isLoading
                        ? "Loading..."
                        : siteDetails
                          ? siteDetails.ticketPrice
                          : selectedSite.ticketPrice}
                    </p>
                  </div>
                </div>

                <div className="bg-[#1A1311] rounded-[16px] p-3 border border-white/5">
                  <p className="text-[11px] text-white/50 uppercase font-black tracking-wider mb-1">
                    AI Overview
                  </p>
                  <p className="text-[13px] font-medium text-white/80 leading-relaxed">
                    {isLoading
                      ? "Loading insights..."
                      : siteDetails?.description || selectedSite.aiOverview}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <BottomNav />
      </div>
    </div>
  );
}

function MapUpdater({ position }: { position: [number, number] }) {
  const map = useMap();
  useEffect(() => {
    map.flyTo(position, 16);
  }, [position, map]);
  return null;
}

// Simple icons to match screenshot
function FlagsIcon(props: any) {
  return (
    <svg
      {...props}
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"></path>
      <line x1="4" y1="22" x2="4" y2="15"></line>
    </svg>
  );
}

function GlobeIcon(props: any) {
  return (
    <svg
      {...props}
      width="12"
      height="12"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="2" y1="12" x2="22" y2="12"></line>
      <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
    </svg>
  );
}

function CameraIcon(props: any) {
  return (
    <svg
      {...props}
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"></path>
      <circle cx="12" cy="13" r="3"></circle>
    </svg>
  );
}
