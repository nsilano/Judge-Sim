# Judge Sim

An iPhone game where you play a bench-trial judge in the fictional **State of Westbrook**. Every case is generated fresh, so no two are the same. You rule on motions and objections, decide guilt, pass sentence, and then learn what really happened.

## How a case plays out

1. **Case File:** the charges, the defendant's background and record, counsel, and sometimes a twist (a sole caregiver, a terminal diagnosis, a DA running for re-election…).
2. **Pretrial Motions:** suppress evidence from an illegal search? Throw out a confession taken after the suspect asked for a lawyer? Dismiss for a speedy-trial violation? Suppressed evidence disappears from the trial, even when it proves guilt.
3. **Trial:** opening statements, exhibits, and witnesses with direct and cross-examination. Lawyers object (hearsay, leading, speculation, character evidence…), and you sustain or overrule. Some cases also put an ethics dilemma in front of you: an ex parte email, a gift from defense counsel, a call from the mayor's office.
4. **Verdict:** guilty, guilty of a lesser included offense, or not guilty, on each count.
5. **Sentencing:** set prison time inside the statutory range, with victim impact statements, the defendant's allocution, and aggravating and mitigating factors. You also decide on probation, fines, and whether multiple counts run concurrently or consecutively.
6. **Judgment:** the Court of Appeals reviews your rulings and may reverse. Then you see the public reaction, your grade, and **the truth**: whether the defendant actually did it.

Your career tracks **Integrity** (legal soundness) and **Public Approval**. A retention election comes every 8 cases. If integrity collapses, the Judicial Conduct Commission removes you.

## Why every case is different

`CaseGenerator` combines one of 21 case blueprints (armed robbery, a bar-fight stabbing, antifreeze poisoning, a battered spouse, hospital ransomware, a police excessive-force case, insulin shoplifting, a Ponzi scheme, a felon carrying a gun for protection, and more) with:

- randomly drawn defendants, victims, witnesses, and lawyers, with random backgrounds and prior records
- a random subset of each side's evidence, and witnesses who may be impeached on cross
- randomly attached motions, objections, twists, and ethics dilemmas
- a target case strength (clear guilt, close call, or weak), so the answer isn't always "guilty"
- a hidden truth that suppressed evidence still counts toward, so following the law sometimes frees the guilty

## Law Library

The Law Library is available from the tab bar and from inside the courtroom. It has 89 entries:

- **Offenses** (46), each with the elements the State must prove, the class, the sentencing range (minimum, typical, maximum), the maximum fine, probation eligibility, mandatory minimums, aggravating and mitigating factors, and common defenses
- **Doctrines** covering constitutional procedure (Fourth Amendment, Miranda, speedy trial, double jeopardy), rules of evidence (hearsay and its exceptions, leading questions, character evidence), defenses (self-defense, necessity, entrapment, insanity), sentencing principles, and judicial ethics

> Westbrook is fictional. Its code is a simplified composite of typical U.S. criminal law, written for gameplay. It is not legal advice.

## Running it

Requirements: a Mac with **Xcode 16 or later**. The game targets iOS 17 and later.

1. Open `JudgeSim.xcodeproj`.
2. Choose an iPhone simulator, or your own iPhone, and press **Run**.
   - To run on a physical device, open the JudgeSim target's **Signing & Capabilities** tab, select your Team, and change the bundle identifier (`com.example.JudgeSim`) to something unique.

If the project doesn't open in your Xcode version, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) and run `xcodegen` in this folder to regenerate it from `project.yml`.

## Code map

```
JudgeSim/
  JudgeSimApp.swift        App entry point
  Models/
    Law.swift              Law, categories, sentence ranges
    LawLibrary.swift       The Westbrook Penal Code (all encyclopedia content)
    CourtCase.swift        Case, evidence, witnesses, motions, objections
  Game/
    CaseTemplates.swift    The 21 case blueprints
    GenericPools.swift     Shared motions, objections, twists, ethics dilemmas, epilogues
    CaseGenerator.swift    Assembles a unique case from a seed
    Scoring.swift          Verdict review, appeals, sentencing guidelines, public reaction
    CaseSession.swift      State of a case in progress
    GameState.swift        Career, save/load, retention elections
  Views/                   SwiftUI screens
```

To add a new kind of case, add a `CaseTemplate` to `CaseTemplates.swift` and append it to `CaseTemplates.all`.
