# Daily Notes

Vault: `~/Irandam Moolai/`. Today's daily: `98 - Dailies/<YYYY>/<Month>/<DD Mon YYYY>.md` (e.g. `98 - Dailies/2026/September/25 Sep 2026.md`). Shape: `## Work` and `## Personal`, each with `### Tasks`, `### Backlog`, `### Note`.

## "write a note"

When the user says "write a note" / "record this in the dailies", from any project: add the current investigation to today's daily under `## Work` > `### Note`. Replace the empty `- ` placeholder or append after existing entries. Touch nothing else in the file.

```
- <What broke, where, one line>, <root cause or fix in a few words>

> [!info]- Details
> **Issue:** <symptom with exact endpoint/host, status code, error string>
>
> **How found:**
> - <evidence step: resource name, log line, config value>
>
> **Fix (<where, e.g. sbx cluster, kubectl only>):** or **Host:** <where the fix has to happen, and whether I did it>
>
> **Side issue:** / **Follow-up, <topic>:** <optional>
>
> **Handoff:** <who was told, what they said they will do>
```

- Plain facts, backticks for names/values, absolute dates.
- Continues an earlier day: `continues from [[17 Sep 2026]]`.
- Handoff unknown: ask who was told.
- Reference entries: 15, 17, 18, 25 Sep 2026.
- Report the file path in one line when done.
