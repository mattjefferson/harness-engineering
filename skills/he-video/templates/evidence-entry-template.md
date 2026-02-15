### Browser Evidence: <scenario-id>

- failure video: `docs/artifacts/<slug>/browser/<scenario-id>/failure-<timestamp>.webm`
- resolution video: `docs/artifacts/<slug>/browser/<scenario-id>/resolution-<timestamp>.webm`
- failure screenshot: `docs/artifacts/<slug>/browser/<scenario-id>/failure-final-<timestamp>.png`
- resolution screenshot: `docs/artifacts/<slug>/browser/<scenario-id>/resolution-final-<timestamp>.png`
- manifest: `docs/artifacts/<slug>/browser/<scenario-id>/manifest.tsv`
- capture commands:

    bash skills/he-video/scripts/record-browser-evidence.sh \
      --slug <slug> \
      --scenario <scenario-id> \
      --phase failure \
      --flow-script <flow-script-path>

    bash skills/he-video/scripts/record-browser-evidence.sh \
      --slug <slug> \
      --scenario <scenario-id> \
      --phase resolution \
      --flow-script <flow-script-path>

- notes: Same scenario and same flow script used for both phases.
