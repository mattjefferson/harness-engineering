#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import shutil
import subprocess
import sys
from pathlib import Path


def _run(cmd: list[str], *, check: bool = True, capture: bool = False, log_file=None) -> str:
    if capture:
        out = subprocess.check_output(cmd, text=True)
        return out.strip()
    if log_file is not None:
        subprocess.run(cmd, check=check, stdout=log_file, stderr=subprocess.STDOUT, text=True)
    else:
        subprocess.run(cmd, check=check)
    return ""


def _run_flow(flow_script: Path, *, log_path: Path) -> int:
    cmd: list[str]
    if flow_script.suffix.lower() == ".py":
        cmd = [sys.executable, str(flow_script)]
    elif flow_script.suffix.lower() == ".sh":
        bash = shutil.which("bash")
        if not bash:
            raise RuntimeError(
                f"flow-script '{flow_script}' is a .sh file but 'bash' was not found. "
                "Use a Python flow script on this machine."
            )
        cmd = [bash, str(flow_script)]
    else:
        # Try to execute directly (shebang / executable bit, or a .cmd/.bat on Windows).
        cmd = [str(flow_script)]

    with log_path.open("a", encoding="utf-8") as f:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        assert proc.stdout is not None
        for line in proc.stdout:
            sys.stdout.write(line)
            f.write(line)
        return proc.wait()


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        prog="record-browser-evidence.py",
        description="Wrap an agent-browser flow script with video recording and durable artifact output.",
    )
    parser.add_argument("--slug", required=True)
    parser.add_argument("--scenario", required=True)
    parser.add_argument("--phase", required=True, choices=["failure", "resolution"])
    parser.add_argument("--flow-script", required=True, help="Path to a flow script (Python preferred).")
    parser.add_argument("--output-root", default="docs/artifacts")
    parser.add_argument("--session", default="")
    parser.add_argument("--keep-browser-open", action="store_true")

    args = parser.parse_args(argv)

    flow_script = Path(args.flow_script).resolve()
    if not flow_script.is_file():
        print(f"Error: flow script not found: {flow_script}", file=sys.stderr)
        return 2

    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = Path(args.output_root) / args.slug / "browser" / args.scenario
    out_dir.mkdir(parents=True, exist_ok=True)

    video_path = out_dir / f"{args.phase}-{timestamp}.webm"
    shot_path = out_dir / f"{args.phase}-final-{timestamp}.png"
    log_path = out_dir / f"{args.phase}-{timestamp}.log"
    manifest_path = out_dir / "manifest.tsv"

    agent_cmd = ["agent-browser"]
    if args.session:
        agent_cmd.extend(["--session", args.session])

    # Write initial log metadata.
    log_path.write_text(
        "\n".join(
            [
                f"timestamp={timestamp}",
                f"slug={args.slug}",
                f"scenario={args.scenario}",
                f"phase={args.phase}",
                f"flow_script={flow_script}",
                f"session={args.session or 'default'}",
                f"output_dir={out_dir}",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    def cleanup() -> None:
        try:
            _run(agent_cmd + ["record", "stop"], check=False)
        except Exception:
            pass
        if not args.keep_browser_open:
            try:
                _run(agent_cmd + ["close"], check=False)
            except Exception:
                pass

    print(f"Recording {args.phase} evidence for scenario '{args.scenario}'")
    print(f"Output directory: {out_dir}")
    print(f"Video target: {video_path}")

    flow_exit = 0
    try:
        _run(agent_cmd + ["record", "start", str(video_path)])
        flow_exit = _run_flow(flow_script, log_path=log_path)

        with log_path.open("a", encoding="utf-8") as f:
            f.write(f"flow_exit={flow_exit}\n")

        # Best-effort final capture context.
        with log_path.open("a", encoding="utf-8") as f:
            try:
                _run(agent_cmd + ["screenshot", str(shot_path)], check=False, log_file=f)
            except Exception:
                pass
            try:
                final_url = _run(agent_cmd + ["get", "url"], capture=True)
                if final_url:
                    f.write(f"final_url={final_url}\n")
            except Exception:
                pass

        with log_path.open("a", encoding="utf-8") as f:
            _run(agent_cmd + ["record", "stop"], check=False, log_file=f)
            if not args.keep_browser_open:
                _run(agent_cmd + ["close"], check=False, log_file=f)
    finally:
        cleanup()

    if (not video_path.exists()) or (video_path.stat().st_size == 0):
        print(f"Error: recording file missing or empty: {video_path}", file=sys.stderr)
        return 1

    if not manifest_path.exists():
        manifest_path.write_text("timestamp\tphase\tvideo\tscreenshot\tflow_exit\tflow_script\n", encoding="utf-8")

    with manifest_path.open("a", encoding="utf-8") as f:
        f.write(
            "\t".join(
                [
                    timestamp,
                    args.phase,
                    str(video_path),
                    str(shot_path),
                    str(flow_exit),
                    str(flow_script),
                ]
            )
            + "\n"
        )

    print(f"Saved video: {video_path}")
    print(f"Saved screenshot: {shot_path}")
    print(f"Saved log: {log_path}")
    print(f"Updated manifest: {manifest_path}")

    if args.phase == "resolution" and flow_exit != 0:
        print(f"Error: resolution capture flow exited non-zero ({flow_exit}).", file=sys.stderr)
        return flow_exit

    if args.phase == "failure" and flow_exit != 0:
        print(f"Note: failure flow exited non-zero ({flow_exit}), which is allowed.", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

