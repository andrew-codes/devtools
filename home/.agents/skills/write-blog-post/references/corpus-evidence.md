# Corpus evidence for `write-as-andrew`

This records what was read and what was measured, so a future maintainer can re-derive or challenge
any rule in `SKILL.md` rather than trusting it.

## Corpus

Every article published on <https://andrew.codes/posts> dated before 2026. Source form lives in the
blog repository under `app/posts/<year>/<slug>/`. Posts dated 2026 or later are **excluded on
purpose**: they may be AI-assisted, and including them would contaminate the voice model.

| Post | Date | Prose words | Category |
| :--- | :--- | ---: | :--- |
| `2014/software-craftsmanship.mdx` | 2014-07-08 | 556 | engineering |
| `2014/jest-vs-mocha-why-jest-wins.mdx` | 2014-09-10 | 747 | engineering |
| `2015/react-with-relay-graphql-talk/` | 2015-07-22 | 18 | presentation |
| `2020/guest-presence-detection/` | 2020-11-13 | 981 | home automation |
| `2023/devtools/` ("My Developer Workbench") | 2023-05-19 | 78 | engineering |
| `2023/agile-estimation/` | 2023-11-14 | 857 | agility |
| `2024/agile-forecasting/` | 2024-09-18 | 707 | agility |

Totals: 7 posts, 3,944 prose words with tables and code excluded (4,175 counting list items),
214 prose sentences, 63 prose paragraphs, 44 headings.

Two caveats on weighting. The 2015 presentation post is 3 sentences and the 2023 devtools post is
mostly reference tables, so both contribute structure but almost no prose rhythm. The prose
measurements are therefore driven by the other five posts.

Completeness was checked against the repository rather than the live site, which returned HTTP 403.
Front-matter dates across all post sources yield exactly these seven pre-2026 entries plus two from
2026. Repository history contains one deleted post file, `app/posts/2020/devtools.mdx`, a superseded
earlier version of the 2023 devtools post; it is unpublished and was not used.

Excluded from 2026, and deliberately unread for voice purposes: `devtools-revisited` (2026-04-07)
and `voice-assistant` (2026-04-22).

## Sentence length

Measured over running prose only: headings, tables, code fences, list items, and blockquotes
removed; markdown links reduced to their text.

| Metric | Value |
| :--- | ---: |
| Sentences | 214 |
| Mean | 15.2 words |
| Median | 15 words |
| Population standard deviation | 7.1 |

| Band | Count | Share |
| :--- | ---: | ---: |
| 1-8 words | 36 | 16.8% |
| 9-15 words | 80 | 37.4% |
| 16-24 words | 77 | 36.0% |
| 25-34 words | 18 | 8.4% |
| 35+ words | 3 | 1.4% |

Per post, mean sentence length ranges from 13.3 (agile-estimation) to 18.2 (guest-presence
detection). The 2020 post is his most technical and his longest-sentenced; the 2023 agility post is
his tightest.

## Paragraph length

63 prose paragraphs. Mean 3.5 sentences, median 3. Distribution: 7 one-sentence paragraphs, 27 of
two to three, 29 of four or more. Per-post sequences show no regular pattern, for example
agile-forecasting runs `[3, 1, 4, 3, 4, 7, 4, 5, 4, 8]`.

## Punctuation, per 1,000 prose words

| Mark | Count | Rate |
| :--- | ---: | ---: |
| Em dash `—` | 1 | 0.3 |
| En dash `–` | 0 | 0.0 |
| Semicolon `;` | 16 | 4.1 |
| Colon `:` | 21 | 5.3 |
| Question mark `?` | 19 | 4.8 |
| Exclamation `!` | 5 | 1.3 |
| True parenthetical | 8 | 2.0 |
| Emoji | 0 | 0.0 |

**Em dash.** The single occurrence in his own prose is in the 2014 Jest post: "changing interactions
with collaborators is quicker—no need for the unnecessary setup of a fake." The only other em dashes
in the repository are inside quoted marketplace copy for the GitLens extension, which is not his
writing. This independently confirms the standing instruction never to use em dashes.

**Parentheses.** The raw `(` count is 29, but 21 of those are markdown link syntax or table content.
The 8 genuine parentheticals are: `(LINK, LINK, LINK, and LINK)`, `(IE, PhantomJS, Chrome, etc.)`,
`(LINK)`, a bare YouTube URL, `(like 68 degrees cold)`, `(at home)`, `(e.g., effort, complexity,
time)`, `(CDF)`.

