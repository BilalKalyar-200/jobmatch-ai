/**
 * Curated major cities keyed by ISO 3166-1 alpha-2 country code.
 * Add new countries by extending this map with their code and city list.
 */
export const CITIES_BY_COUNTRY: Record<string, string[]> = {
  us: [
    "New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia",
    "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Seattle",
    "Denver", "Boston", "Miami", "Atlanta", "San Francisco", "Washington DC",
  ],
  gb: [
    "London", "Manchester", "Birmingham", "Leeds", "Glasgow", "Liverpool",
    "Edinburgh", "Bristol", "Sheffield", "Newcastle", "Nottingham", "Cardiff",
  ],
  ca: [
    "Toronto", "Montreal", "Vancouver", "Calgary", "Edmonton", "Ottawa",
    "Winnipeg", "Quebec City", "Halifax", "Victoria",
  ],
  au: [
    "Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Canberra",
    "Gold Coast", "Hobart", "Darwin",
  ],
  de: ["Berlin", "Munich", "Hamburg", "Frankfurt", "Cologne", "Stuttgart", "Dusseldorf", "Leipzig"],
  fr: ["Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Nantes", "Bordeaux", "Lille"],
  nl: ["Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Eindhoven", "Groningen"],
  se: ["Stockholm", "Gothenburg", "Malmo", "Uppsala"],
  no: ["Oslo", "Bergen", "Trondheim", "Stavanger"],
  dk: ["Copenhagen", "Aarhus", "Odense", "Aalborg"],
  fi: ["Helsinki", "Espoo", "Tampere", "Turku"],
  ie: ["Dublin", "Cork", "Galway", "Limerick"],
  ch: ["Zurich", "Geneva", "Basel", "Bern", "Lausanne"],
  at: ["Vienna", "Graz", "Linz", "Salzburg"],
  be: ["Brussels", "Antwerp", "Ghent", "Bruges"],
  es: ["Madrid", "Barcelona", "Valencia", "Seville", "Bilbao", "Malaga"],
  it: ["Rome", "Milan", "Naples", "Turin", "Florence", "Bologna"],
  pt: ["Lisbon", "Porto", "Braga", "Coimbra"],
  pl: ["Warsaw", "Krakow", "Wroclaw", "Gdansk", "Poznan"],
  cz: ["Prague", "Brno", "Ostrava", "Plzen"],
  in: [
    "Mumbai", "Delhi", "Bangalore", "Hyderabad", "Chennai", "Kolkata",
    "Pune", "Ahmedabad", "Jaipur", "Lucknow", "Chandigarh", "Noida",
  ],
  pk: [
    "Karachi", "Lahore", "Islamabad", "Rawalpindi", "Faisalabad", "Multan",
    "Peshawar", "Quetta", "Sialkot", "Hyderabad", "Gujranwala", "Abbottabad",
    "Sargodha", "Bahawalpur", "Sukkur", "Mardan", "Muzaffarabad",
  ],
  bd: ["Dhaka", "Chittagong", "Khulna", "Rajshahi", "Sylhet", "Gazipur"],
  ae: ["Dubai", "Abu Dhabi", "Sharjah", "Ajman", "Al Ain"],
  sa: ["Riyadh", "Jeddah", "Mecca", "Medina", "Dammam", "Khobar"],
  sg: ["Singapore"],
  my: ["Kuala Lumpur", "Penang", "Johor Bahru", "Ipoh", "Malacca"],
  id: ["Jakarta", "Surabaya", "Bandung", "Medan", "Bali", "Semarang"],
  ph: ["Manila", "Quezon City", "Cebu", "Davao", "Makati", "Taguig"],
  jp: ["Tokyo", "Osaka", "Yokohama", "Nagoya", "Sapporo", "Fukuoka", "Kyoto"],
  kr: ["Seoul", "Busan", "Incheon", "Daegu", "Daejeon", "Gwangju"],
  cn: ["Beijing", "Shanghai", "Shenzhen", "Guangzhou", "Hangzhou", "Chengdu", "Wuhan"],
  hk: ["Hong Kong", "Kowloon", "New Territories"],
  nz: ["Auckland", "Wellington", "Christchurch", "Hamilton", "Dunedin"],
  za: ["Johannesburg", "Cape Town", "Durban", "Pretoria", "Port Elizabeth"],
  ng: ["Lagos", "Abuja", "Port Harcourt", "Kano", "Ibadan"],
  ke: ["Nairobi", "Mombasa", "Kisumu", "Nakuru"],
  eg: ["Cairo", "Alexandria", "Giza", "Luxor"],
  br: ["Sao Paulo", "Rio de Janeiro", "Brasilia", "Salvador", "Fortaleza", "Curitiba"],
  mx: ["Mexico City", "Guadalajara", "Monterrey", "Puebla", "Tijuana"],
  ar: ["Buenos Aires", "Cordoba", "Rosario", "Mendoza"],
  co: ["Bogota", "Medellin", "Cali", "Barranquilla", "Cartagena"],
  cl: ["Santiago", "Valparaiso", "Concepcion", "Vina del Mar"],
  tr: ["Istanbul", "Ankara", "Izmir", "Bursa", "Antalya"],
  il: ["Tel Aviv", "Jerusalem", "Haifa", "Beersheba"],
  qa: ["Doha", "Al Wakrah", "Al Khor"],
  kw: ["Kuwait City", "Hawalli", "Salmiya"],
  ro: ["Bucharest", "Cluj-Napoca", "Timisoara", "Iasi"],
  hu: ["Budapest", "Debrecen", "Szeged", "Pecs"],
  gr: ["Athens", "Thessaloniki", "Patras", "Heraklion"],
  ua: ["Kyiv", "Lviv", "Odessa", "Kharkiv", "Dnipro"],
};

export function getCitiesForCountry(countryCode: string | null | undefined): string[] {
  if (!countryCode) {
    return [];
  }
  return CITIES_BY_COUNTRY[countryCode.toLowerCase()] ?? [];
}
