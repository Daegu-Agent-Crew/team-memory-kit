---
name: tm-share
description: Draft approval-gated Slack, Discord, email, or chat messages for synced team memory updates.
---

# tm-share

Run:

```bash
bin/memory-share-plan --project <project> --title "<summary>"
```

The helper never writes externally. Review the draft with the user, including:

- destination candidates
- root message
- thread/body message
- source record, wiki, commit, or file links

Hard rule: do not call Slack, Discord, email, or chat write tools until the user
approves the exact destination and message body.
