import { useState, useEffect } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Bookmark,
  MapPin,
  Info,
  Sparkles,
  Loader2,
} from "lucide-react";
import BottomNav from "@/components/BottomNav";
import { supabase } from "@/lib/supabase";
import Markdown from "react-markdown";

export default function ArchiveDetail() {
  const { id } = useParams();
  const isNew =
    id === "new" || window.location.pathname.includes("/admin/generate");
  const navigate = useNavigate();

  const [topic, setTopic] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(!isNew);
  const [generateError, setGenerateError] = useState("");

  const getErrorMessage = (error: unknown) =>
    error instanceof Error ? error.message : "Failed to generate AI content.";

  useEffect(() => {
    async function fetchData() {
      if (isNew) return;

      setIsLoading(true);

      // Mock static data for specific routes
      if (id === "mask") {
        setData({
          title: "Traditional Mask Making",
          subtitle: "ANCIENT CRAFTSMANSHIP",
          location: "AMBALANGODA, SRI LANKA",
          intro:
            'In the coastal town of Ambalangoda, the ancient art of "Wesmuhunu" (mask making) has been preserved through generations, breathing life into the folklore and spiritual rituals of the island.',
          section1Title: "The Heritage of Kaduru Wood",
          section1Content:
            "The process begins with the careful selection of 'Kaduru' (Strychnos nux-vomica), a soft, light wood found in marshy lands. The timber is seasoned with smoke for several weeks to prevent decay and insect infestation, a practice unchanged for centuries. Each mask starts as a raw block, slowly revealing its character under the skilled hands of a master carver.",
          images: [
            "https://images.unsplash.com/photo-1544640808-32cb4fbad06e?q=80&w=600&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=600&auto=format&fit=crop",
          ],
          section2Title: "The Spirit of Gara Yaka",
          section2Content:
            "Among the most iconic creations is the Gara Yaka mask. Characterized by its large, bulging eyes, protruding tongue, and vibrant cobra-like ears, it is central to 'Tovil' (exorcism) rituals. These masks are believed to ward off 'Vas-dos' (evil eye or bad luck) and are frequently seen at the entrances of new homes and businesses in Southern Sri Lanka.",
          didYouKnow:
            "The vibrant colors used in these masks were traditionally derived from natural sources: 'Makulu' (white clay), 'Gokatu' (yellow resin), and charred 'Pol-katu' (coconut shells) for the deep blacks.",
        });
        setIsLoading(false);
        return;
      }

      const fallbackRecord = {
        title: "Archive Record",
        subtitle: "HISTORICAL ARCHIVE",
        location: "SRI LANKA",
        intro:
          "An exploration into the deep roots of Sri Lankan heritage and history.",
        section1Title: "Historical Context",
        section1Content:
          "Detailed documentation of this topic is preserved within the national archives.",
        section2Title: "Cultural Significance",
        section2Content:
          "These traditions form the bedrock of the local community's identity.",
        didYouKnow:
          "Sri Lanka has a documented history that spans over 3,000 years.",
      };

      if (supabase) {
        try {
          // Fetch from supabase
          const { data: record, error } = await supabase
            .from("archives")
            .select("*")
            .eq("id", id)
            .single();

          if (!error && record) {
            setData({
              ...record,
              images: record.image ? [record.image] : record.images || [],
            });
          } else {
            setData(fallbackRecord);
          }
        } catch (error) {
          console.error("Archive fetch error:", error);
          setData(fallbackRecord);
        }
        setIsLoading(false);
        return;
      }

      setData(fallbackRecord);
      setIsLoading(false);
    }
    fetchData();
  }, [id, isNew]);

  const handleGenerate = async () => {
    if (!topic.trim()) return;
    setGenerateError("");
    setIsGenerating(true);
    try {
      const res = await fetch("/api/generate-archive", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ topic }),
      }).catch((err) => {
        throw new Error("Network error: Could not reach the server.");
      });

      if (!res.ok) {
        let message = "";
        try {
          const body = await res.json();
          message = body?.error || "";
        } catch {
          message = "";
        }
        throw new Error(message || `Server returned ${res.status}`);
      }
      if (!res.body) throw new Error("No readable stream");

      const aiImageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(topic + " Sri Lanka historical artifact heritage realistic 4k")}?width=1000&height=1000&nologo=true`;

      setData({
        title: topic,
        subtitle: "AI GENERATED ARCHIVE",
        location: "SRI LANKA (AI ESTIMATED)",
        content: "",
        images: [aiImageUrl],
      });

      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let streamedMarkdown = "";
      let pTitle = topic;
      let pSubtitle = "AI GENERATED ARCHIVE";
      let pLocation = "SRI LANKA (AI ESTIMATED)";
      let parsedContent = "";

      while (true) {
        const { value, done } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        streamedMarkdown += chunk;

        const lines = streamedMarkdown.split("\n");
        const contentLines = [];

        for (const line of lines) {
          if (line.match(/^#\s+/)) {
            pTitle =
              line.replace(/^#\s+/, "").replace(/\*/g, "").trim() || pTitle;
          } else if (line.match(/^##\s+/)) {
            pSubtitle =
              line
                .replace(/^##\s+/, "")
                .replace(/\*/g, "")
                .trim() || pSubtitle;
          } else if (
            line.match(/^\*\*Location:\*\*\s+/i) ||
            line.match(/^Location:\s+/i)
          ) {
            pLocation =
              line
                .replace(/^\*+Location:\*+\s+/i, "")
                .replace(/^Location:\s+/i, "")
                .replace(/\*/g, "")
                .trim() || pLocation;
          } else {
            contentLines.push(line);
          }
        }

        parsedContent = contentLines.join("\n").trim();

        setData((prev: any) => ({
          ...prev,
          title: pTitle,
          subtitle: pSubtitle,
          location: pLocation,
          content: parsedContent,
        }));
      }

      if (!streamedMarkdown.trim()) {
        throw new Error("The AI service returned an empty response.");
      }

      const newArchive = {
        title: pTitle,
        subtitle: pSubtitle,
        location: pLocation,
        intro: parsedContent || streamedMarkdown,
        content: parsedContent || streamedMarkdown,
        images: [aiImageUrl],
      };

      if (supabase) {
        const {
          data: { session },
        } = await supabase.auth.getSession();

        const { data: insertedData, error } = await supabase
          .from("archives")
          .insert([
            {
              title: newArchive.title,
              subtitle: newArchive.subtitle,
              location: newArchive.location,
              intro: newArchive.intro,
              content: newArchive.content,
              image: aiImageUrl,
              user_id: session?.user?.id || null,
            },
          ])
          .select()
          .single();

        if (error) {
          console.error("Supabase insert error:", error);
          throw new Error(
            "Failed to save archive to database: " + error.message,
          );
        }

        if (insertedData) {
          navigate(`/archive/${insertedData.id}`);
          return;
        }
      }
    } catch (e: any) {
      console.error("Archive Generation Error:", e);

      // Fallback if API fails
      const fallbackMarkdown = `
