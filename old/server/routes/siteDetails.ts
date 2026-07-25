import { RequestHandler } from "express";
import { GoogleGenAI } from "@google/genai";
import { getProviderApiKey } from "../lib/providerApiKeys";

export const handleSiteDetails: RequestHandler = async (req, res) => {
  try {
    const siteName = req.query.name as string;

    if (!siteName) {
      res.status(400).json({ error: "Site name is required" });
      return;
    }

    const prompt = `Provide practical details for a tourist visiting "${siteName}". 
Respond ONLY with a JSON object in the exact following format:
{
  "description": "A short, engaging 1-2 sentence description.",
  "status": "e.g., Open, Closed, Open 24/7",
  "ticketPrice": "e.g., Free, $5, 1000 LKR",
  "bestTimeToVisit": "e.g., Morning, Evening"
}
Ensure the JSON is valid and can be directly parsed. No markdown fences.`;

    const geminiApiKey = await getProviderApiKey("gemini");
    const ai = new GoogleGenAI({ apiKey: geminiApiKey });

    const response = await ai.models.generateContent({
      model: "gemini-1.5-flash",
      contents: prompt,
      config: {
        tools: [{ googleSearch: {} }],
      },
    });

    const resultText = response.text || "{}";
    let details;
    try {
      details = JSON.parse(
        resultText
          .replace(/```json/g, "")
          .replace(/```/g, "")
          .trim(),
      );
    } catch (e) {
      console.error("Failed to parse Gemini response", resultText);
      details = {
        description: "Information currently unavailable.",
        status: "Unknown",
        ticketPrice: "Unknown",
        bestTimeToVisit: "Unknown",
      };
    }

    res.json(details);
  } catch (error) {
    console.error("Error fetching site details:", error);
    res.status(500).json({ error: "Failed to generate details" });
  }
};