## Semicolons: the habit and the error

All 16 occurrences were classified. Three are standard, joining independent clauses:

- "Writing software is hard; writing software that provides continual value to end-users is even more challenging." (2014 craftsmanship)
- "mastery is not static; it is a continual work in progress" (2014 craftsmanship)
- "I give them a temporary digital key for the locks; however, the security system may arm when a guest is still home" (2020)

The remaining 13 attach a dependent tail where a comma or colon is correct:

- "Auto-magically finds and runs all your tests; no registration required" (2014 Jest)
- "Presentation given to Developers of Athens; exploring React, Relay and GraphQL" (2015)
- "LTE Bluetooth fobs; all having their own set of pros and cons" (2020, appears twice)
- "This is useful in a lot of scenarios; such as, turn off all the lights" (2020)
- "connecting their laptop to the guest wifi; a device that may or may not leave with them" (2020)
- "a simple node express app; with an index route serving a page" (2020)
- "adds it to a 'Guests' group as a device tracker; ignoring any guest devices that are already registered" (2020)
- "two instances of the automation; one for phones and one for all other devices" (2020)
- "When will the work be done; i.e., what is the delivery date?" (2024)
- "answer these questions dynamically; including as the project progresses" (2024)
- "No other data is needed; start dates, story points or sizings, etc. are not required" (2024)
- "statistics and math involved to make these calculations; which can be cumbersome to do by hand" (2024)

The habit spans 2014 to 2024, so it is stable rather than a phase. The **rhythm** it produces, a
main clause followed by an appended qualifier, is therefore treated as voice and preserved. The
**punctuation** is treated as an error under the no-typos exception and corrected to a comma or
colon.

## Contractions

Thirty apostrophe forms appear, but 15 are possessives (`software's`, `member's`, `phone's`,
`guest's`, `package's`, `developer's`, `device's`, `Ubiquiti's`, `application's`, `work's`,
`Jest's`, and so on). Only 15 are verbal contractions: `don't` (4), `I've` (4), `I'll` (2),
`here's`, `doesn't`, `isn't`, `there's`, `I'd`.

Expanded forms total 47: `is not` (9), `it is` (8), `I have` (7), `does not` (4), `cannot` (4),
`I am` (4), `do not` (3), `are not` (3), `I will` (3), `was not`, `will not`.

The decisive data point is `it's`: **zero occurrences**, against eight of `it is`.

## Person

`I` 49, `my` 18, `me` 4, `we` 25, `us` 9, `our` 6, `you` 20, `your` 19. No impersonal use of "one".

One outlier worth knowing about: "I encourage readers to review their own historical data"
(agile-estimation) is the single instance of "readers" rather than direct address. It is an
exception, not the pattern.

## Headings

44 total: 27 H2, 15 H3, 2 H4, 0 H1. Mean length 3.0 words. 32 of 44 are Title Case. 5 of 44 end in
a question mark.

`## Overview` opens 5 of the 7 posts. `## Final Thoughts` closes 3 of 7. Question headings observed:
"What is Software Craftsmanship?", "To Mock, or Not To Mock? Shouldn't be a Question",
"What about...?", "Why Do We Estimate?", "What Data is Required to Forecast?", "How Does it Work?".

## Blockquotes

19 blockquote lines. Two functions, both listed in `SKILL.md`. The agile-estimation post is the
densest user with 6 pull-out takeaways, each placed after the prose that earns it. Examples:
"Estimation is a poor planning tool and this is not its primary purpose.", "Only the completion data
of each story is required to forecast project timelines.", "Note: My primary development machine
runs on macOS."

## Bold

11 instances, all one of two forms: the label opening a list item (`**Small**:`, `**Just enough
accuracy**:`) or a single contrasted word inside a sentence (`**in isolation**`, `**collaboration**`,
`**and**`, `**AND**`). No bolded sentences.

## Vocabulary absence check

The following were searched across all 4,175 prose words. Zero hits: delve, dive into, deep dive,
tapestry, landscape, realm, testament, seamless, seamlessly, effortlessly, robust, unlock, empower,
elevate, supercharge, game-changing, revolutionary, cutting-edge, navigate the, myriad, plethora,
holistic, synergy, paradigm, best-in-class, in today's, in the world of, when it comes to, at the
end of the day, that said, moreover, furthermore, in conclusion, to summarize, in summary, the
bottom line, key takeaway, vital, paramount, truly, incredibly, absolutely, essentially,
fundamentally, feel free to, don't hesitate, it's worth noting, it's important to note, "it's not
just", emoji.

