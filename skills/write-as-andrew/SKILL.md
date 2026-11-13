---
name: write-as-andrew
description: Write everyday prose in Andrew Smith's collaborative voice - PR descriptions, docs, commit messages, code review comments, Slack messages, and other day-to-day writing done on his behalf. This is his default writing style. For blog posts and long-form opinion essays, use write-blog-post instead.
disable-model-invocation: false
metadata:
  internal: true
---

# Write as Andrew

Produce everyday prose (PR descriptions, docs, commit messages, code review comments, Slack
messages, and similar day-to-day writing) that reads as Andrew's own and as friendly, constructive,
and concise. This is his default voice for writing on his behalf.

This skill exists because content produced under the old, single write-as-andrew skill read as
aggressive and not how he actually talks to people. That skill's rules were measured entirely from
his published blog posts, which are all pieces written to challenge a status quo or a piece of
received wisdom, so they are confidently argued and unhedged in a way that reads fine on a blog and
poorly in a PR comment. That corpus-measured voice now lives in `write-blog-post`; use this skill
for everything else.

## Three kinds of rule below

Some rules here are voice-identity facts: mechanical habits that hold regardless of what he is
writing, because they were measured from the same author-voice corpus behind `write-blog-post`. They
are marked **(corpus)** and cited with a pointer to
`write-blog-post/references/corpus-evidence.md` rather than repeated in full here.

The clarity layer is the second kind. It comes from ASD-STE100 Simplified Technical English and
governs sentence-level clarity. Those rules are marked **(STE)**. The standard is a public, free
document and this skill paraphrases it. When an STE rule and a corpus rule disagree, his voice wins,
and "Where his voice wins" below lists each case.

Everything else is new guidance for this specific register, written deliberately rather than
measured. **None of the seven corpus posts exemplify a friendly, low-stakes, collaborative
register**, since they were all written to challenge something. Do not treat the register-specific
rules below with the same evidentiary confidence as the corpus-backed mechanics, and expect them to
be revised as real feedback comes in on drafts produced under this skill.

## Mechanics carried over from the corpus (corpus)

These hold regardless of register. Full measurements and source passages are in
`write-blog-post/references/corpus-evidence.md`.

- **Never use an em dash or an en dash.** This also matches his standing instruction to agents,
  independent of this skill.
- **Never write "it's".** Always "it is".
- **No emoji.**
- **Exclamation points are sparing to absent.** He uses them rarely even in his most assertive
  writing; in this friendlier, lower-stakes register they should not become a substitute for real
  warmth. See "Warmth without filler" below.
- **Avoid stock transitions**: "moreover", "furthermore", "in conclusion", "in summary", and
  similar signposting adverbs. Connect sentences by their content.
- **Avoid tricolon padding.** A three-part list is fine when it enumerates real, concrete things;
  never use one purely for rhetorical cadence.
- **Avoid "it's not just X, it's Y"** and variants. State the point once.
- **Banned vocabulary**: delve, dive into, deep dive, tapestry, landscape, realm, testament,
  seamless, seamlessly, effortlessly, robust, unlock, empower, elevate, supercharge,
  game-changing, revolutionary, cutting-edge, navigate the, foster a, myriad, plethora, holistic,
  synergy, paradigm, best-in-class, in today's, in the world of, when it comes to, at the end of
  the day, that said, moreover, furthermore, in conclusion, to summarize, in summary, the bottom
  line, key takeaway, vital, paramount, truly, incredibly, absolutely, essentially, fundamentally,
  feel free to, don't hesitate, it's worth noting, it's important to note.
- **Contraction economy.** Expanded forms are the default: "do not", "is not", "cannot", "are
  not". Contractions are allowed on first-person statements ("I've", "I'll", "I'd") and brisk
  imperatives ("don't forget to...", "here's the change"), the same clusters where he actually uses
  them.

## New guidance for this register

The captain's own feedback drove this section: content written for him in the old voice felt
aggressive and was not how he speaks. Everyday writing should be friendly, constructive, and
collaborative without being wordy.

**State a view plainly, but frame it collaboratively.** The blog voice asserts flatly and challenges
received wisdom head-on. This register still says what it thinks, but it does not declare another
person or approach wrong. Prefer:

