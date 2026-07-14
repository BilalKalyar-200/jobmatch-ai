/**
 * Display-only formatting for resume preview text.
 * Never use this output for API calls or matching requests.
 */

const RESUME_SECTION_HEADERS = [
  "Summary",
  "Professional Summary",
  "Objective",
  "Profile",
  "Experience",
  "Work Experience",
  "Professional Experience",
  "Employment History",
  "Education",
  "Skills",
  "Technical Skills",
  "Core Competencies",
  "Projects",
  "Certifications",
  "Licenses and Certifications",
  "Achievements",
  "Awards",
  "Languages",
  "Interests",
  "References",
];

function hasLineBreaks(text: string): boolean {
  return /[\r\n]/.test(text);
}

function insertSectionBreaks(text: string): string {
  const headerPattern = new RegExp(
    `(\\s)(${RESUME_SECTION_HEADERS.join("|")})(?=\\s|:|$)`,
    "g",
  );

  let formatted = text.replace(headerPattern, "\n\n$2");
  formatted = formatted.replace(
    new RegExp(`^(${RESUME_SECTION_HEADERS.join("|")})(?=\\s|:|$)`, "i"),
    "\n\n$1",
  );

  return formatted.replace(/\n{3,}/g, "\n\n").trim();
}

export function formatResumePreviewForDisplay(text: string): string {
  if (!text.trim()) {
    return text;
  }

  if (hasLineBreaks(text)) {
    return text;
  }

  return insertSectionBreaks(text);
}
