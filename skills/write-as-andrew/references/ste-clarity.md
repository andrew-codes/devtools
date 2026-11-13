# Clarity layer: ASD-STE100 for everyday writing

`SKILL.md` holds the rules that change output the most. Read this file when you draft a procedure,
a runbook, a long doc or a README section, or when a rule in `SKILL.md` is unclear.

## Source and scope

ASD-STE100 Simplified Technical English is a controlled language. Aerospace maintenance manuals use
it so that a reader who is tired, rushed or reading English as a second language cannot misread an
instruction. Issue 9 (January 2025) has 53 writing rules in 9 sections, plus a dictionary of about
900 approved words with the rejected words and the approved alternatives for each. ASD publishes
the standard as a free download at asd-ste100.org.

This skill borrows the writing rules as a clarity layer. It paraphrases them with software
examples and does not copy the standard's text or its dictionary. It does not make a draft
STE-compliant and must not claim that it does. No tool can guarantee compliance, and the dictionary
rules need the official document.

What this layer adopts and what it leaves out:

| Adopted | Left out |
| :------ | :------- |
| Sentence length limits, one instruction per sentence, condition before command | The approved-word dictionary and its part-of-speech rulings |
| Active voice, simple tenses, plain verbs | The ban on every contraction (his corpus rules apply instead) |
| One word per meaning for the whole piece | Replacing every "check" with "make sure that" |
| Noun clusters of three words or fewer | Replacing "since", "however" and "any" by rule (a soft preference only) |
| Complete grammar: keep articles and "that" | A blanket ban on questions and suggestions |
| Warnings that put the command first, then the risk | The ban on every semicolon (a correct one between independent clauses stays) |
| Two sentences instead of a phrase tacked on after a semicolon | Any rule about chat replies, bold labels or list formatting. His PR descriptions use bold labels such as `**Verified:**` |

## Procedural and descriptive text

Classify each passage before you write it. The two kinds have different limits.

| | Procedural | Descriptive |
| :-- | :--------- | :---------- |
| Job | Tells the reader what to do | Explains what is true or why |
| Examples | Setup steps, a test plan, a runbook step, a commit subject, a warning | A PR summary, a README intro, the reason for a change, an architecture note |
| Mood and tense | Imperative: "Run the migration." | Simple present, simple past, simple future |
| Sentence limit | 20 words | 25 words |
| Shape | One instruction per sentence, condition first | One new fact per sentence, one topic per paragraph, six sentences at most |

A PR description is usually both. The summary and the reason are descriptive. The test plan is
procedural. Hold each part to its own limit.

How to count: a path, an identifier, a quoted string, a number with its unit, and text in
backticks each count as one word. A colon that introduces a vertical list ends the sentence, and
each list item starts a new count.

## The rules in detail

Numbers refer to the order in `SKILL.md`, not to the standard.

**Sentences.** Short does not mean terse. Keep the articles (a, an, the) and the word "that". Write
"Make sure that a backup exists. Then run the migration." and not "Ensure backup exists before
running." A shortened sentence that drops words is a new ambiguity.

**Condition first.** A reader executes a command as soon as they read it. Put the condition before
it, with a comma: "If the build fails, read the log." A trailing "if the flag is set" arrives too
late.

**Active voice.** Name who acts. "The script reads the token from the keychain", not "The token is
read from the keychain". Use "you" for the reader and "we" for the team. The passive is for an
actor that is unknown or does not matter, never for a step the reader performs.