# ${topic}
## AI GENERATED ARCHIVE
Write a brief engaging introduction.
### The Heritage
Write a detailed paragraph about the history and significance.
### Did you know?
Write a fascinating historical fact.
      `;
      const aiImageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(topic + " Sri Lanka historical artifact heritage realistic 4k")}?width=1000&height=1000&nologo=true`;
      setData({
        title: topic,
        subtitle: "AI GENERATED ARCHIVE",
        location: "SRI LANKA (AI ESTIMATED)",
        content: fallbackMarkdown.trim(),
        images: [aiImageUrl],
      });
      setGenerateError(getErrorMessage(e));
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] text-[#FEFBE0] shadow-[0_0_40px_rgba(0,0,0,0.5)] overflow-x-hidden pb-24">
        {isNew && !data ? (
          <div className="p-5 pt-20 flex flex-col items-center justify-center min-h-[50vh]">
            <Link
              to="/archive"
              className="absolute top-12 left-5 w-10 h-10 rounded-full bg-[#1A1311] border border-white/5 flex items-center justify-center"
            >
              <ArrowLeft className="w-5 h-5 text-[#F4A261]" />
            </Link>
            <div className="w-16 h-16 rounded-full bg-[#F4A261]/20 flex items-center justify-center mb-6">
              <Sparkles className="w-8 h-8 text-[#F4A261]" />
            </div>
            <h1 className="text-2xl font-bold mb-4 font-['Playfair_Display',serif] text-center">
              Admin: Generate Archive
            </h1>
            <p className="text-white/60 text-center text-sm mb-8">
              Enter a topic to generate a comprehensive historical archive using
              NVIDIA NIM AI.
            </p>

            <input
              type="text"
              value={topic}
              onChange={(e) => setTopic(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && topic.trim() && !isGenerating) {
                  void handleGenerate();
                }
              }}
              placeholder="e.g. Ancient Sigiriya Frescoes"
              className="w-full bg-[#1A1311] border border-[#F4A261]/30 rounded-2xl py-4 px-5 text-white placeholder-white/40 mb-6 outline-none focus:border-[#F4A261]"
            />
            {generateError && (
              <div className="w-full rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-200 mb-4">
                {generateError}
              </div>
            )}

            <button
              onClick={handleGenerate}
              disabled={!topic.trim() || isGenerating}
              className="w-full bg-[#F4A261] text-[#100E0A] rounded-2xl py-4 font-bold disabled:opacity-50 flex items-center justify-center gap-2 transition-transform active:scale-95"
            >
              {isGenerating ? (
                <Loader2 className="w-5 h-5 animate-spin" />
              ) : (
                <Sparkles className="w-5 h-5" />
              )}
              {isGenerating ? "Generating..." : "Generate Post"}
            </button>
          </div>
        ) : data ? (
          <>
            {/* Immersive Header Image */}
            <div className="relative h-[45vh] w-full shrink-0">
              <img
                src={
                  data.image ||
                  data.images?.[0] ||
                  `https://image.pollinations.ai/prompt/${encodeURIComponent(data.title + " Sri Lanka historical artifact heritage realistic 4k")}?width=1000&height=1000&nologo=true`
                }
                alt="Archive Featured"
                onError={(e) => {
                  e.currentTarget.src =
                    "https://images.unsplash.com/photo-1545657805-46eb13251a37?q=80&w=1000&auto=format&fit=crop";
                }}
                className="absolute inset-0 w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#100E0A] via-[#100E0A]/60 to-transparent" />

              <div className="absolute top-12 left-5 right-5 flex justify-between z-10 safe-top">
                <Link
                  to="/archive"
                  className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-md border border-white/10 flex items-center justify-center transition-colors hover:bg-black/60"
                >
                  <ArrowLeft className="w-5 h-5 text-white" />
                </Link>
                <button className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-md border border-white/10 flex items-center justify-center transition-colors hover:bg-black/60">
                  <Bookmark className="w-5 h-5 text-[#F4A261]" fill="#F4A261" />
                </button>
              </div>

              <div className="absolute bottom-0 left-0 right-0 p-5 z-10 translate-y-4">
                <div className="inline-block px-2.5 py-1 rounded border border-[#F4A261]/20 bg-[#F4A261]/10 text-[#F4A261] text-[9px] font-bold uppercase tracking-[0.15em] mb-3">
                  {data.subtitle}
                </div>
                <h1 className="text-[36px] leading-[1.1] font-bold text-white mb-3 font-['Playfair_Display',serif] shadow-black drop-shadow-lg">
                  {data.title}
                </h1>
                <div className="flex items-center gap-1.5 text-[#F4A261]">
                  <MapPin className="w-3.5 h-3.5" />
                  <span className="text-[10px] font-bold uppercase tracking-wider">
                    {data.location}
                  </span>
                </div>
              </div>
            </div>

            {/* Content Body */}
            <div className="px-6 pt-10">
              {data.content ? (
                <div className="markdown-body prose prose-invert prose-p:leading-relaxed prose-headings:text-[#F4A261] prose-a:text-[#F4A261] mb-10 text-[14px]">
                  <Markdown>{data.content}</Markdown>
                </div>
              ) : (
                <>
                  <div className="border-l-[3px] border-[#F4A261] pl-5 mb-10">
                    <p className="text-[15px] italic text-white/80 leading-relaxed font-['Playfair_Display',serif]">
                      {data.intro}
                    </p>
                  </div>

                  {data.section1Title && (
                    <div className="mb-10">
                      <h2 className="text-[20px] font-bold text-[#F4A261] mb-4">
                        {data.section1Title}
                      </h2>
                      <p className="text-[14px] text-white/70 leading-[1.8]">
                        {data.section1Content}
                      </p>
                    </div>
                  )}

                  {data.images && data.images.length > 0 && (
                    <div className="grid grid-cols-2 gap-3 mb-10">
                      {data.images.map((img: string, i: number) => (
                        <div
                          key={i}
                          className="rounded-[20px] overflow-hidden aspect-[4/5] border border-white/5"
                        >
                          <img
                            src={img}
                            alt="Detail"
                            onError={(e) => {
                              e.currentTarget.style.display = "none";
                            }}
                            className="w-full h-full object-cover"
                          />
                        </div>
                      ))}
                    </div>
                  )}

                  {data.section2Title && (
                    <div className="mb-10">
                      <h2 className="text-[20px] font-bold text-[#F4A261] mb-4">
                        {data.section2Title}
                      </h2>
                      <p className="text-[14px] text-white/70 leading-[1.8]">
                        {data.section2Content}
                      </p>
                    </div>
                  )}

                  {data.didYouKnow && (
                    <div className="bg-[#1A1311] border border-white/5 rounded-[24px] p-6 relative overflow-hidden">
                      <div className="absolute -right-4 -top-4 opacity-5">
                        <Info className="w-32 h-32" />
                      </div>
                      <div className="flex items-center gap-2 text-[#F4A261] font-bold mb-3 relative z-10">
                        <Info className="w-5 h-5" />
                        Did you know?
                      </div>
                      <p className="text-[13px] text-white/60 leading-relaxed relative z-10">
                        {data.didYouKnow}
                      </p>
                    </div>
                  )}
                </>
              )}
            </div>
          </>
        ) : null}

        <BottomNav />
      </div>
    </div>
  );
}
