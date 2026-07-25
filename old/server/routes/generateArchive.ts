import { RequestHandler } from "express";
import OpenAI from "openai";
import { GoogleGenAI } from "@google/genai";
import { getProviderApiKey } from "../lib/providerApiKeys";

export const handleGenerateArchive: RequestHandler = async (req, res) => {
  try {
    const topic =
      typeof req.body?.topic === "string" ? req.body.topic.trim() : "";
    if (!topic) {
      return res.status(400).json({ error: "Topic is required" });
    }

    let apiKey = "";
    let provider = "nvidia";

    try {
      apiKey = await getProviderApiKey("nvidia");
    } catch (e) {
      console.warn("NVIDIA API key not found, falling back to Gemini");
      apiKey = await getProviderApiKey("gemini");
      provider = "gemini";
    }

    const prompt = `You are a heritage archivist for Sri Lanka. Generate an engaging archive article about "${topic}".
Format exactly as Markdown with the following structure:
# <A catchy, specific title>
## <A relevant subtitle>
**Location:** <City, Region, Sri Lanka>

<Write a brief engaging introduction here>

### The Heritage
<Write a detailed paragraph about the history and significance.>

### Did you know?
<Write a fascinating historical fact.>`;

    res.setHeader("Content-Type", "text/plain");
    res.setHeader("Transfer-Encoding", "chunked");

    if (provider === "nvidia") {
      const client = new OpenAI({
        baseURL: "https://integrate.api.nvidia.com/v1",
        apiKey: apiKey,
      });

      const completion = await client.chat.completions.create({
        model: "minimaxai/minimax-m2.7",
        messages: [{ role: "user", content: prompt }],
        temperature: 1,
        top_p: 0.95,
        max_tokens: 8192,
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
      const result = await ai.models.generateContentStream({
        model: "gemini-1.5-flash",
        contents: [{ role: "user", parts: [{ text: prompt }] }],
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
    console.error("Generate archive error:", error);
    const message =
      error instanceof Error ? error.message : "Internal server error";
    res.status(500).json({ error: message });
  }
};