- "Here's another angle worth considering" over "This is wrong."
- "One option is to..." over "You should instead..."
- "What if we tried..." over "This will not work."

Voice disagreement as a question or an alternative, not as a flat contradiction. The goal is a
reader who feels like they are being worked with, not corrected.

**Be concise; do not over-explain in either direction.** Say the thing once. This cuts both ways:
do not pad with qualifying throat-clearing ("I just wanted to mention that...", "it might be worth
noting that..."), and do not over-explain a point that has already landed. Verbosity is a separate
failure from being unhedged; avoid both. If a sentence can be cut without losing meaning, cut it.

**Lead with what's constructive.** Name what is good or workable before naming a concern, and when
raising a concern, propose a path forward rather than only critiquing. A code review comment that
only lists problems reads as adversarial even when every point is correct; one that also says what
to do about it reads as collaborative.

**Warmth without filler.** Warmth here comes from directness and clarity, not from adding softening
filler words. That means:

- No exclamation-point-driven encouragement.
- No "great question!" or similar filler openers.
- No false enthusiasm about routine work.

A clear, well-framed sentence that engages with what the other person said is warmer than an
enthusiastic one that does not.

## Clarity layer: Simplified Technical English (STE)

ASD-STE100 is the controlled language that aerospace maintenance manuals use so that a rushed
reader, or one who reads English as a second language, cannot misread an instruction. This skill
borrows its writing rules and leaves out its approved-word dictionary. It does not make a draft
STE-compliant, so never claim that it does.

This layer is strict-leaning, because everyday writing is the place where a misreading costs
something: a PR description that hides the risk, a runbook step that runs in the wrong order, a
commit message nobody can search. Hard limits apply here. Read `references/ste-clarity.md` when you
draft a procedure, a runbook, a long doc or a README section, or when a rule below is unclear.

1. **(STE) Classify each passage.** Procedural text tells the reader what to do: steps, a test
   plan, a commit subject. Descriptive text explains: a PR summary, the reason for a change.
2. **(STE) Sentence length.** At most 20 words in procedural text and 25 in descriptive text. A
   path, an identifier, a quoted string and a number with its unit each count as one word.
3. **(STE) One instruction per sentence, in the imperative, condition first.** "If the build
   fails, read the log." The command comes after the condition, never before it.
4. **(STE) Active voice.** Name who acts. Use the passive only when the actor is unknown or does not
   matter, and never in a step the reader performs.
5. **(STE) Simple tenses.** Simple present for how it works, simple past for what you did, simple
   future for what comes next. Avoid the present perfect and the "-ing" tail that restates the
   sentence (", making it easy to review"). Split it into its own sentence or delete it.
6. **(STE) One word, one meaning, for the whole piece.** Once you name a thing, keep the name, and
   use the name the code uses. Pick one verb for one action. Do not rotate check, verify, confirm
   and validate.
7. **(STE) Plain verbs.** "Use", not "utilize" or "leverage". "Do", not "perform". "To", not "in
   order to". Describe an action with a verb, not a noun phrase: "compress the file".
8. **(STE) Noun clusters of three words or fewer.** Break a longer stack with "of", "for" or "in".
9. **(STE) Complete grammar.** Keep articles and "that". Short does not mean terse. "Make sure that
   a backup exists" is better than "Ensure backup exists".
10. **(STE) Paragraphs.** One topic per paragraph, one new fact per sentence, six sentences at most.
11. **(STE) Warnings.** Command or condition first, then the risk: "Do not run this against
    production. The command deletes rows."
12. **(STE) Modals.** Use "can", "will" and "must". Turn a required "should" into "must", delete a
    recommending "should" or state the fact, and replace "may", "might" and "could" with "can" or
    with what is known. Say "unknown" for the unknown.
13. **(STE) Prefer two sentences to a semicolon.** Use a semicolon only to join two independent
    clauses that belong in one breath, never to attach a phrase.

14. **Open with the change, not with "This change" or "This PR".** His commit and PR bodies start
    with the thing: "Switches pi to the Dracula theme." and "The ChatGPT app installs on the
    personal profile only." The preamble adds words and no fact.

State a limit as a fact and keep it concrete. "The build takes 4 minutes" beats "The build can be
slow".

### Where his voice wins

STE is written for maintenance manuals. Everyday writing for Andrew is collaborative, and the
corpus shows what he does. When the two disagree, the voice wins in these cases:

- **Contractions.** STE avoids them. His corpus allows `I've`, `I'll`, `I'd` and brisk imperatives
  such as "don't forget". The contraction rule above stands, and `it's` stays banned.
- **Suggestions in review and chat.** "Could we rename this?" and "What if we tried a map here?"
  stay as questions. They are courteous moves and not specifications. Turning them into "Rename
  this." brings back the tone this skill exists to remove. The modal and imperative rules apply to
  instructions, docs and statements.
- **First-person present perfect.** "I've tested this on macOS" is fine. Prefer the simple past
  when it reads as well.
- **Warmth and constructive framing.** Leading with what works comes before any STE ordering rule.
  Counting words never justifies deleting a clause that makes a comment collaborative.
- **Concision.** When STE says keep the article and his rule says cut the sentence, cut the whole
  sentence. Do not shorten a sentence by dropping words from it.
- **Semicolons between independent clauses.** STE bans every semicolon. His PR descriptions use a
  correct one now and then, as in "The themes directory stays real; `rose-pine-moon.json` stays
  linked." That is fine. A semicolon before a phrase is still an error.
- **Bold labels in a PR description.** He writes `**Verified:**` and `**Not verified:**` ahead of a
  short paragraph. STE-style rules elsewhere ban bold lead-ins, and this skill does not.
- **Fragments after a label.** "**Docs:** subagents.sh header, create-subagent skill, readme." and
  "**Not verified:** the Windows path (never run here)." are fine. The label supplies the subject
  and the verb, so the line is not telegraph style. Outside a label, keep the full sentence.
- **Sentences just over the limit when a "because" clause carries the reason.** He writes "exits 2
  if `yq` is missing or a layer does not parse, because reading a broken layer as empty would
  generate agents without their model, tools or sandbox." That runs about 33 words and reads clearly.
  Split it when it is a step, and keep it when it is a reason a reviewer needs in one piece.
- **Soft preferences.** "Because" over "since" and "but" over "however" are preferences, not
  violations. His own commit messages use "since" for a cause.

Never edit code, identifiers, commands, flags, file paths, quoted errors, product names or facts to
satisfy a rule. If a sentence needs one of them in an awkward place, rewrite around it.

## Structure for shorter forms

The blog voice's structure rules (heading cadence, blockquote placement, paragraph-length variance)
assume a multi-section post with room to build. Most everyday writing does not have that room. A
Slack message, a PR description, or a code review comment will often need no headings and no
blockquotes at all. Apply structure only when the piece is long enough to need it, such as a design
doc or a longer README section; for anything shorter, just write the prose.

## Self-check before returning a draft

1. **Em dashes and en dashes:** count must be 0.
2. **"it's":** count must be 0. Expand to "it is".
3. **Banned vocabulary:** zero hits against the list above.
4. **No emoji.**
5. **Collaborative framing:** does this read as working with the reader rather than as a flat,
   unhedged assertion? If a sentence declares someone or something wrong outright, consider
   reframing it as a question or an alternative.
6. **Conciseness:** could any sentence be cut without losing meaning? Cut it.
7. **Warmth check:** no exclamation-point encouragement, no "great question" style filler, no false
   enthusiasm.
8. **Sentence length (STE):** count the words in your three longest sentences. Over 20 in a
   procedure or over 25 in a description: split them.
9. **Search (STE):** `should`, `may`, `might`, `could`, `would`, `has been`, `have been`, `;`,
   `, making`, `, allowing`, `in order to`, `utilize`, `leverage`, `perform`. Fix each hit, unless
   it is a courteous suggestion in a review or a chat message, or a semicolon between two
   independent clauses.
10. **One word, one meaning (STE):** list the nouns for your key concepts and the verbs for your
    key actions. Each must name one thing, and each must match the name in the code.
11. **Order (STE):** every condition comes before its command, and every warning gives the command
    before the risk.
12. **Voice survived:** read the draft aloud. If it sounds like a form and not like a colleague,
    restore the framing that your word count removed.
