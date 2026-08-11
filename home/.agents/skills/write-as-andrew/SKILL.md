---
name: write-as-andrew
description: Write blog posts and other prose in Andrew Smith's own voice, derived from his published pre-2026 articles. Use when drafting or revising anything that will be published under his name, so the result reads as his writing rather than as AI output.
disable-model-invocation: false
---

# Write as Andrew

Produce prose that Andrew would recognize as his own. Every rule below was measured against the
seven articles he published on andrew.codes before 2026. The measurements and the passages they
come from are in `references/corpus-evidence.md`; read it when a rule here seems arbitrary or when
you want to challenge one.

**The one deviation from the corpus: never reproduce his errors.** The corpus contains misspellings
(`Detetermine`, `messsage`, `Assitant`, `Racycast`, `audomate`, `langugage`), a dropped word
(`I do not wan to enforce`), a missing verb (`There, of course, some edge cases`), a garbled clause
(`the general workflow of they interact with one another`), a misplaced possessive (`a teams'
historical data`), and a duplicated paragraph. Match the voice, never the typos. Where a habit of
his is itself a grammatical error, the rule below tells you which part to keep and which to fix.

## Sentence rhythm

Median sentence is 15 words; the mean is 15.2 with a standard deviation of 7.1. Three quarters of
his sentences land between 9 and 24 words. Sentences of 35 words or more are essentially absent:
3 out of 214.

Aim for that band, then break it deliberately. About one sentence in six is 8 words or fewer, and
those short ones do the emphatic work. Two rhythms recur:

- A staccato question-and-answer run: "How much longer? Noticeable. Too long? Up for debate."
- Consecutive short declaratives to close a thought: "Do not be afraid to fail. Failure is an
  opportunity to improve. Embrace failures as learning experiences."

Do not write a paragraph of uniformly medium sentences. The variance is the voice.

## The appended-tail construction, and how to punctuate it

This is his most distinctive sentence shape and the place where his habit and correct grammar
diverge. He writes a main clause, then appends a qualifying tail: a participial phrase, a
prepositional phrase, an example set, or a relative clause. Thirteen of the sixteen semicolons in
the corpus attach such a tail, where standard usage calls for a comma or a colon.

Keep the two-beat shape. Fix the punctuation:

| His habit | Write instead |
| :-------- | :------------ |
| `...as a device tracker; ignoring any guest devices that are already registered.` | `...as a device tracker, ignoring any guest devices that are already registered.` |
| `...a lot of scenarios; such as, turn off all the lights...` | `...a lot of scenarios, such as turning off all the lights...` |
| `No other data is needed; start dates, story points or sizings, etc. are not required.` | `No other data is needed: start dates, story points or sizings, and the like are not required.` |
| `...math involved to make these calculations; which can be cumbersome to do by hand.` | `...math involved to make these calculations, which can be cumbersome to do by hand.` |

Use a semicolon only where he uses one correctly, joining two independent clauses that belong in
one breath: "Writing software is hard; writing software that provides continual value to end-users
is even more challenging." "Mastery is not static; it is a continual work in progress."

## Punctuation habits

**Never use an em dash or an en dash.** One em dash appears in his own prose across 3,944 words, in
a single 2014 sentence. Every other em dash in the repository sits inside quoted third-party text.
When you want an aside, use commas. This also matches his standing instruction to agents.

**Colons carry lists and elaborations**, about 5 per 1,000 words. A colon after a bolded label is
his standard list-item form: `**Small**: Work that looks like all other "normal" work.`

**Parentheses are rare, short, and factual.** Eight true parentheticals in the whole corpus:
`(at home)`, `(like 68 degrees cold)`, `(e.g., effort, complexity, time)`, `(CDF)`,
`(IE, PhantomJS, Chrome, etc.)`. They gloss a term or expand an abbreviation. They never hold a
joke or a second voice.

**Question marks are frequent**, about 5 per 1,000 words, and they carry argument. He poses the
objection a reader is already forming, then answers it directly: "The simple answer is it doesn't
matter because it is a mocked dependency!"

**Exclamation points are rare but real**, five in the corpus, reserved for a genuine beat of
surprise or delight: "there is a catch!", "Enjoy!"

**No emoji.** Zero in the corpus.

## Contractions

Expanded forms outnumber verbal contractions roughly three to one. He writes "do not", "is not",
"it is", "I have", "cannot", "are not". **He never writes "it's"**: zero occurrences against eight
of "it is".

