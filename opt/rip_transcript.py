#!/usr/bin/env python3

import argparse
import json
import sys
from pathlib import Path
from typing import Any

DEFAULT_LANGUAGE = "en"
DEFAULT_WHISPER_MODEL_REPO = "mlx-community/whisper-large-v3-turbo"


class TranscriptError(Exception):
    """Raised when a transcript cannot be generated or written."""


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI parser for media transcription."""
    parser = argparse.ArgumentParser(
        prog="rip_transcript",
        description="Extract transcripts from audio or video files with mlx-whisper."
    )
    parser.add_argument(
        "media_paths",
        nargs="+",
        help="One or more audio/video file paths to transcribe.",
    )
    parser.add_argument(
        "--language",
        default=DEFAULT_LANGUAGE,
        help=f"Whisper language code. Defaults to '{DEFAULT_LANGUAGE}'.",
    )
    parser.add_argument(
        "--model-repo",
        default=DEFAULT_WHISPER_MODEL_REPO,
        help=(
            "Whisper model repo to use with mlx-whisper. "
            f"Defaults to '{DEFAULT_WHISPER_MODEL_REPO}'."
        ),
    )
    return parser


def validate_media_path(media_path: Path) -> Path:
    """Ensure the input path exists and points to a file."""
    candidate = media_path.expanduser()

    if not candidate.exists():
        raise TranscriptError(f"Input file does not exist: {candidate}")
    if not candidate.is_file():
        raise TranscriptError(f"Input path is not a file: {candidate}")

    return candidate


def transcribe_media(
    media_path: Path,
    *,
    whisper_model_repo: str,
    language: str,
) -> dict[str, Any]:
    """Transcribe the provided audio or video file with mlx-whisper."""
    try:
        import mlx_whisper
    except ImportError as exc:
        raise TranscriptError(
            "mlx-whisper is not installed for the selected Python runtime."
        ) from exc

    try:
        return mlx_whisper.transcribe(
            str(media_path),
            path_or_hf_repo=whisper_model_repo,
            language=language,
            word_timestamps=True,
            condition_on_previous_text=True,
        )
    except Exception as exc:
        raise TranscriptError(
            f"Failed to transcribe '{media_path}'. Details: {exc}"
        ) from exc


def format_seconds_as_timestamp(total_seconds: float | int) -> str:
    """Render seconds as M:SS or H:MM:SS for YouTube-style timestamps."""
    total_seconds_int = max(0, int(total_seconds))
    hours, remainder = divmod(total_seconds_int, 3600)
    minutes, seconds = divmod(remainder, 60)
    if hours:
        return f"{hours}:{minutes:02d}:{seconds:02d}"
    return f"{minutes}:{seconds:02d}"


def build_time_marker_transcript(transcription_result: dict[str, Any]) -> str:
    """Build a transcript where each segment is prefixed with its start timestamp."""
    segments = transcription_result.get("segments") or []
    lines: list[str] = []

    for segment in segments:
        if not isinstance(segment, dict):
            continue
        text = str(segment.get("text", "")).strip()
        if not text:
            continue
        start = segment.get("start", 0)
        lines.append(f"{format_seconds_as_timestamp(start)} - {text}")

    if lines:
        return "\n".join(lines).strip() + "\n"

    text = str(transcription_result.get("text", "")).strip()
    return f"{text}\n" if text else ""


def build_output_paths(media_path: Path) -> tuple[Path, Path, Path]:
    """Return sibling output paths derived from the media filename."""
    base_name = media_path.stem
    output_dir = media_path.parent
    return (
        output_dir / f"{base_name}.transcript.txt",
        output_dir / f"{base_name}.transcript_with_time_markers.txt",
        output_dir / f"{base_name}.transcription_result.json",
    )


def write_transcription_outputs(
    media_path: Path,
    transcription_result: dict[str, Any],
) -> tuple[Path, Path, Path]:
    """Persist transcript files next to the source media file."""
    transcript_path, transcript_with_time_markers_path, transcription_result_path = (
        build_output_paths(media_path)
    )

    transcript_text = str(transcription_result.get("text", "")).strip()

    try:
        transcript_path.write_text(f"{transcript_text}\n", encoding="utf-8")
        transcript_with_time_markers_path.write_text(
            build_time_marker_transcript(transcription_result),
            encoding="utf-8",
        )
        transcription_result_path.write_text(
            json.dumps(transcription_result, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
    except OSError as exc:
        raise TranscriptError(
            f"Failed to write transcript outputs for '{media_path}'. Details: {exc}"
        ) from exc

    return (
        transcript_path,
        transcript_with_time_markers_path,
        transcription_result_path,
    )


def process_media_file(
    media_path: Path,
    *,
    whisper_model_repo: str,
    language: str,
) -> tuple[Path, Path, Path]:
    """Transcribe one media file and write all output artifacts."""
    validated_path = validate_media_path(media_path)
    print(f"Transcribing '{validated_path}'...")
    transcription_result = transcribe_media(
        validated_path,
        whisper_model_repo=whisper_model_repo,
        language=language,
    )
    return write_transcription_outputs(validated_path, transcription_result)


def main() -> int:
    """CLI entrypoint."""
    parser = build_parser()
    args = parser.parse_args()

    failures = 0

    for media_path_arg in args.media_paths:
        media_path = Path(media_path_arg)

        try:
            transcript_path, transcript_with_time_markers_path, result_path = (
                process_media_file(
                    media_path,
                    whisper_model_repo=args.model_repo,
                    language=args.language,
                )
            )
        except TranscriptError as exc:
            failures += 1
            print(f"ERROR: {exc}", file=sys.stderr)
            continue

        print(f"Saved transcript: {transcript_path}")
        print(
            "Saved timestamped transcript: "
            f"{transcript_with_time_markers_path}"
        )
        print(f"Saved raw transcription result: {result_path}")

    if failures:
        print(f"Completed with {failures} failed file(s).", file=sys.stderr)

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
