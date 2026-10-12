# Judge Sim

An iPhone simulator in which you serve as a Resident Superior Court Judge in **Hollis County, North Carolina** (a fictional county). Defendants have waived a jury, so you hear the motions, rule on objections, decide guilt, and impose sentence under North Carolina's Structured Sentencing Act.

There is no score and no right answer. You make rulings, and the world responds: appeals come back months later, the local paper covers your cases, and people you sentenced, put on probation, or acquitted may appear in your courtroom again.

## A case

1. **Case file:** docket number (`27 CRS 004512`), session date, procedural posture (jury waiver under N.C. Const. art. I, § 24; habitual felon indictment; probation status; the district court judgment in a misdemeanor appeal), the defendant's record with offense classes and counties, the charges with G.S. citations, counsel, and the investigating agency.
   - Sometimes the parties present a **plea arrangement**. Taking it means a plea colloquy under G.S. 15A-1022 (rights, maximum punishment, immigration consequences, voluntariness, factual basis), and you accept a guilty, *Alford*, or no-contest plea. Arrangements may dismiss or admit habitual felon status. If you sentence more harshly than the arrangement recommends, G.S. 15A-1024 lets the defendant withdraw the plea and go to trial.
2. **Pretrial motions:** suppress evidence under G.S. 15A-974 (each fact pattern fits where the item was found: a car, a home, or a phone), suppress statements (Miranda, voluntariness), or dismiss on speedy-trial grounds.
3. **Trial:** exhibits and witnesses, with objections under the North Carolina Rules of Evidence (hearsay and its exceptions, character, 404(b), Rule 403, leading, asked and answered, Rule 612, and North Carolina's wide-open cross under Rule 611(b)). When the State rests, the defense moves to dismiss under G.S. 15A-1227, and you rule count by count. You may advise the defendant on the right to testify; if they testify, it can help or hurt. Sometimes there is also an ethics situation outside the courtroom.
4. **Verdict:** review the record, with suppressed exhibits and stricken answers marked, then decide guilty, guilty of a lesser-included offense, or not guilty, on each count.
5. **Sentencing (Structured Sentencing):**
   - Prior record points and level (I–VI felony, I–III misdemeanor), including the +1 point for offending on probation (which requires 30 days' notice), the +1 point when all elements of the offense appear in a prior, and the rule that only one conviction from a single session of court counts. You rule on priors the defense disputes.
   - Habitual felon status (sentenced four classes higher, capped at Class C), with predicate convictions excluded from points
   - Findings of aggravating and mitigating factors, which open the aggravated and mitigated ranges
   - Mitigated, presumptive, or aggravated range; a minimum term, with the statutory maximum computed automatically
   - Active, Intermediate, or Community disposition, as the chart cell allows, and the probation length
   - Consolidated judgment or separate judgments run concurrently or consecutively
   - Probation conditions: supervised or unsupervised, special probation (split sentence), electronic house arrest, Drug Treatment Court, community service, treatment, testing, curfew, no-contact, firearm surrender, employment and education
   - For active sentences: credit for time served, Advanced Supervised Release (Class D at levels I–III, E at I–IV, F at I–V, G and H at any level), and treatment, work-release, and vocational recommendations
   - Prayer for judgment continued (not allowed for Class A–E felonies under G.S. 15A-1331.2); conditional discharge under G.S. 90-96 or, on joint motion, G.S. 15A-1341(a4)
   - Fines, court costs, restitution, appointed-attorney and appointment fees, the State Crime Laboratory fee, and supervision and community service fees, with waivers
   - The sentence is yours. Nothing is locked: you can go outside the chart, set your own term, or add any order you write yourself. Departures from North Carolina law are listed before you enter judgment, and they draw appeals, resentencing, and sometimes the Judicial Standards Commission.
6. **Probation violation hearing:** if the defendant was on probation, you decide whether to revoke (concurrent with today's sentence, or consecutive), order a CRV, modify, or continue it. CRV time is credited.
7. **Judgment:** the judgment and commitment, written findings of factors (AOC-CR-605), any notice of appeal, reactions in the hallway, and tomorrow's story in the *Port Hollis Ledger*, placed on the front page when the case drew attention.

## Talking to counsel

At every stage you can call a bench conference and question the ADA or defense counsel. They answer from what they know about the case: plea negotiations, custody status, discovery problems, the strength of each exhibit and witness, sentencing recommendations, restitution, the defendant's plan, ability to pay, treatment needs, and support. Asking the right question at sentencing can surface additional aggravating or mitigating factors. Each lawyer in the county has a consistent personality.

## The county

Each career generates one Hollis County, and it stays the same throughout:

- **Fixed cast:** an elected District Attorney and their ADAs, the Chief Public Defender and assistants, private defense lawyers, the Clerk of Superior Court, the Sheriff, the Port Hollis police chief, detectives, officers, and Highway Patrol troopers. You can see all of them under **Chambers → Hollis County Courthouse**.
- **Calendar:** time moves forward between cases, and docket numbers increase in sequence.
- **People:** everyone who appears before you is kept on record. Prison sentences run out, probation ends, and people can be arrested again. Returning defendants bring their full record, including convictions from your courtroom. If they were on probation from your court, you hold a violation hearing.
- **Probation:** conditions you set affect whether a probationer succeeds. Unaddressed addiction, unaffordable fees, and stacked conditions lead to violation reports, which come back to you as probation violation hearings. The probationer admits or denies; if they deny, the probation officer testifies. You find whether a violation happened without lawful excuse, then continue, modify, quick dip, CRV (90 days for a felony, up to 90 for a misdemeanor), revoke (only for absconding, a new crime, or after two CRVs), or terminate.
- **Calendar calls:** about every fourth day is an administrative session: quick pleas that add people to the county's record, failures to appear, continuance and bond motions, capacity motions, and probation admissions.
- **Events:** appeals go to the Court of Appeals months after judgment. A new trial can bring a case back to you, with the inadmissible evidence removed, unless the District Attorney declines to retry it. Vacated convictions and exonerations come off the person's record. Releases from prison, completed probation, and Drug Treatment Court graduations make the paper.
- **Career ledger:** under Records, a neutral tally of your career: convictions, pleas, acquittals, where felony sentences fell against the presumptive range, probation outcomes, appeals, and exonerations. It isn't a score.
- **What really happened** is never shown to you directly. Sometimes it comes out later in the news.

## Law Library

The library has about 80 North Carolina offenses and more than 50 doctrine entries. Each offense shows its G.S. citation, class, elements, and the presumptive, mitigated, and aggravated minimum ranges and dispositions at every prior record level, taken from the felony and misdemeanor punishment charts. Doctrine entries cover criminal procedure, the Rules of Evidence, defenses (including *State v. Norman* and *State v. Mercer*), Structured Sentencing, habitual felon status, probation violations, and the Code of Judicial Conduct. A full punishment chart viewer is included.

> Laws are summarized from the North Carolina General Statutes and the Structured Sentencing punishment charts for offenses on or after October 1, 2013, and simplified for a simulator. Statutes change; this is not legal advice. Hollis County and everyone in it are fictional.

## Running it

Requirements: a Mac with **Xcode 16 or later**. The app targets iOS 17 and later.

1. Open `JudgeSim.xcodeproj`.
2. Pick an iPhone simulator, or your own iPhone, and press **Run**.
   - To install on a physical device, set your Team under **Signing & Capabilities**.

If the project won't open in your Xcode version, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) and run `xcodegen` in this folder.

## Code map

```
JudgeSim/
  JudgeSimApp.swift            App entry point
  Models/
    Law.swift                  Offense classes, law entries
    LawLibrary.swift           NC statutes and doctrines (encyclopedia content)
    StructuredSentencing.swift Felony/misdemeanor charts, prior record, habitual felon, maximums
    CourtCase.swift            Case, evidence, witnesses, motions, objections
    World.swift                County, cast, people, probation terms, news, scheduled events
  Game/
    CaseTemplates*.swift       58 case blueprints with NC charges (1,000+ distinct scenarios, never repeated in a career)
    GenericPools.swift         Shared motions, objections, twists, ethics situations, prior records
    CaseGenerator.swift        Builds a case from a template, the county cast, and returning defendants
    Judgment.swift             Sentencing units, judgment text, appeals, news
    CaseSession.swift          State of a case in progress, including pleas and the trial flow
    CounselDialogue.swift      Bench conferences with the ADA and defense counsel
    ViolationHearings.swift    Probation violation hearings
    CalendarCall.swift         Administrative calendar calls
    GameState.swift            Calendar, people, news, scheduled events, save/load
  Views/                       SwiftUI screens
```
