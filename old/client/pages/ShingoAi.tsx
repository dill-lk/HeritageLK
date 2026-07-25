import { useState, useRef, useEffect } from "react";
import { ArrowLeft, Send, Sparkles } from "lucide-react";
import { Link } from "react-router-dom";
import { useToast } from "@/hooks/use-toast";
import ShingoLogo from "@/components/ShingoLogo";

import Markdown from "react-markdown";
import remarkGfm from "remark-gfm";

type Message = {
  id: string;
  role: "user" | "assistant";
  content: string;
};

export default function ShingoAi() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "1",
      role: "assistant",
      content:
        "Hello! I am Shingo AI. Ask me anything about Sri Lankan heritages, entry fees, weather, historical contexts, or directions to specific sites.",
    },
  ]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const { toast } = useToast();

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: "user",
      content: input,
    };
    const newMessages = [...messages, userMessage];
    setMessages(newMessages);
    setInput("");
    setIsLoading(true);

    try {
      const response = await fetch("/api/shingo-chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: newMessages.map((m) => ({
            role: m.role,
            content: m.content,
          })),
        }),
      });

      if (!response.ok) {
        throw new Error("Failed to connect to Shingo AI.");
      }

      const reader = response.body?.getReader();
      const decoder = new TextDecoder("utf-8");

      if (!reader) throw new Error("No reader available");

      let assistantMessageContent = "";
      const assistantMessageId = (Date.now() + 1).toString();

      setMessages((prev) => [
        ...prev,
        { id: assistantMessageId, role: "assistant", content: "" },
      ]);
      setIsLoading(false);

      while (true) {
        const { value, done } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        assistantMessageContent += chunk;

        setMessages((prev) =>
          prev.map((msg) =>
            msg.id === assistantMessageId
              ? { ...msg, content: assistantMessageContent }
              : msg,
          ),
        );
      }
    } catch (e: any) {
      setMessages((prev) => [
        ...prev,
        {
          id: (Date.now() + 2).toString(),
          role: "assistant",
          content:
            "Sorry, I'm having trouble connecting right now. Please make sure you're connected to the internet and try again later.",
        },
      ]);
      toast({
        variant: "destructive",
        title: "Error",
        description: e.message || "Shingo AI is experiencing issues right now.",
      });
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] text-[#FEFBE0] shadow-[0_0_40px_rgba(0,0,0,0.5)] flex flex-col">
        {/* Header */}
        <div className="px-6 pt-12 pb-4 flex items-center justify-between border-b border-white/5 bg-[#100E0A] z-10">
          <Link
            to="/archive"
            className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center transition-colors hover:bg-white/10"
          >
            <ArrowLeft className="w-5 h-5 text-[#E9C46A]" />
          </Link>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 flex items-center justify-center rounded-full bg-[#E9C46A]/20 shadow-[0_0_10px_rgba(233,196,106,0.3)]">
              <ShingoLogo className="w-4 h-4 text-[#E9C46A]" />
            </div>
            <h1 className="text-lg font-bold font-['Playfair_Display',serif] tracking-wide flex items-center gap-1.5">
              Shingo AI <Sparkles className="w-3.5 h-3.5 text-[#E9C46A]" />
            </h1>
          </div>
          <div className="w-10 h-10" />
        </div>

        {/* Chat Area */}
        <div className="flex-1 overflow-y-auto px-6 py-6 space-y-6">
          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex ${msg.role === "user" ? "justify-end" : "justify-start"}`}
            >
              <div
                className={`max-w-[85%] rounded-3xl p-4 ${msg.role === "user" ? "bg-[#F4A261] text-[#100E0A] rounded-tr-sm" : "bg-white/10 text-white/90 border border-white/5 rounded-tl-sm"}`}
              >
                <div className="text-sm leading-relaxed prose prose-invert max-w-none">
                  <Markdown remarkPlugins={[remarkGfm]}>{msg.content}</Markdown>
                </div>
              </div>
            </div>
          ))}
          {isLoading && (
            <div className="flex justify-start">
              <div className="max-w-[85%] rounded-3xl p-4 bg-white/10 text-white/90 border border-white/5 rounded-tl-sm flex items-center gap-2">
                <div className="w-2 h-2 bg-white/40 rounded-full animate-bounce" />
                <div
                  className="w-2 h-2 bg-white/40 rounded-full animate-bounce"
                  style={{ animationDelay: "0.2s" }}
                />
                <div
                  className="w-2 h-2 bg-white/40 rounded-full animate-bounce"
                  style={{ animationDelay: "0.4s" }}
                />
              </div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>

        {/* Input Area */}
        <div className="p-6 bg-[#100E0A] border-t border-white/5">
          <form onSubmit={handleSubmit} className="flex gap-3">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Ask Shingo..."
              className="flex-1 bg-white/5 border border-white/10 rounded-full px-5 text-sm outline-none text-white placeholder-white/40 transition-colors focus:border-[#E9C46A]/50"
            />
            <button
              type="submit"
              disabled={isLoading || !input.trim()}
              className="w-12 h-12 rounded-full bg-[#E9C46A] flex items-center justify-center shrink-0 transition-transform active:scale-95 disabled:opacity-50 disabled:active:scale-100"
            >
              <Send className="w-5 h-5 text-[#100E0A] ml-1" />
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
