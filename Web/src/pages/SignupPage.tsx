import { useState, type FormEvent } from "react";
import { Link } from "react-router-dom";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { Input } from "../components/ui/Input";
import { PasswordInput } from "../components/ui/PasswordInput";
import { useSignup } from "../hooks/useAuth";
import { getErrorMessage } from "../utils/errors";

export function SignupPage() {
  const signup = useSignup();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function handleSubmit(event: FormEvent) {
    event.preventDefault();
    signup.mutate({ name, email, password });
  }

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4 py-12">
      <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-6 shadow-lg sm:p-8 dark:border-border-dark dark:bg-card-dark">
        <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Create your account</h1>
        <p className="mt-2 text-sm text-slate-600 dark:text-slate-400">
          Start matching your resume to real job postings.
        </p>

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <Input
            label="Full name"
            name="name"
            required
            value={name}
            onChange={(event) => setName(event.target.value)}
          />
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
            autoComplete="new-password"
            required
            minLength={8}
            value={password}
            onChange={(event) => setPassword(event.target.value)}
          />
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Use at least 8 characters with letters and numbers.
          </p>

          {signup.isError ? <Alert message={getErrorMessage(signup.error, "Signup failed.")} /> : null}

          <Button type="submit" loading={signup.isPending} className="w-full">
            Sign up
          </Button>
        </form>

        <p className="mt-6 text-center text-sm text-slate-600 dark:text-slate-400">
          Already have an account?{" "}
          <Link
            to="/login"
            className="font-medium text-brand-600 hover:text-brand-700 dark:text-accent dark:hover:brightness-110"
          >
            Sign in
          </Link>
        </p>
      </div>
    </div>
  );
}