**Simple tenses.** Use simple present for how a thing works now, simple past for what you did or
what happened, and simple future for what comes next. Avoid the present perfect ("has been
updated") and the "-ing" tail that restates the sentence ("..., making it easy to review"). Split
the tail into its own sentence or delete it.

**Verbs, not noun phrases.** "Compress the file", not "perform compression of the file".

**One word, one meaning.** Once you name a thing, keep the name. If the code says `profile`, the
prose says "profile" and not "mode" or "persona" in the next paragraph. Do the same for verbs. Pick
one of check, verify, confirm or validate for one action and keep it. A reader who sees two words
assumes two things.

**Noun clusters.** Three words or fewer. Break a longer stack with "of", "for", "in" or "on": "the
timeout value for the connection pool", not "the connection pool timeout configuration value".
A technical name that exists in the code stays whole and counts as one word.

**Warnings.** Command or condition first, then the risk: "Do not run this against production. The
command deletes rows." Never bury the risk in a trailing clause.

**Vertical lists.** Use one for three or more parallel items or steps. End the lead-in with a
colon, start each item in uppercase, and keep instructions and facts in separate lists.

## Modals

| You wrote | Write instead |
| :-------- | :------------ |
| should, meaning a requirement | must |
| should, meaning a recommendation | Delete it, or state it as a fact: "X is faster because Y." |
| should, in "should a failure occur" | if: "If a failure occurs" |
| may, might, could, meaning a possibility | can, or say what is known and say "unknown" for the rest |
| would, meaning a hypothetical | can, or "If X happens, Y happens." |

Exception: a courteous suggestion in a review comment or a Slack thread. "Could we rename this?"
and "What if we tried a map here?" stay. They are social moves, not specifications, and turning
them into "Rename this." brings back the tone this skill exists to remove.

## Plain verbs and swaps

This table is ours, not the standard's. It lists the words that most often make everyday writing
heavier than it needs to be. If a word carries no fact, delete it.

| Heavy | Plain |
| :---- | :---- |
| utilize, leverage | use |
| perform | do |
| in order to | to |
| prior to | before |
| ensure | make sure that (or the one verb you chose for the action) |
| facilitate | help, make possible |
| due to the fact that | because |
| in the event that | if |
| enables you to, allows you to | you can |
| is designed to, aims to | Delete it, then say what the thing does |
| as needed | Name the condition |
| e.g., i.e., etc. | for example, that is, or name the items |

Two soft preferences, not violations. Prefer "because" to "since" when you mean a cause, and prefer
"but" to "however" in a PR description or a doc. His own commit messages use "since" for a cause.

## Applying it by kind of writing

| Kind | Strictness | Notes |
| :--- | :--------- | :---- |
| Commit subject | Strict | Imperative, complete grammar, no trailing period. Keep it short enough to scan. |
| Commit body | Strict, descriptive | Open with the change and skip "This change". Say what changed and why in simple tenses. His bodies run 2 to 4 short paragraphs. |
| PR description | Strict | Summary and reason are descriptive. The test plan is procedural. Name what you did not verify. |
| Docs, README, runbook | Strictest | Classify each passage. Apply every rule above, including condition first and warnings first. |
| Report or status update | Strict, descriptive | Say what happened in simple past, what is known, and "unknown" for the rest. State the next step. |
| Code review comment | Light | Voice wins on suggestions. Keep the plain words, active voice and one word per meaning. |
| Slack and chat | Light | Short and clear. No limits to count. Keep the words plain and the terms consistent. |
| Error message | Strict, procedural | What happened in simple past, the cause if known, then the fix as an instruction. |

## Examples

These show the layer at work and stay in his register: plain, concrete, no filler. The first two are
rewrites. The third shows a case where his voice wins.

Commit body, before:

> This change has been made in order to leverage the ChatGPT app for the personal profile, making it
> possible to utilize Codex desktop, which is being deprecated in the separate cask.

After:

> The ChatGPT app installs on the personal profile only. It carries Codex desktop, and Homebrew's
> separate codex-app cask is deprecated in favor of it.

Test plan, before:

> You'll want to make sure the flake evaluates properly, and it might be worth confirming that
> shellcheck passes on the scripts that were touched.

After:

> 1. Run `nix flake check`. If it fails, read the first error.
> 2. Run `shellcheck` on each script that the PR changes.

Review comment, where the voice wins over a strict imperative:

> Strict: Rename `mode` to `profile`. Use the same term as `profiles.nix`.
>
> His voice: What if we named this `profile`? It matches the term in `profiles.nix`, so a reader
> sees one word for one thing.

Both versions keep one word per meaning. Only the second asks the reader to join in, which is how
he talks to colleagues.

## Mistakes to avoid when applying the layer

- **Stripping the person out.** The limits apply to facts and instructions. They do not delete his
  warmth, his collaborative framing or his dry detail. A draft that reads like a form has gone too far.
- **Telegraph style.** Dropping articles and "that" to hit a word count breaks the layer's own
  rule on complete grammar.
- **Mechanical swaps.** Replacing every "check" with "make sure that" turns a short sentence into a
  stiff one. Pick one verb for the action and keep it.
- **Counting instead of reading.** A sentence of 19 words that a reader cannot parse still fails.
  The limits are a floor for clarity, so read the sentence aloud as well as counting it.
- **Applying it where it does not fit.** Marketing copy, a blog post and an opinion piece have their
  own skill. Use `write-blog-post` for those.
