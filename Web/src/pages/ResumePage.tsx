import { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import { ResumeDropzone } from "../components/resume/ResumeDropzone";
import { ResumePreviewText } from "../components/resume/ResumePreviewText";
import { ScoreRing } from "../components/resume/ScoreRing";
import { Alert } from "../components/ui/Alert";
import { Button } from "../components/ui/Button";
import { useJobMatch } from "../hooks/useJobs";
import { useMyResume, useUploadResume } from "../hooks/useResume";
import type { JobMatchResponse } from "../types/job";
import { getErrorMessage } from "../utils/errors";

interface ResumeLocationState {
  matchResult?: JobMatchResponse;
  jobTitle?: string;
}

export function ResumePage() {
  const location = useLocation();
  const locationState = (location.state as ResumeLocationState | null) ?? {};
  const { data: resume, isLoading, isError, error } = useMyResume();
  const uploadResume = useUploadResume();
  const jobMatch = useJobMatch();

  const [matchResult, setMatchResult] = useState<JobMatchResponse | null>(
    locationState.matchResult ?? null,
  );
  const [jobTitle, setJobTitle] = useState(locationState.jobTitle ?? "");

  useEffect(() => {
    if (locationState.matchResult) {
      setMatchResult(locationState.matchResult);
      setJobTitle(locationState.jobTitle ?? "");
    }
  }, [locationState.matchResult, locationState.jobTitle]);

  function handleUpload(file: File) {
    uploadResume.mutate(file, {
      onSuccess: () => {
        setMatchResult(null);
      },
    });
  }

  function scoreWithDescription(description: string) {
    jobMatch.mutate(
      { job_description: description },
      {
        onSuccess: (response) => {
          setMatchResult(response.data);
        },
      },
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 sm:text-3xl dark:text-slate-100">
          Resume upload and scoring
        </h1>
        <p className="mt-2 text-slate-600 dark:text-slate-400">
          Upload a PDF or DOCX resume, then score it against a job from the job detail page.
        </p>
      </div>

      <ResumeDropzone onFileSelected={handleUpload} disabled={uploadResume.isPending} />

      {uploadResume.isError ? (
        <Alert message={getErrorMessage(uploadResume.error, "Upload failed.")} />
      ) : null}
      {uploadResume.isSuccess ? (
        <Alert message={uploadResume.data.data.message} variant="success" />
      ) : null}

      {isLoading ? <p className="text-slate-600 dark:text-slate-400">Checking for an uploaded resume...</p> : null}
      {isError ? (
        <Alert message={getErrorMessage(error, "No resume uploaded yet.")} variant="info" />
      ) : null}
      {resume ? (
        <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-5 dark:border-border-dark dark:bg-card-dark">
          <h2 className="font-semibold text-slate-900 dark:text-slate-100">Current resume</h2>
          <p className="mt-1 text-sm text-slate-600 dark:text-slate-400">{resume.filename}</p>
          <ResumePreviewText text={resume.text_preview} />
        </div>
      ) : null}

      {jobTitle ? (
        <p className="text-sm text-slate-600 dark:text-slate-400">
          Latest score request for: <span className="font-medium text-slate-900 dark:text-slate-200">{jobTitle}</span>
        </p>
      ) : null}

      {jobMatch.isError ? (
        <Alert message={getErrorMessage(jobMatch.error, "Scoring failed.")} />
      ) : null}

      {matchResult ? (
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-[auto_1fr]">
          <div className="flex justify-center rounded-2xl border border-slate-200 bg-surface-elevated p-6 dark:border-border-dark dark:bg-card-dark">
            <ScoreRing score={matchResult.final_score} />
          </div>

          <div className="space-y-4">
            <div className="rounded-2xl border border-slate-200 bg-surface-elevated p-5 dark:border-border-dark dark:bg-card-dark">
              <h2 className="font-semibold text-slate-900 dark:text-slate-100">Score breakdown</h2>
              <p className="mt-2 text-sm text-slate-600 dark:text-slate-400">{matchResult.scoring_formula}</p>
              <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
                <div className="rounded-xl bg-slate-50 p-3 dark:bg-surface-dark">
                  <p className="text-xs uppercase text-slate-500">Keyword score</p>
                  <p className="text-xl font-bold text-slate-900 dark:text-slate-100">{matchResult.keyword_score}%</p>
                </div>
                <div className="rounded-xl bg-slate-50 p-3 dark:bg-surface-dark">
                  <p className="text-xs uppercase text-slate-500">Semantic score</p>
                  <p className="text-xl font-bold text-slate-900 dark:text-slate-100">{matchResult.semantic_score}%</p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              <div className="rounded-2xl border border-green-200 bg-green-50 p-5 dark:border-green-900 dark:bg-green-950/30">
                <h3 className="font-semibold text-green-900 dark:text-green-300">Matched keywords</h3>
                <div className="mt-3 flex flex-wrap gap-2">
                  {matchResult.matched_keywords.length > 0 ? (
                    matchResult.matched_keywords.map((keyword) => (
                      <span
                        key={keyword}
                        className="rounded-full bg-white px-3 py-1 text-sm text-green-800 dark:bg-green-950 dark:text-green-300"
                      >
                        {keyword}
                      </span>
                    ))
                  ) : (
                    <p className="text-sm text-green-800 dark:text-green-300">No matched keywords yet.</p>
                  )}
                </div>
              </div>

              <div className="rounded-2xl border border-amber-200 bg-amber-50 p-5 dark:border-amber-900 dark:bg-amber-950/30">
                <h3 className="font-semibold text-amber-900 dark:text-amber-300">Missing keywords</h3>
                <div className="mt-3 flex flex-wrap gap-2">
                  {matchResult.missing_keywords.length > 0 ? (
                    matchResult.missing_keywords.map((keyword) => (
                      <span
                        key={keyword}
                        className="rounded-full bg-white px-3 py-1 text-sm text-amber-800 dark:bg-amber-950 dark:text-amber-300"
                      >
                        {keyword}
                      </span>
                    ))
                  ) : (
                    <p className="text-sm text-amber-800 dark:text-amber-300">No missing keywords.</p>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : null}

      {resume && !matchResult ? (
        <Button
          variant="secondary"
          onClick={() => scoreWithDescription(resume.text_preview)}
          loading={jobMatch.isPending}
        >
          Score using resume preview text
        </Button>
      ) : null}
    </div>
  );
}
