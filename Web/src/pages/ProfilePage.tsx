import { useEffect, useRef, useState } from "react";
import { CityMultiSelect } from "../components/preferences/CityMultiSelect";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { TrashIcon } from "../components/ui/Icons";
import { Input } from "../components/ui/Input";
import { Select } from "../components/ui/Select";
import { useLogout, useProfile, useUpdateProfile } from "../hooks/useAuth";
import { useDeleteSearchHistory, useSearchHistory } from "../hooks/useSavedJobs";
import { COUNTRIES, getCountryName } from "../utils/countries";
import { getErrorMessage } from "../utils/errors";

export function ProfilePage() {
  const { data: profile, isLoading } = useProfile();
  const updateProfile = useUpdateProfile();
  const logout = useLogout();
  const { data: searchHistory } = useSearchHistory();
  const deleteSearchHistory = useDeleteSearchHistory();

  const [name, setName] = useState("");
  const [niche, setNiche] = useState("");
  const [countryCode, setCountryCode] = useState("");
  const [cities, setCities] = useState<string[]>([]);
  const [successMessage, setSuccessMessage] = useState("");
  const [clearedNote, setClearedNote] = useState("");
  const [deleteError, setDeleteError] = useState("");
  const previousCountryRef = useRef<string>("");

  useEffect(() => {
    if (!profile) {
      return;
    }
    const loadedCountry = profile.preferred_countries[0]?.toLowerCase() ?? "";
    setName(profile.name);
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
        name,
        preferred_niches: niche ? [niche] : [],
        preferred_countries: countryCode ? [countryCode] : [],
        preferred_cities: cities,
      },
      {
        onSuccess: () => setSuccessMessage("Profile updated."),
      },
    );
  }

  function handleDeleteSearch(searchId: string) {
    setDeleteError("");
    deleteSearchHistory.mutate(searchId, {
      onError: (error) => {
        setDeleteError(getErrorMessage(error, "Could not delete search history entry."));
      },
    });
  }

  if (isLoading || !profile) {
    return <p className="text-slate-600 dark:text-slate-400">Loading profile...</p>;
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 sm:text-3xl dark:text-slate-100">Profile</h1>
          <p className="mt-2 text-slate-600 dark:text-slate-400">{profile.email}</p>
        </div>
        <Button variant="secondary" onClick={() => logout.mutate()} loading={logout.isPending}>
          Logout
        </Button>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="space-y-4 rounded-2xl border border-slate-200 bg-surface-elevated p-5 shadow-sm sm:p-6 dark:border-border-dark dark:bg-card-dark">
          <Input label="Name" name="name" value={name} onChange={(event) => setName(event.target.value)} />
          <Input
            label="Niche or role"
            name="niche"
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
            <Alert message={getErrorMessage(updateProfile.error, "Could not update profile.")} />
          ) : null}
          {successMessage ? <Alert message={successMessage} variant="success" /> : null}

          <Button onClick={handleSave} loading={updateProfile.isPending}>
            Save changes
          </Button>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-5 shadow-sm sm:p-6 dark:border-border-dark dark:bg-card-dark">
          <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">Recent searches</h2>

          {deleteError ? <div className="mt-3"><Alert message={deleteError} /></div> : null}

          <div className="mt-4 space-y-3">
            {searchHistory && searchHistory.total > 0 ? (
              searchHistory.searches.map((search) => (
                <div
                  key={search.id}
                  className="flex items-start justify-between gap-3 rounded-xl bg-slate-50 p-3 text-sm dark:bg-surface-dark"
                >
                  <div className="min-w-0 flex-1">
                    <p className="font-medium text-slate-900 dark:text-slate-100">{search.niche}</p>
                    <p className="text-slate-600 dark:text-slate-400">
                      {search.cities.join(", ")}, {getCountryName(search.country)}
                    </p>
                    <p className="mt-1 text-xs text-slate-500 dark:text-slate-500">
                      {new Date(search.created_at).toLocaleString()}
                    </p>
                  </div>
                  <button
                    type="button"
                    onClick={() => handleDeleteSearch(search.id)}
                    disabled={deleteSearchHistory.isPending}
                    className="focus-ring flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-slate-500 transition hover:bg-red-50 hover:text-red-600 dark:text-slate-400 dark:hover:bg-red-950/40 dark:hover:text-red-400"
                    aria-label={`Delete search for ${search.niche}`}
                  >
                    <TrashIcon />
                  </button>
                </div>
              ))
            ) : (
              <p className="text-sm text-slate-600 dark:text-slate-400">No search history yet.</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
