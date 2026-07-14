import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { CityMultiSelect } from "../components/preferences/CityMultiSelect";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { Input } from "../components/ui/Input";
import { Select } from "../components/ui/Select";
import { useProfile, useUpdateProfile } from "../hooks/useAuth";
import { COUNTRIES } from "../utils/countries";
import { getErrorMessage } from "../utils/errors";

export function PreferencesPage() {
  const navigate = useNavigate();
  const { data: profile, isLoading } = useProfile();
  const updateProfile = useUpdateProfile();

  const [niche, setNiche] = useState("");
  const [countryCode, setCountryCode] = useState("");
  const [cities, setCities] = useState<string[]>([]);
  const [successMessage, setSuccessMessage] = useState("");
  const [clearedNote, setClearedNote] = useState("");
  const previousCountryRef = useRef<string>("");

  useEffect(() => {
    if (!profile) {
      return;
    }
    const loadedCountry = profile.preferred_countries[0]?.toLowerCase() ?? "";
    setNiche(profile.preferred_niches[0] ?? "");
    setCountryCode(loadedCountry);
    setCities(profile.preferred_cities ?? []);
    previousCountryRef.current = loadedCountry;
  }, [profile]);

  function handleCountryChange(newCode: string) {
    if (previousCountryRef.current && newCode !== previousCountryRef.current && cities.length > 0) {
      setCities([]);
      setClearedNote("Cities were cleared because you changed the country.");
    } else {
      setClearedNote("");
    }
    previousCountryRef.current = newCode;
    setCountryCode(newCode);
  }

  function handleSave() {
    setSuccessMessage("");
    updateProfile.mutate(
      {
        preferred_niches: niche ? [niche] : [],
        preferred_countries: countryCode ? [countryCode] : [],
        preferred_cities: cities,
      },
      {
        onSuccess: () => {
          setSuccessMessage("Preferences saved.");
          navigate("/jobs");
        },
      },
    );
  }

  if (isLoading) {
    return <p className="text-slate-600 dark:text-slate-400">Loading preferences...</p>;
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 sm:text-3xl dark:text-slate-100">Job preferences</h1>
        <p className="mt-2 text-slate-600 dark:text-slate-400">
          Choose your niche, country, and cities. Country names are shown in the UI, but only ISO
          codes are sent to the backend.
        </p>
      </div>

      <div className="space-y-5 rounded-2xl border border-slate-200 bg-surface-elevated p-5 shadow-sm sm:p-6 dark:border-border-dark dark:bg-card-dark">
        <Input
          label="Niche or role"
          name="niche"
          placeholder="e.g. React developer, data scientist"
          value={niche}
          onChange={(event) => setNiche(event.target.value)}
        />

        <Select
          label="Country"
          name="country"
          value={countryCode}
          onChange={(event) => handleCountryChange(event.target.value)}
          options={[
            { label: "Select a country", value: "" },
            ...COUNTRIES.map((country) => ({
              label: country.name,
              value: country.code,
            })),
          ]}
        />

        <CityMultiSelect
          label="Cities"
          countryCode={countryCode}
          cities={cities}
          onChange={setCities}
          clearedNote={clearedNote}
        />

        {updateProfile.isError ? (
          <Alert message={getErrorMessage(updateProfile.error, "Could not save preferences.")} />
        ) : null}
        {successMessage ? <Alert message={successMessage} variant="success" /> : null}

        <Button
          onClick={handleSave}
          loading={updateProfile.isPending}
          disabled={!niche || !countryCode || cities.length === 0}
          className="w-full sm:w-auto"
        >
          Save and search jobs
        </Button>
      </div>
    </div>
  );
}
