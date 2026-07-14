import { Navigate, Route, Routes } from "react-router-dom";
import { PublicOnlyRoute, ProtectedRoute } from "./components/auth/ProtectedRoute";
import { AppLayout } from "./components/layout/AppLayout";
import { JobDetailPage } from "./pages/JobDetailPage";
import { JobSearchPage } from "./pages/JobSearchPage";
import { LoginPage } from "./pages/LoginPage";
import { PreferencesPage } from "./pages/PreferencesPage";
import { ProfilePage } from "./pages/ProfilePage";
import { ResumePage } from "./pages/ResumePage";
import { SavedJobsPage } from "./pages/SavedJobsPage";
import { SignupPage } from "./pages/SignupPage";

export default function App() {
  return (
    <Routes>
      <Route element={<PublicOnlyRoute />}>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signup" element={<SignupPage />} />
      </Route>

      <Route element={<ProtectedRoute />}>
        <Route element={<AppLayout />}>
          <Route path="/" element={<Navigate to="/jobs" replace />} />
          <Route path="/jobs" element={<JobSearchPage />} />
          <Route path="/jobs/:jobId" element={<JobDetailPage />} />
          <Route path="/preferences" element={<PreferencesPage />} />
          <Route path="/resume" element={<ResumePage />} />
          <Route path="/saved" element={<SavedJobsPage />} />
          <Route path="/profile" element={<ProfilePage />} />
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/jobs" replace />} />
    </Routes>
  );
}