The contractions he does use cluster on first person and on brisk imperatives: `I've` (4),
`don't` (4), `I'll` (2), `I'd`, `here's`, `doesn't`, `isn't`, `there's`. So: default to the
expanded form, and let a contraction through when the sentence is about what he did ("I've written
a desktop GUI tool") or is telling the reader to do something ("Don't forget to include a karma
plugin for your browser").

## Person

Three registers, each with a job:

- **"I" and "my"** (49 and 18 uses) for what he did, chose, and concluded. This is the anchor.
  "In my experience", "I was skeptical", "I am ok sacrificing a little bit of test runner speed."
- **"we" and "us"** (25 and 9) for the problem practitioners share. Heaviest in the agility posts:
  "We cannot compare two tasks without knowing their relative cost."
- **"you" and "your"** (20 and 19) for direct instruction to the reader.

Never use "one" as an impersonal pronoun. Address the reader as "you", not as "the reader".

## Structure

**Headings.** Forty-four across the corpus: 27 H2, 15 H3, 2 H4, and no H1, because the front-matter
title is the H1. Mean heading length is 3 words. Most are Title Case. Bare structural nouns are
normal: `Overview`, `Problem`, `Solution`, `Explanation`.

Five of the 44 are questions, used when a section answers an obvious one: `Why Do We Estimate?`,
`What Data is Required to Forecast?`, `How Does it Work?`.

**Opening.** Five of seven posts open with `## Overview`. Three of seven close with
`## Final Thoughts`.

The first sentence states the situation plainly. There is no hook, no industry claim, and no
question. Three observed openings:

- The concrete setup: "When developing front-end applications, my TDD tool belt consists of karma,
  mocha, sinon, and chai."
- The definition: "Software craftsmanship is a movement in the development community that
  emphasizes the quality and skill of individual developers."
- The state of play plus the promise: "Estimating is a common practice in Agile software
  development... In this post, I'll discuss the purpose of estimation and a more effective way to
  forecast project timelines."

**Closing.** The ending adds something rather than restating. Four patterns, all observed:

- Concede the drawback he accepts: "However, there was one noticeable drawback: it is a little slow
  to run your tests... I am ok sacrificing a little bit of test runner speed."
- Name the gap he did not cover, and point at the follow-up: "There is one gap in this article that
  I have not addressed."
- Point at the tool and invite contribution: "I hope to implement the first question in the future
  and welcome any pull requests to help with this."
- Close on short imperatives: "Do not be afraid to fail. Failure is an opportunity to improve."

**Paragraphs.** Mean 3.5 sentences, median 3, and deliberately uneven: of 63 paragraphs, 7 are a
single sentence, 27 run two to three, and 29 run four or more. One idea per paragraph. Do not
normalize them to a uniform length.

**Blockquotes** do two jobs and nothing else:

1. The pull-out takeaway, one distilled sentence placed *after* the prose that earns it, never
   before, at most one per section: "> Estimation is a poor planning tool and this is not its
   primary purpose."
2. The operational note or cross-link: "> Note: My primary development machine runs on macOS.",
   "> Assumes you have `jq` installed from the above list.", "> See [Agile
   Forecasting](/posts/agile-forecasting) for more information on forecasting project timelines."

**Bold** has exactly two uses: the label opening a list item, and a single contrasted word inside a
sentence (`**in isolation**`, `**collaboration**`, `**and**`). Never bold a whole sentence.

**Tables** carry side-by-side comparisons and reference lists. Left-align with `:---`.

**Numbered lists** are for real sequences and for reasons he then discusses in order. **Bulleted
lists** are for parallel items with no order.

**Cross-link related posts early**, and name a follow-up explicitly when one is planned.

## Introducing code and examples

Name what the code is and where its inputs come from in one plain sentence, then show it. He does
not announce the code ("let's take a look at the example below") and does not walk through it
afterward restating what it does.

> Below is the python automation I used via AppDaemon. Values, such as the group name, mqtt
> connection details, and MQTT topic, of the script are pulled from the application's configuration
> in AppDaemon.

Comparisons are shown as two parallel numbered lists, not narrated. See the Mocha Experience and
Jest Experience sections in the Jest post.

## Assertion, hedging, and honesty

Assert flatly, then bound the claim with a named limit. He does not soften a claim; he tells you
where its evidence stops.

- "Estimation is a poor planning tool and this is not its primary purpose." Then: "I can support
  this claim with empirical evidence, though I cannot release the data at this time."
- "In my experience, timelines or scope are often adjusted to meet deadlines."

Challenge received wisdom when his experience contradicts it, and say so directly: "Instead, I
suggest skipping story points."

Give the honest, non-technical reason when there is one. Concede real drawbacks; a post that
concedes nothing reads as marketing.

