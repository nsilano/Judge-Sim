# Judge Sim

An iPhone simulator in which you serve as a Resident Superior Court Judge in **Hollis County, North Carolina** (a fictional county). Defendants have waived a jury, so you hear the motions, rule on objections, decide guilt, and impose sentence under North Carolina's Structured Sentencing Act.

There is no score and no right answer. You make rulings, and the world responds: appeals come back months later, the local paper covers your cases, and people you sentenced, put on probation, or acquitted may appear in your courtroom again.

## A case

1. **Case file:** docket number (`27 CRS 004512`), session date, procedural posture (jury waiver under N.C. Const. art. I, § 24; habitual felon indictment; probation status), the defendant's record with offense classes and counties, the charges with G.S. citations, counsel, and the investigating agency.
2. **Pretrial motions:** suppress evidence under G.S. 15A-974, suppress statements (Miranda, voluntariness), or dismiss on speedy-trial grounds.
3. **Trial:** exhibits and witnesses, with objections under the North Carolina Rules of Evidence. Sometimes there is also an ethics situation outside the courtroom.
4. **Verdict:** guilty, guilty of a lesser-included offense, or not guilty, on each count.
5. **Sentencing (Structured Sentencing):**
   - Prior record points and level (I–VI felony, I–III misdemeanor), including the +1 point for offending on probation
   - Habitual felon status (sentenced four classes higher, capped at Class C), with predicate convictions excluded from points
   - Findings of aggravating and mitigating factors, which open the aggravated and mitigated ranges
   - Mitigated, presumptive, or aggravated range; a minimum term, with the statutory maximum computed automatically
   - Active, Intermediate, or Community disposition, as the chart cell allows, and the probation length
   - Consolidated judgment or separate judgments run concurrently or consecutively, plus a fine
6. **Probation violation hearing:** if the defendant was on probation, you decide whether to revoke, modify, or continue it.
7. **Judgment:** the judgment and commitment, any notice of appeal, reactions in the hallway, and tomorrow's story in the *Port Hollis Ledger*.

## The county

Each career generates one Hollis County, and it stays the same throughout:

- **Fixed cast:** an elected District Attorney and their ADAs, the Chief Public Defender and assistants, private defense lawyers, the Clerk of Superior Court, the Sheriff, the Port Hollis police chief, detectives, officers, and Highway Patrol troopers. You can see all of them under **Chambers → Hollis County Courthouse**.
- **Calendar:** time moves forward between cases, and docket numbers increase in sequence.
- **People:** everyone who appears before you is kept on record. Prison sentences run out, probation ends, and people can be arrested again. Returning defendants bring their full record, including convictions from your courtroom. If they were on probation from your court, you hold a violation hearing.
- **Events:** appeals are decided by the Court of Appeals (or the Supreme Court in life-without-parole cases) months after judgment. Exonerations through the North Carolina Innocence Inquiry Commission, new evidence, and press coverage of ethics choices also surface over time.
- **What really happened** is never shown to you directly. Sometimes it comes out later in the news.

## Law Library

The library has 60 North Carolina offenses and 51 doctrine entries. Each offense shows its G.S. citation, class, elements, and the presumptive, mitigated, and aggravated minimum ranges and dispositions at every prior record level, taken from the felony and misdemeanor punishment charts. Doctrine entries cover criminal procedure, the Rules of Evidence, defenses (including *State v. Norman* and *State v. Mercer*), Structured Sentencing, habitual felon status, probation violations, and the Code of Judicial Conduct. A full punishment chart viewer is included.

> Laws are summarized from the North Carolina General Statutes and the Structured Sentencing punishment charts for offenses on or after October 1, 2013, and simplified for a simulator. Statutes change; this is not legal advice. Hollis County and everyone in it are fictional.

## Running it

Requirements: a Mac with **Xcode 16 or later**. The app targets iOS 17 and later.

1. Open `JudgeSim.xcodeproj`.
2. Pick an iPhone simulator, or your own iPhone, and press **Run**.
   - To install on a physical device, set your Team under **Signing & Capabilities** and change the bundle identifier (`com.example.JudgeSim`) to something unique.

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
    CaseTemplates.swift        21 case blueprints with NC charges
    GenericPools.swift         Shared motions, objections, twists, ethics situations, prior records
    CaseGenerator.swift        Builds a case from a template, the county cast, and returning defendants
    Judgment.swift             Sentencing units, judgment text, appeals, news
    CaseSession.swift          State of a case in progress
    GameState.swift            Calendar, people, news, scheduled events, save/load
  Views/                       SwiftUI screens
```
