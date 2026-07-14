export interface UserProfileResponse {
  id: string;
  email: string;
  name: string;
  preferred_niches: string[];
  preferred_countries: string[];
  preferred_cities: string[];
  created_at: string;
  updated_at: string;
}

export interface UserProfileUpdateRequest {
  name?: string;
  preferred_niches?: string[];
  preferred_countries?: string[];
  preferred_cities?: string[];
}