Never write "it might be possible that perhaps", and never claim exhaustive coverage of a topic he
treated narrowly.

## Humor and asides

Dry, infrequent, and always attached to a concrete detail. "adjust the thermostat to be cold (like
68 degrees cold)". "Auto-magically finds and runs all your tests". "This is simply a deal-breaker
for me."

No jokes for their own sake, no self-deprecating filler, no winking at the reader.

## Vocabulary

**His words:** work, software, estimation, forecast, throughput, relative size, trade-offs,
prioritization, craftsmanship, agility, automation, presence detection, edge-case, deal-breaker,
tool belt, workbench, empirical, cumbersome, arduous.

**Words absent from all 4,175 prose words of the corpus.** Do not introduce them:

delve, dive into, deep dive, tapestry, landscape, realm, testament, seamless, seamlessly,
effortlessly, robust, unlock, empower, elevate, supercharge, game-changing, revolutionary,
cutting-edge, navigate the, foster a, myriad, plethora, holistic, synergy, paradigm, best-in-class,
in today's, in the world of, when it comes to, at the end of the day, that said, moreover,
furthermore, in conclusion, to summarize, in summary, the bottom line, key takeaway, vital,
paramount, truly, incredibly, absolutely, essentially, fundamentally, feel free to, don't hesitate,
it's worth noting, it's important to note.

**"However" is his one workhorse connective** (9 uses). "Additionally" appears twice, "therefore"
and "significantly" once each. Beyond those, he connects sentences by their content rather than by
a signposting adverb.

## Anti-tells

These are the habits that mark AI prose. Each is listed because the corpus does not do it.

- **Stock transitions.** Zero uses of "moreover", "furthermore", "in conclusion", "that said". Nine
  of "however". If a paragraph opens with a transition adverb, delete it and check whether the
  sentence still connects. It usually does.
- **Tricolon padding.** He uses twelve "X, Y, and Z" constructions, and every one enumerates
  concrete things: "mocha, sinon, and chai", "small, large, and too large", "people, time, and
  money". None is a rhetorical triple of abstractions. Never write a three-part list for cadence.
- **"It's not just X, it's Y."** Zero occurrences of this frame or its variants. He states the
  claim once.
- **Over-signposting.** He never writes "In this section we will explore" or "Let's dive in". The
  heading already says what the section is. The only forward reference he makes is a concrete one:
  "which I will discuss in a future post".
- **Uniform paragraph length.** His paragraphs run 1 to 6+ sentences with no pattern. Blocks of
  even three-sentence paragraphs read as generated.
- **Hollow summary paragraphs.** No post ends by restating itself. A closing section that could be
  deleted without losing information must be deleted.
- **Balanced both-sides hedging.** He picks a side. "Jest wins" is the title.
- **Bolded sentences and emoji as emphasis.** Neither appears.
- **The em dash.** Covered above, and worth repeating: it is the single loudest tell in his case,
  because his own rate is one per 3,944 words.

## Self-check before returning a draft

Run every item. Fix what fails, then report the numbers for items 1 through 4 alongside the draft.

1. **Em dashes and en dashes:** count must be 0.
2. **"it's":** count must be 0. Expand to "it is".
3. **Semicolons:** for each one, confirm both sides are independent clauses. If the right side is a
   phrase, replace with a comma or a colon.
4. **Sentence length:** median between 12 and 18 words. At most one sentence over 35 words, and
   none over 40. Short sentences of 8 words or fewer should run about 1 in 6 for an argument or
   opinion piece, and no lower than about 1 in 15 for a dense technical walkthrough. These bounds
   are the range his own five prose posts actually occupy, not an ideal.
5. **Banned vocabulary:** search the draft for the absent-words list above. Zero hits.
6. **Transitions:** zero paragraphs open with "Moreover", "Furthermore", or "In conclusion". At
   most one opens with "Additionally", which he does once in the 2024 post.
7. **Paragraph variance:** paragraph lengths are not all within one sentence of each other.
8. **Opening:** first sentence states a concrete situation, definition, or state of play. It is not
   a question, a hook, or a claim about the industry.
9. **Closing:** the final section adds a concession, a named gap, a pointer forward, or an
   imperative. It does not summarize the post.
10. **Blockquotes:** each follows the prose it distills, and there is at most one per section.
11. **Structure:** headings start at H2, average around 3 words, and no H1 is present.
12. **Spelling and grammar:** clean. This is the one place the draft must be better than the
    corpus.
13. **Read the opening and closing paragraph aloud.** If either sounds like it introduces or
    concludes an essay rather than telling you something, rewrite it.
