import { useState } from "react";
import { ArrowLeft, Upload, Info } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";

export default function ContributeArchive() {
  const [title, setTitle] = useState("");
  const [category, setCategory] = useState("Artifacts");
  const [description, setDescription] = useState("");
  const [isPublic, setIsPublic] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { toast } = useToast();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !description) return;

    setIsSubmitting(true);

    try {
      if (supabase) {
        const {
          data: { session },
        } = await supabase.auth.getSession();

        const { data, error } = await supabase
          .from("archives")
          .insert([
            {
              title,
              category,
              content: description,
              intro: description.substring(0, 50) + "...",
              user_id: session?.user?.id || null,
              location: "User Uploaded",
              is_public: isPublic,
              image:
                "https://images.unsplash.com/photo-1545657805-46eb13251a37?q=80&w=1000&auto=format&fit=crop",
            },
          ])
          .select()
          .single();

        if (error) throw error;

        toast({
          title: "Contribution added to the Archive! ✨",
          description: "Thank you for preserving Sri Lanka's heritage.",
        });

        if (data) {
          navigate(`/archive/${data.id}`);
        } else {
          navigate("/archive");
        }
      }
    } catch (e: any) {
      toast({
        variant: "destructive",
        title: "Failed to submit",
        description: e.message || "Something went wrong.",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] text-[#FEFBE0] shadow-[0_0_40px_rgba(0,0,0,0.5)] overflow-x-hidden pb-24">
        {/* Header Background */}
        <div className="absolute top-0 left-0 right-0 h-48 cover-gradient z-0 overflow-hidden">
          <img
            src="https://images.unsplash.com/photo-1580211105436-bd8efb3684a0?q=80&w=1000&auto=format&fit=crop"
            className="w-full h-full object-cover opacity-30"
            alt="Background"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-transparent to-[#100E0A]" />
        </div>

        <div className="relative z-10 px-6 pt-12">
          {/* Top Bar */}
          <div className="flex items-center justify-between mb-8">
            <Link
              to="/archive"
              className="w-10 h-10 rounded-full bg-white/10 border border-white/20 flex items-center justify-center"
            >
              <ArrowLeft className="w-5 h-5 text-[#F4A261]" />
            </Link>
            <h1 className="text-lg font-bold font-['Playfair_Display',serif]">
              Contribute to Archive
            </h1>
            <div className="w-10 h-10 rounded-full bg-white/10 border border-white/20 flex items-center justify-center">
              <Info className="w-5 h-5 text-[#F4A261]" />
            </div>
          </div>

          <p className="text-[#F4A261] text-xs font-bold tracking-widest uppercase mb-1">
            SHARE YOUR STORY
          </p>
          <h2 className="text-3xl font-bold font-['Playfair_Display',serif] mb-8">
            Add to the Legacy
          </h2>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Title Input */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-4">
              <div className="flex items-center gap-3 mb-1">
                <span className="text-white/40">👤</span>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full bg-transparent border-none outline-none text-white placeholder-white/20 text-sm"
                  placeholder="Title of Contribution (e.g. My Grandmother's Recipes)"
                />
              </div>
            </div>

            {/* Category Select */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-4">
              <div className="flex items-center gap-3">
                <span className="text-white/40 text-sm">🗂️</span>
                <div className="w-full">
                  <p className="text-[10px] text-white/40 uppercase tracking-widest mb-1">
                    Category
                  </p>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full bg-transparent border-none outline-none text-white text-sm appearance-none"
                  >
                    <option className="bg-[#100E0A]">Artifacts</option>
                    <option className="bg-[#100E0A]">Oral History</option>
                    <option className="bg-[#100E0A]">Ancient Sites</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Description Textarea */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-4 min-h-[140px]">
              <h3 className="text-sm font-semibold text-white/60 mb-2">
                The Story / Description
              </h3>
              <textarea
                required
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="w-full bg-transparent border-none outline-none text-white/40 text-sm resize-none h-[100px]"
                placeholder="Tell us the historical significance, the origin, or the personal memories associated with this contribution..."
              />
            </div>

            {/* Media Upload */}
            <div>
              <h3 className="text-sm font-semibold text-white/80 mb-3 mt-6">
                Upload Media
              </h3>
              <div className="border border-dashed border-white/20 rounded-2xl p-8 flex flex-col items-center justify-center bg-white/5 transition-colors hover:bg-white/10 cursor-pointer">
                <div className="w-12 h-12 bg-[#F4A261] rounded-full flex items-center justify-center mb-4">
                  <Upload className="text-[#100E0A] w-5 h-5" />
                </div>
                <h4 className="font-bold mb-1">Drop photos, audio or PDFs</h4>
                <p className="text-xs text-white/40">Maximum file size: 50MB</p>
              </div>
            </div>

            {/* Public Toggle */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-4 flex items-center justify-between mt-4">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center">
                  <span className="text-xs">🔒</span>
                </div>
                <div>
                  <h3 className="text-sm font-bold">Public Archive</h3>
                  <p className="text-xs text-white/40">
                    Available for everyone to see
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setIsPublic(!isPublic)}
                className={`w-12 h-7 rounded-full transition-colors relative ${isPublic ? "bg-[#F4A261]" : "bg-white/20"}`}
              >
                <div
                  className={`absolute top-1 w-5 h-5 rounded-full bg-white transition-transform ${isPublic ? "right-1 translate-x-0" : "left-1 translate-x-0"}`}
                />
              </button>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full h-14 bg-[#F4A261] text-[#100E0A] font-bold rounded-2xl mt-8 flex items-center justify-center gap-2"
            >
              {isSubmitting ? "Submitting..." : "Submit to Archive →"}
            </button>

            <div className="flex justify-center mt-6">
              <span className="text-white/20 uppercase tracking-widest text-xs border-b border-white/20 pb-1">
                HeritageLK
              </span>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