Present but rare: however (9), additionally (2), leverage (1), utilize (1), crucial (1), foster (1),
significantly (1), therefore (1), "not only" (1), "but also" (1).

Most frequent content words: work (33), software (21), home (19), estimation (17), guest (16),
time (15), project (14), code (13), data (13), forecast (12), story (12), craftsmanship (11),
automation (11), estimating (11).

## Tricolons

Twelve "X, Y, and Z" constructions, all enumerating concrete things: "mocha, sinon, and chai";
"landscaping, interior design, and many other disciplines"; "turn off all the lights, lock the
doors, and arm your home security"; "people, time, and money"; "small, large, and too large"; "the
unit of measurement, the scale, and what the value represents". None is a rhetorical triple of
abstractions. This is why `SKILL.md` bans tricolon *padding* rather than tricolons.

## Errors found in the corpus, and not to be reproduced

| Location | Text | Correction |
| :--- | :--- | :--- |
| 2020 front matter | `Detetermine` | Determine |
| 2020 line 60 | `I do not wan to enforce` | want to |
| 2020 line 88 | `messsage` | message |
| 2020 line 152 | `Home Assitant` | Home Assistant |
| 2020 line 169 | `guest_tracker_other_devies` | devices |
| 2020 line 65 | `There, of course, some edge cases` | There are, of course |
| 2020 line 70 | `the general workflow of they interact with one another` | of how they interact |
| 2020 lines 20-25 / 56-61 | paragraph duplicated verbatim | remove one |
| 2020 line 29 | `such as, turn off` | such as turning off |
| 2023 devtools | `Racycast`, `audomate`, `langugage` | Raycast, automate, language |
| 2024 line 30 | `a teams' historical data` | a team's |

## Self-check calibration

The numeric thresholds in the `SKILL.md` self-check were run back against the five prose-carrying
posts, on the principle that a check Andrew's own writing fails is a bad check. The 2015
presentation and the 2023 devtools post were excluded as too short and too table-heavy to measure.

| Post | Em dash | `it's` | Median sentence | Sentences >35w | Opens with a transition |
| :--- | ---: | ---: | ---: | ---: | ---: |
| 2014 jest-vs-mocha | 1 | 0 | 16 | 1 | 0 |
| 2014 software-craftsmanship | 0 | 0 | 13 | 1 | 0 |
| 2020 guest-presence-detection | 0 | 0 | 18 | 1 | 0 |
| 2023 agile-estimation | 0 | 0 | 13 | 0 | 0 |
| 2024 agile-forecasting | 0 | 0 | 15 | 0 | 1 |

All five pass the banned-vocabulary check with zero hits, and all five show uneven paragraph
lengths.

Three thresholds were loosened as a result, because the first drafts of them were stricter than the
corpus:

- **Long sentences.** "No sentence over 35 words" would have failed three of five posts. The corpus
  maximum is 39 words, and 35+ sentences are 3 of 214. The rule became at most one over 35 and none
  over 40.
- **Transition-opened paragraphs.** "None" would have failed the 2024 post, which opens a paragraph
  with "Additionally". The rule became zero for "Moreover", "Furthermore", and "In conclusion",
  which genuinely never appear, and at most one "Additionally".
- **Short-sentence rate.** A flat "one short sentence per three paragraphs" would have failed the
  2020 post, which is his densest technical writing at 6% short sentences against 29% in the 2014
  Jest post. The rule became mode-aware.

The 2014 Jest post fails the em dash check with its single occurrence. That is the intended
behavior: the no-typos exception means the skill is stricter than the corpus on this one mark, and
the rule stays at zero.

## How to re-derive

The measurements above came from reading all seven posts in full and from four throwaway analysis
scripts over the `.mdx` sources: sentence-length distribution, punctuation and contraction counts,
structural counts for headings, blockquotes, and paragraphs, and an absence check for a list of
known AI-tell phrases. Nothing here depends on tooling that needs to be kept; re-running equivalent
counts over the sources reproduces every number.

When new pre-2026-style writing is published, re-measure rather than appending impressions. If a
rule in `SKILL.md` no longer matches the corpus, change the rule.
