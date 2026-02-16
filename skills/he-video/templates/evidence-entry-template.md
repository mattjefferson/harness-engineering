### Browser Evidence: <scenario-id>

- raw failure video: `tmp/artifacts/<slug>/browser/<scenario-id>/failure-<timestamp>.webm`
- raw resolution video: `tmp/artifacts/<slug>/browser/<scenario-id>/resolution-<timestamp>.webm`
- raw failure screenshot: `tmp/artifacts/<slug>/browser/<scenario-id>/failure-final-<timestamp>.png`
- raw resolution screenshot: `tmp/artifacts/<slug>/browser/<scenario-id>/resolution-final-<timestamp>.png`
- raw manifest: `tmp/artifacts/<slug>/browser/<scenario-id>/manifest.tsv`
- promoted minimal set (optional):
  - `docs/artifacts/<slug>/browser/<scenario-id>/resolution-final-<timestamp>.png`
  - `docs/artifacts/<slug>/browser/<scenario-id>/manifest.tsv`
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

    # Optional: promote minimal committed evidence for PR/release review.
    bash skills/he-video/scripts/promote-browser-evidence.sh \
      --slug <slug> \
      --scenario <scenario-id> \
      --phase resolution

- notes: Same scenario and same flow script used for both phases.
