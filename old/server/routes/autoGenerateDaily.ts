import { RequestHandler } from "express";
import { GoogleGenAI } from "@google/genai";
import OpenAI from "openai";
import {
  getRequiredServerSupabaseConfig,
  supabaseServer,
} from "../lib/supabase";
import { getProviderApiKey } from "../lib/providerApiKeys";

import { createClient } from "@supabase/supabase-js";

export const generateDailyArchive = async (token?: string) => {
  try {
    if (!supabaseServer) {
      console.error("Auto Gen: Supabase is not configured on the server");
      return { error: "Supabase is not configured on the server" };
    }

    const geminiApiKey = await getProviderApiKey("gemini");
    let nvidiaApiKey = "";
    try {
      nvidiaApiKey = await getProviderApiKey("nvidia");
    } catch (e) {
      console.warn("Auto Gen: NVIDIA API key not found, will use Gemini for article generation");
    }

    let client = supabaseServer;
    let userId = null;
    if (token) {
      const { supabaseUrl, supabaseAnonKey } =
        getRequiredServerSupabaseConfig();
      client = createClient(supabaseUrl, supabaseAnonKey, {
        global: { headers: { Authorization: token } },
      });
      const {
        data: { user },
      } = await client.auth.getUser(token.replace("Bearer ", ""));
      if (user) {
        userId = user.id;
      }
    }

    // 1. Get Topic from Gemini
    console.log("Auto Gen: Requesting topic from Gemini...");
    let topic = "";
    const ai = new GoogleGenAI({ apiKey: geminiApiKey });
    try {
      const geminiResponse = await ai.models.generateContent({
        model: "gemini-1.5-flash",
        contents: [
          {
            role: "user",
            parts: [
              {
                text: "Give me exactly one unique archive topic for a Sri Lankan historical artifact or ancient site. Respond with ONLY the title string, nothing else. Do not use quotes or markdown.",
              },
            ],
          },
        ],
      });
      topic = geminiResponse.text?.trim() || "";
    } catch (e: any) {
      console.error("Auto Gen: Gemini failed, using fallback topic", e.message);
      const fallbackTopics = [
        "The Moonstone of Polonnaruwa",
        "Sigiriya Frescoes",
        "The Sacred Tooth Relic",
        "Anuradhapura Avukana Buddha Statue",
        "Ruwanwelisaya Stupa",
        "The Yapahuwa Rock Fortress",
        "Dambulla Cave Temple paintings",
        "Galle Fort Ramparts",
      ];
      topic = fallbackTopics[Math.floor(Math.random() * fallbackTopics.length)];
    }

    if (!topic) {
      console.error("Auto Gen: Failed to get topic from Gemini");
      return { error: "Failed to get topic from Gemini" };
    }
    console.log("Auto Gen: provided topic:", topic);

    // 2. Setup prompts and AI for article generation
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

    let articleContent = "";

    if (nvidiaApiKey) {
      console.log("Auto Gen: Requesting article from NVIDIA Minimax...");
      const nvidiaClient = new OpenAI({
        baseURL: "https://integrate.api.nvidia.com/v1",
        apiKey: nvidiaApiKey,
      });

      const completion = await nvidiaClient.chat.completions.create({
        model: "minimaxai/minimax-m2.7",
        messages: [{ role: "user", content: prompt }],
        temperature: 1,
        top_p: 0.95,
        max_tokens: 4096,
        stream: false,
      });
      articleContent = completion.choices?.[0]?.message?.content || "";
    } else {
      console.log("Auto Gen: Requesting article from Gemini...");
      const completion = await ai.models.generateContent({
        model: "gemini-1.5-flash",
        contents: [{ role: "user", parts: [{ text: prompt }] }],
      });
      articleContent = completion.text || "";
    }

    if (!articleContent) {
      console.error("Auto Gen: AI returned empty article");
      return { error: "AI returned empty article" };
    }

    // 3. Parse content
    let pTitle = topic;
    let pSubtitle = "AI GENERATED ARCHIVE";
    let pLocation = "SRI LANKA (AI ESTIMATED)";
    let parsedContent = "";

    const lines = articleContent.split("\n");
    const contentLines = [];

    for (const line of lines) {
      if (line.match(/^#\s+/)) {
        pTitle = line.replace(/^#\s+/, "").replace(/\*/g, "").trim() || pTitle;
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

    // 4. Determine Image
    const aiImageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(pTitle + " Sri Lanka historical artifact heritage realistic 4k")}?width=1000&height=1000&nologo=true`;

    // 5. Store in Supabase
    const newArchive = {
      title: pTitle,
      subtitle: pSubtitle,
      location: pLocation,
      intro: parsedContent || articleContent,
      content: parsedContent || articleContent,
      category: "Artifacts",
      image: aiImageUrl,
      ...(userId ? { user_id: userId } : {}),
    };

    console.log("Auto Gen: Saving archive to Supabase...");
    const { error, data } = await client
      .from("archives")
      .insert([newArchive])
      .select();

    if (error) {
      console.error(
        "Auto Gen: Supabase insertion error:",
        JSON.stringify(error, null, 2),
      );
      return { error };
    }

    console.log("Auto Gen: Successfully created new daily archive:", pTitle);
    return data;
  } catch (err: any) {
    console.error("Auto Gen: Unhandled error:", err);
    return { error: err?.message || "Unknown error" };
  }
};

export const handleGenerateDailyArchive: RequestHandler = async (req, res) => {
  const token = req.headers.authorization;
  const data = await generateDailyArchive(token);
  if (data && !(data as any).error) {
    res.status(200).json({ success: true, archive: data });
  } else {
    res.status(500).json({
      success: false,
      message: "Failed to generate daily archive",
      error: (data as any)?.error,
    });
  }
};
