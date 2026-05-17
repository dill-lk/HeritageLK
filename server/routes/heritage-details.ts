import type { RequestHandler } from "express";
import type { HeritageDetailsResponse } from "@shared/api";

type GeminiPlaceDetail = {
  placeName?: string;
  shortDescription?: string;
  ticketPriceLkr?: string;
  ticketPriceForeignUsd?: string;
  sourceNote?: string;
};

type GeminiApiResponse = {
  candidates?: Array<{
    content?: {
      parts?: Array<{ text?: string }>;
    };
  }>;
};

const FALLBACK_SOURCE = "Gemini unavailable";

const fallbackPlace = (placeName: string) => ({
  placeName,
  shortDescription: "Details are currently unavailable. Please try again.",
  ticketPriceLkr: "N/A",
  ticketPriceForeignUsd: "N/A",
  sourceNote: FALLBACK_SOURCE,
});

const parseGeminiJson = (text: string): GeminiPlaceDetail[] | null => {
  const jsonMatch = text.match(/```json\s*([\s\S]*?)\s*```/) ?? text.match(/(\[[\s\S]*\])/);
  const raw = jsonMatch?.[1] ?? text;

  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) {
      return null;
    }

    return parsed.filter((item) => item && typeof item === "object");
  } catch {
    return null;
  }
};

export const handleHeritageDetails: RequestHandler = async (req, res) => {
  const placesRaw = typeof req.query.places === "string" ? req.query.places : "";
  const places = placesRaw
    .split(",")
    .map((name) => name.trim())
    .filter(Boolean)
    .slice(0, 10);

  if (!places.length) {
    return res.status(400).json({ error: "Provide at least one place in query param 'places'" });
  }

  const geminiApiKey = process.env.GEMINI_API_KEY;
  if (!geminiApiKey) {
    const fallback: HeritageDetailsResponse = {
      places: places.map(fallbackPlace),
    };
    return res.status(200).json(fallback);
  }

  const prompt = `Return ONLY a JSON array (no markdown, no extra text) with one object per place for: ${places.join(
    ", ",
  )}.
Each object must include:
- placeName
- shortDescription (max 18 words)
- ticketPriceLkr (adult local entry ticket, include currency label)
- ticketPriceForeignUsd (adult foreign entry ticket, include currency label)
- sourceNote (very short note like "Estimated from recent web knowledge")
If unknown, use "Unknown".`;

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${encodeURIComponent(geminiApiKey)}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.2,
          },
        }),
      },
    );

    if (!response.ok) {
      const fallback: HeritageDetailsResponse = {
        places: places.map(fallbackPlace),
      };
      return res.status(200).json(fallback);
    }

    const data = (await response.json()) as GeminiApiResponse;
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    const parsed = parseGeminiJson(text);

    if (!parsed) {
      const fallback: HeritageDetailsResponse = {
        places: places.map(fallbackPlace),
      };
      return res.status(200).json(fallback);
    }

    const byName = new Map(
      parsed.map((item) => [
        (item.placeName ?? "").toLowerCase().trim(),
        {
          placeName: item.placeName?.trim() || "Unknown Place",
          shortDescription: item.shortDescription?.trim() || "Unknown",
          ticketPriceLkr: item.ticketPriceLkr?.trim() || "Unknown",
          ticketPriceForeignUsd: item.ticketPriceForeignUsd?.trim() || "Unknown",
          sourceNote: item.sourceNote?.trim() || "Estimated from Gemini",
        },
      ]),
    );

    const payload: HeritageDetailsResponse = {
      places: places.map((placeName) => byName.get(placeName.toLowerCase()) ?? fallbackPlace(placeName)),
    };

    return res.status(200).json(payload);
  } catch {
    const fallback: HeritageDetailsResponse = {
      places: places.map(fallbackPlace),
    };
    return res.status(200).json(fallback);
  }
};
