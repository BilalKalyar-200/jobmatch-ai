import { useState } from "react";
import { Link, NavLink, Outlet } from "react-router-dom";
import { useLogout } from "../../hooks/useAuth";
import { useTheme } from "../../hooks/useTheme";
import { CloseIcon, MenuIcon, MoonIcon, SunIcon } from "../ui/Icons";

const NAV_ITEMS = [
  { to: "/jobs", label: "Search" },
  { to: "/preferences", label: "Preferences" },
  { to: "/resume", label: "Resume" },
  { to: "/saved", label: "Saved" },
  { to: "/profile", label: "Profile" },
] as const;

function NavItem({ to, label, onClick }: { to: string; label: string; onClick?: () => void }) {
  return (
    <NavLink
      to={to}
      onClick={onClick}
      className={({ isActive }) =>
        `focus-ring group relative inline-flex min-h-[44px] items-center px-3 py-2 text-sm font-medium transition-all duration-200 ${
          isActive
            ? "text-brand-600 dark:text-accent"
            : "text-slate-600 hover:-translate-y-0.5 hover:text-brand-600 dark:text-slate-300 dark:hover:text-accent"
        }`
      }
    >
      {({ isActive }) => (
        <>
          {label}
          <span
            className={`absolute bottom-0 left-3 right-3 h-0.5 rounded-full transition-all duration-300 ${
              isActive
                ? "scale-x-100 bg-brand-600 dark:bg-accent"
                : "scale-x-0 bg-brand-400 group-hover:scale-x-100 dark:bg-accent/60"
            }`}
          />
        </>
      )}
    </NavLink>
  );
}

export function AppLayout() {
  const logout = useLogout();
  const { isDark, toggleTheme } = useTheme();
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-surface dark:bg-surface-dark">
      <header className="sticky top-0 z-30 border-b border-slate-200/80 bg-surface-elevated/90 backdrop-blur-md dark:border-border-dark dark:bg-card-dark/90">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-3 px-4 py-3">
          <Link
            to="/jobs"
            className="focus-ring rounded-lg text-xl font-bold text-brand-700 dark:text-accent"
          >
            JobMatch
          </Link>

          <nav className="hidden items-center gap-1 lg:flex">
            {NAV_ITEMS.map((item) => (
              <NavItem key={item.to} to={item.to} label={item.label} />
            ))}
          </nav>

          <div className="flex items-center gap-1">
            <button
              type="button"
              onClick={toggleTheme}
              className="focus-ring btn-lift flex h-11 w-11 items-center justify-center rounded-xl text-slate-600 transition hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800"
              aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}
            >
              {isDark ? <SunIcon /> : <MoonIcon />}
            </button>

            <button
              type="button"
              onClick={() => logout.mutate()}
              className="focus-ring btn-lift hidden min-h-[44px] rounded-xl px-3 py-2 text-sm font-medium text-slate-600 transition hover:bg-slate-100 lg:inline-flex lg:items-center dark:text-slate-300 dark:hover:bg-slate-800"
            >
              Logout
            </button>

            <button
              type="button"
              onClick={() => setMenuOpen((current) => !current)}
              className="focus-ring flex h-11 w-11 items-center justify-center rounded-xl text-slate-600 transition hover:bg-slate-100 lg:hidden dark:text-slate-300 dark:hover:bg-slate-800"
              aria-label={menuOpen ? "Close menu" : "Open menu"}
              aria-expanded={menuOpen}
            >
              {menuOpen ? <CloseIcon /> : <MenuIcon />}
            </button>
          </div>
        </div>

        {menuOpen ? (
          <div className="border-t border-slate-200 bg-surface-elevated px-4 py-3 lg:hidden dark:border-border-dark dark:bg-card-dark">
            <nav className="flex flex-col gap-1">
              {NAV_ITEMS.map((item) => (
                <NavItem
                  key={item.to}
                  to={item.to}
                  label={item.label}
                  onClick={() => setMenuOpen(false)}
                />
              ))}
              <button
                type="button"
                onClick={() => {
                  setMenuOpen(false);
                  logout.mutate();
                }}
                className="focus-ring mt-2 min-h-[44px] rounded-xl px-3 py-2 text-left text-sm font-medium text-slate-600 transition hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800"
              >
                Logout
              </button>
            </nav>
          </div>
        ) : null}
      </header>

      <main className="mx-auto max-w-6xl px-4 py-6 sm:py-8">
        <Outlet />
      </main>
    </div>
  );
}
