---
description: "Generate Instagram carousel slides (1080x1350) as a JSON file. Supports cover, content, checklist, stat, quote, showcase, and CTA slide types."
---
# /create-carousel
Generate an Instagram carousel as a set of 1080x1350 slides using Remotion. Output a JSON file that the Remotion render script converts to PNG images.

## Carousel Narrative Arc
Every carousel MUST follow this psychological structure:
**Hook > Problem > Cost > Shift > System > Proof > CTA**

1. **Hook** (Slide 1): Create a knowledge gap. Make them think "I need to read this." Use tension, curiosity, or a bold claim.
2. **Problem** (Slide 2): Name the pain. What is the audience struggling with right now?
3. **Cost** (Slide 3): What happens if they don't solve it? Agitate the problem.
4. **Shift** (Slide 4): Introduce the new way. Reframe their thinking.
5. **System** (Slides 5-8): Deliver the value. Steps, frameworks, prompts, tactics. This is the meat.
6. **Proof** (Slide 9): Why should they trust this? Results, social proof, or a summary of outcomes.
7. **CTA** (Last slide): Tell them exactly what to do next.

Not every carousel needs all 7 stages as separate slides. Some stages can be combined or skipped. But the arc should always move from tension to value to action.

## Writing Rules
These rules apply to ALL slide copy. Enforce them strictly.

- **One idea per slide.** If a slide makes two points, split it.
- **5-7 lines max per slide.** Count the lines. If it is more, cut.
- **Maximum white space.** Less text = more impact. When in doubt, delete.
- **Bold one key word per takeaway.** Not a full sentence in bold. One word.
- **Write at a 6th grade reading level.** Short sentences. Common words. No jargon unless you define it.
- **No fluff.** Remove every word that does not earn its place.

## Slide Types
Each slide has a `type` field plus type-specific properties:

- **cover**: `hookText` (string, the main headline), `topicLabel` (string, small label above the hook). Always Slide 1.
- **content**: `heading` (string), `body` (string), `bulletPoints` (optional array of strings). For explaining concepts.
- **checklist**: `heading` (optional string), `items` (array of strings), `variant` ("check" or "x"). For step-by-step instructions. Most common slide type for tutorials.
- **stat**: `value` (string, e.g. "$560K", "98%"), `label` (string), `sublabel` (optional string). For metrics and proof points.
- **quote**: `quoteText` (string), `attribution` (string), `role` (optional string). For testimonials or memorable statements.
- **cta**: `ctaText` (string), `ctaSubtext` (optional string), `handle` (optional string, your Instagram handle). Always the last slide. Wrap text in double asterisks to highlight it white on the button.
- **showcase**: `heading` (string), `body` (string), `mediaSource` (string, video filename), `mediaDuration` (number, seconds), `stepNumber` (optional number), `mediaStartTime` (optional number, seconds to seek into video), `handle` (optional string). Renders as MP4 clip instead of PNG. For video demos.

## Mapping Arc to Slide Types
- Hook: `cover`
- Problem: `content`
- Cost: `content` or `stat`
- Shift: `content`
- System: `content`, `checklist`, `stat`, or `showcase` (2-4 slides)
- Proof: `quote`, `stat`, or `content`
- CTA: `cta`

## Workflow

### Step 1: Gather Context
1. Ask the user for: topic, target audience, and Instagram handle
2. If the user mentions a keyword (for comment automation), note it for the CTA slide

### Step 2: Draft Carousel Content
1. Write 3 hook options. Pick the one that creates the strongest curiosity gap.
2. Map each slide to the narrative arc.
3. Draft the slides following the writing rules.
4. Re-read every slide. Cut any line that does not need to be there.

Present the full carousel slide-by-slide in the chat, labeling each slide with its arc position (e.g., "Slide 3 [COST]").

### Step 3: Review
Present the draft. Wait for approval or edits before saving. Never skip the review step.

### Step 4: Save the JSON File
After approval, save the carousel JSON. The file format:

```json
{
  "name": "topic-slug",
  "brandColor": "#3B82F6",
  "backgroundStyle": "dark",
  "slides": [
    { "type": "cover", "hookText": "The headline text", "topicLabel": "TOPIC LABEL" },
    { "type": "content", "heading": "The Problem", "body": "Description of the pain point." },
    { "type": "checklist", "heading": "How to Fix It", "items": ["Step one", "Step two", "Step three"], "variant": "check" },
    { "type": "stat", "value": "3x", "label": "faster than doing it manually" },
    { "type": "cta", "ctaText": "Comment **KEYWORD** for the free guide", "handle": "@yourhandle" }
  ]
}
```

Save to: `carousel-output/{topic-slug}-carousel.json`

### Step 5: Render
Run the render command:

```bash
cd content-creation/remotion && node scripts/render-carousel.mjs path/to/carousel.json --output ~/Desktop/carousel-output
```

Each slide renders as a 1080x1350 PNG (or MP4 for showcase slides).

## Rules
- Maximum 10 slides (Instagram limit), minimum 3 (cover + 1 value + CTA)
- Each slide should make sense if someone only sees that one slide
- Always start with a cover slide, always end with a CTA slide
- One idea per slide. 5-7 lines max. Maximum white space.
- Bold one key word per takeaway line, not full sentences.
- Write at 6th grade level. No jargon. No fluff.
