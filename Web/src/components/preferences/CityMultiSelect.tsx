import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { getCitiesForCountry } from "../../utils/cities";

interface CityMultiSelectProps {
  label: string;
  countryCode: string;
  cities: string[];
  onChange: (cities: string[]) => void;
  clearedNote?: string;
}

interface PanelPosition {
  top: number;
  left: number;
  width: number;
}

const PANEL_GAP_PX = 4;

/** Multi city picker with a searchable dropdown tied to the selected country. */
export function CityMultiSelect({
  label,
  countryCode,
  cities,
  onChange,
  clearedNote,
}: CityMultiSelectProps) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [panelPosition, setPanelPosition] = useState<PanelPosition | null>(null);

  const rootRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const panelRef = useRef<HTMLUListElement>(null);

  const availableCities = useMemo(() => getCitiesForCountry(countryCode), [countryCode]);

  const filteredCities = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return availableCities.filter((city) => {
      const alreadySelected = cities.some(
        (selected) => selected.toLowerCase() === city.toLowerCase(),
      );
      if (alreadySelected) {
        return false;
      }
      if (!normalizedQuery) {
        return true;
      }
      return city.toLowerCase().includes(normalizedQuery);
    });
  }, [availableCities, cities, query]);

  const updatePanelPosition = useCallback(() => {
    if (!inputRef.current) {
      return;
    }
    const rect = inputRef.current.getBoundingClientRect();
    setPanelPosition({
      top: rect.bottom + PANEL_GAP_PX,
      left: rect.left,
      width: rect.width,
    });
  }, []);

  useEffect(() => {
    if (!open) {
      setPanelPosition(null);
      return;
    }

    updatePanelPosition();

    window.addEventListener("resize", updatePanelPosition);
    window.addEventListener("scroll", updatePanelPosition, true);

    return () => {
      window.removeEventListener("resize", updatePanelPosition);
      window.removeEventListener("scroll", updatePanelPosition, true);
    };
  }, [open, query, updatePanelPosition]);

  useEffect(() => {
    if (!open) {
      return;
    }

    function handleClickOutside(event: MouseEvent) {
      const target = event.target as Node;
      if (inputRef.current?.contains(target)) {
        return;
      }
      if (panelRef.current?.contains(target)) {
        return;
      }
      if (rootRef.current?.contains(target)) {
        return;
      }
      setOpen(false);
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  function addCity(city: string) {
    if (cities.some((selected) => selected.toLowerCase() === city.toLowerCase())) {
      return;
    }
    onChange([...cities, city]);
    setQuery("");
    setOpen(false);
  }

  const hasCountry = Boolean(countryCode);

  const portaledDropdown =
    open && panelPosition && typeof document !== "undefined"
      ? createPortal(
          <ul
            ref={panelRef}
            role="listbox"
            style={{
              position: "fixed",
              top: panelPosition.top,
              left: panelPosition.left,
              width: panelPosition.width,
              zIndex: 9999,
            }}
            className="max-h-48 overflow-y-auto rounded-xl border border-slate-200 bg-surface-elevated shadow-xl dark:border-border-dark dark:bg-card-dark"
          >
            {filteredCities.length > 0 ? (
              filteredCities.map((city) => (
                <li key={city}>
                  <button
                    type="button"
                    role="option"
                    onClick={() => addCity(city)}
                    className="focus-ring w-full bg-surface-elevated px-3 py-3 text-left text-sm text-slate-700 transition hover:bg-slate-50 dark:bg-card-dark dark:text-slate-200 dark:hover:bg-slate-800"
                  >
                    {city}
                  </button>
                </li>
              ))
            ) : (
              <li className="bg-surface-elevated px-3 py-3 text-sm text-slate-500 dark:bg-card-dark dark:text-slate-400">
                No matching cities for this country.
              </li>
            )}
          </ul>,
          document.body,
        )
      : null;

  return (
    <div className="space-y-2" ref={rootRef}>
      <label className="block text-sm font-medium text-slate-700 dark:text-slate-300">{label}</label>

      <div className="rounded-xl border border-slate-300 bg-surface-elevated p-3 dark:border-border-dark dark:bg-card-dark">
        {cities.length > 0 ? (
          <div className="mb-2 flex flex-wrap gap-2">
            {cities.map((city) => (
              <span
                key={city}
                className="inline-flex items-center gap-1 rounded-full bg-brand-100 px-3 py-1.5 text-sm text-brand-900 dark:bg-accent/20 dark:text-accent"
              >
                {city}
                <button
                  type="button"
                  onClick={() => onChange(cities.filter((item) => item !== city))}
                  className="focus-ring flex h-6 w-6 items-center justify-center rounded-full text-brand-700 hover:text-brand-900 dark:text-accent dark:hover:text-white"
                  aria-label={`Remove ${city}`}
                >
                  x
                </button>
              </span>
            ))}
          </div>
        ) : null}

        {!hasCountry ? (
          <p className="py-2 text-sm text-slate-500 dark:text-slate-400">Select a country first.</p>
        ) : (
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={(event) => {
              setQuery(event.target.value);
              setOpen(true);
            }}
            onFocus={() => setOpen(true)}
            placeholder="Search and select a city"
            className="focus-ring w-full rounded-lg border border-slate-200 bg-white px-3 py-3 text-sm outline-none dark:border-border-dark dark:bg-surface-dark dark:text-slate-100"
            aria-expanded={open}
            aria-haspopup="listbox"
          />
        )}
      </div>

      {portaledDropdown}

      {clearedNote ? (
        <p className="text-xs text-amber-700 dark:text-amber-400">{clearedNote}</p>
      ) : null}
      <p className="text-xs text-slate-500 dark:text-slate-400">
        Select cities from the list for your chosen country. You can add multiple cities.
      </p>
    </div>
  );
}
