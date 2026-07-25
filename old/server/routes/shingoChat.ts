import { RequestHandler } from "express";
import OpenAI from "openai";
import { GoogleGenAI } from "@google/genai";
import { getProviderApiKey } from "../lib/providerApiKeys";

type ChatMessage = {
  role: "user" | "assistant";
  content: string;
};

const isValidChatMessage = (message: unknown): message is ChatMessage => {
  if (!message || typeof message !== "object") {
    return false;
  }

  const candidate = message as { role?: unknown; content?: unknown };
  const hasValidRole =
    candidate.role === "user" || candidate.role === "assistant";
  const hasValidContent =
    typeof candidate.content === "string" &&
    candidate.content.trim().length > 0;

  return hasValidRole && hasValidContent;
};

export const handleShingoChat: RequestHandler = async (req, res) => {
  try {
    const rawMessages = req.body?.messages;
    const rawMessage = req.body?.message;

    let messages: ChatMessage[] | null = null;
    if (Array.isArray(rawMessages)) {
      const validMessages = rawMessages.filter(isValidChatMessage);
      if (validMessages.length !== rawMessages.length) {
        return res.status(400).json({
          error:
            "All messages must include role ('user' or 'assistant') and non-empty content",
        });
      }

      messages = validMessages.map(
        (message): ChatMessage => ({
          role: message.role,
          content: message.content.trim(),
        }),
      );
    } else if (typeof rawMessage === "string" && rawMessage.trim()) {
      messages = [{ role: "user", content: rawMessage.trim() }];
    }

    if (!messages || messages.length === 0) {
      return res
        .status(400)
        .json({ error: "Valid message or messages array is required" });
    }

    const systemPrompt =
      "You are Shingo AI, an expert on Sri Lankan heritage, culture, historical context, entry fees, weather, and directions to specific sites. Provide concise, helpful, and friendly answers.";

    let apiKey = "";
    let provider = "nvidia";

    try {
      apiKey = await getProviderApiKey("nvidia");
    } catch (e) {
      console.warn("NVIDIA API key not found, falling back to Gemini");
      apiKey = await getProviderApiKey("gemini");
      provider = "gemini";
    }

    res.setHeader("Content-Type", "text/plain");
    res.setHeader("Transfer-Encoding", "chunked");

    if (provider === "nvidia") {
      const client = new OpenAI({
        baseURL: "https://integrate.api.nvidia.com/v1",
        apiKey: apiKey,
      });

      const formattedMessages = [
        { role: "system", content: systemPrompt },
        ...messages.map((m) => ({ role: m.role, content: m.content })),
      ];

      const completion = await client.chat.completions.create({
        model: "minimaxai/minimax-m2.7",
        messages: formattedMessages as any,
        temperature: 0.7,
        top_p: 0.95,
        max_tokens: 1024,
        stream: true,
      });

      for await (const chunk of completion) {
        const content = chunk.choices[0]?.delta?.content;
        if (content) {
          res.write(content);
        }
      }
    } else {
      const ai = new GoogleGenAI({ apiKey });
      const contents = messages.map((m) => ({
        role: m.role === "assistant" ? "model" : "user",
        parts: [{ text: m.content }],
      }));

      const result = await ai.models.generateContentStream({
        model: "gemini-1.5-flash",
        contents: contents,
        config: {
          systemInstruction: systemPrompt,
        },
      });

      for await (const chunk of result) {
        const text = chunk.text;
        if (text) {
          res.write(text);
        }
      }
    }

    res.end();
  } catch (error) {
    console.error("Shingo AI chat error:", error);
    const message =
      error instanceof Error ? error.message : "Internal server error";
    res.status(500).json({ error: message });
  }
};
