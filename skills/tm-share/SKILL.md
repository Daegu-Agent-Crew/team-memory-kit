---
name: tm-share
description: Draft approval-gated Slack, Discord, email, or chat messages for synced team memory updates.
---

# tm-share

Run:

```bash
bin/memory-share-plan --project <project> --title "<summary>"
```

The helper never writes externally. Prefer running it after `memory-sync` so
commit and file links point at the synced source of truth. Review the draft with
the user, including:

- destination candidates
- root message
- thread/body message
- source record, wiki, commit, or file links

Hard rule: do not call Slack, Discord, email, or chat write tools until the user
approves the exact destination and message body.

If multiple destination candidates are plausible, ask which one to use. If no
destination is configured, ask the user whether to add
`context/registry/messengers/channels/<name>.yml` or produce a copyable draft
only.
