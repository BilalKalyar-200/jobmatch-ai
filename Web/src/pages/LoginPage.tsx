import { useState, type FormEvent } from "react";
import { Link } from "react-router-dom";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { Input } from "../components/ui/Input";
import { PasswordInput } from "../components/ui/PasswordInput";
import { useLogin } from "../hooks/useAuth";
import { getErrorMessage } from "../utils/errors";

export function LoginPage() {
  const login = useLogin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    login.mutate({ email, password });
  }

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4 py-12">
      <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-6 shadow-lg sm:p-8 dark:border-border-dark dark:bg-card-dark">
        <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Welcome back</h1>
        <p className="mt-2 text-sm text-slate-600 dark:text-slate-400">
          Sign in to search jobs and score your resume.
        </p>

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <Input
            label="Email"
            name="email"
            type="email"
            autoComplete="email"
            required
            value={email}
            onChange={(event) => setEmail(event.target.value)}
          />
          <PasswordInput
            label="Password"
            name="password"
            autoComplete="current-password"
            required
            value={password}
            onChange={(event) => setPassword(event.target.value)}
          />

          {login.isError ? <Alert message={getErrorMessage(login.error, "Login failed.")} /> : null}

          <Button type="submit" loading={login.isPending} className="w-full">
            Sign in
          </Button>
        </form>

        <p className="mt-6 text-center text-sm text-slate-600 dark:text-slate-400">
          No account yet?{" "}
          <Link
            to="/signup"
            className="font-medium text-brand-600 hover:text-brand-700 dark:text-accent dark:hover:brightness-110"
          >
            Create one
          </Link>
        </p>
      </div>
    </div>
  );
}
