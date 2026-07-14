/** Country option for UI display. Only `code` is sent to the backend. */
export interface CountryOption {
  name: string;
  code: string;
}

/**
 * Static ISO 3166-1 alpha-2 country list.
 * The UI shows `name` (e.g. "Pakistan") but every API call uses `code` (e.g. "pk").
 */
export const COUNTRIES: CountryOption[] = [
  { name: "United States", code: "us" },
  { name: "United Kingdom", code: "gb" },
  { name: "Canada", code: "ca" },
  { name: "Australia", code: "au" },
  { name: "Germany", code: "de" },
  { name: "France", code: "fr" },
  { name: "Netherlands", code: "nl" },
  { name: "Sweden", code: "se" },
  { name: "Norway", code: "no" },
  { name: "Denmark", code: "dk" },
  { name: "Finland", code: "fi" },
  { name: "Ireland", code: "ie" },
  { name: "Switzerland", code: "ch" },
  { name: "Austria", code: "at" },
  { name: "Belgium", code: "be" },
  { name: "Spain", code: "es" },
  { name: "Italy", code: "it" },
  { name: "Portugal", code: "pt" },
  { name: "Poland", code: "pl" },
  { name: "Czech Republic", code: "cz" },
  { name: "India", code: "in" },
  { name: "Pakistan", code: "pk" },
  { name: "Bangladesh", code: "bd" },
  { name: "United Arab Emirates", code: "ae" },
  { name: "Saudi Arabia", code: "sa" },
  { name: "Singapore", code: "sg" },
  { name: "Malaysia", code: "my" },
  { name: "Indonesia", code: "id" },
  { name: "Philippines", code: "ph" },
  { name: "Japan", code: "jp" },
  { name: "South Korea", code: "kr" },
  { name: "China", code: "cn" },
  { name: "Hong Kong", code: "hk" },
  { name: "New Zealand", code: "nz" },
  { name: "South Africa", code: "za" },
  { name: "Nigeria", code: "ng" },
  { name: "Kenya", code: "ke" },
  { name: "Egypt", code: "eg" },
  { name: "Brazil", code: "br" },
  { name: "Mexico", code: "mx" },
  { name: "Argentina", code: "ar" },
  { name: "Colombia", code: "co" },
  { name: "Chile", code: "cl" },
  { name: "Turkey", code: "tr" },
  { name: "Israel", code: "il" },
  { name: "Qatar", code: "qa" },
  { name: "Kuwait", code: "kw" },
  { name: "Romania", code: "ro" },
  { name: "Hungary", code: "hu" },
  { name: "Greece", code: "gr" },
  { name: "Ukraine", code: "ua" },
].sort((a, b) => a.name.localeCompare(b.name));

export function getCountryName(code: string): string {
  const normalized = code.toLowerCase();
  return COUNTRIES.find((country) => country.code === normalized)?.name ?? code.toUpperCase();
}

export function getCountryCode(nameOrCode: string): string {
  const normalized = nameOrCode.toLowerCase();
  const byCode = COUNTRIES.find((country) => country.code === normalized);
  if (byCode) {
    return byCode.code;
  }
  const byName = COUNTRIES.find((country) => country.name.toLowerCase() === normalized);
  return byName?.code ?? normalized;
}
