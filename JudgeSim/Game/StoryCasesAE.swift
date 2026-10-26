import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAE: [CaseTemplate] = [receiptCheck]

    // MARK: - The receipt that never printed (a paid-for television, a blocked cart, and a phone taken mid-recording)

    static let receiptCheck = CaseTemplate(
        key: "story.receiptCheck", category: .property,
        headlines: ["Shopper Arrested at Harbor Mart Exit Says the TV Was Paid For", "No Receipt, a Blocked Cart, and a Phone Taken Mid-Recording"],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 8, lesserThreshold: 6,
        specification: "Took and carried away a 65-inch television valued at $1,098, the property of Harbor Mart, without paying for it, on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "resisting", specification: "Willfully resisted, delayed, and obstructed {OFFICER}, a public officer, by refusing to produce a receipt and pulling away when the officer took hold of {D.his} phone, on {DATE}.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...45, occupations: ["delivery driver", "HVAC technician", "home health aide", "warehouse lead"], hasVictim: false,
        summaries: [
            "On {DATE} at about 5:40 p.m., {D} bought a 65-inch television at register 7 at Harbor Mart. The card reader beeped, but the receipt printer jammed and nothing came out. {DL}, due at work at six, pushed the cart toward the exit. A loss prevention associate, {LP}, stepped in front of the cart, took hold of it, and said, \"No receipt, no TV. We're not doing this today.\" {DL} said {D.he} had paid and was late, and started recording on {D.his} phone. {OFFICER} of the Hollis County Sheriff's Office, working an off-duty shift at the store, came over. When {DL} asked whether the law required {D.him} to show a receipt, the officer said, \"Yes. It's store policy, and you're on store property.\" As {DL} kept recording, the officer took the phone out of {D.his} hand and tried to stop the recording, and {DL} pulled {D.his} arm back. {DL} was handcuffed and charged with felony larceny and resisting an officer. The store's register journal shows no completed sale at register 7 at that time. {DL}'s bank app shows a pending $1,184.33 charge from Harbor Mart that afternoon."
        ],
        prosecutionEvidence: [
            E(.document, 2, "Register Journal", "Harbor Mart's register journal for register 7 shows the television scanned at 5:39 p.m. and the transaction marked \"suspended\" at 5:41 p.m. No completed sale for a television appears before the arrest."),
            E(.video, 2, "Store Exit Camera", "The ceiling camera at the front exit shows {LP} stepping in front of the cart and taking hold of it, and {DL} trying to steer around {LP} with the television in the cart."),
            E(.video, 1, "Officer's Body Camera", "The officer's camera shows {DL} refusing to show a receipt, saying \"I paid, I'm late, I'm leaving,\" and pulling {D.his} arm back as the officer takes the phone."),
            E(.statement, 1, "Loss Prevention Report", "{LP}'s written report: \"Customer exited past the registers with a 65-inch TV and no receipt. Customer refused to stop and became loud.\"")
        ],
        defenseEvidence: [
            E(.digital, 2, "Bank App Screenshot", "A screenshot from {DL}'s bank app, taken that night: \"HARBOR MART #2214, $1,184.33, pending,\" time-stamped 5:41 p.m."),
            E(.video, 2, "Defendant's Phone Recording", "{DL}'s own video, recovered from the phone: {DL} asks, \"Is it the law that I have to show you a receipt?\" The officer answers, \"Yes,\" then reaches for the phone. The picture swings to the floor and goes dark."),
            E(.document, 2, "Printer Service Ticket", "A Harbor Mart maintenance ticket opened at 5:44 p.m. that day: \"Register 7 receipt printer jammed, transactions hanging.\""),
            E(.document, 1, "Harbor Mart Exit Policy", "Harbor Mart's written asset protection policy: associates may ask to see a receipt, but may not physically stop a customer unless they personally saw the customer conceal or take merchandise without paying.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{LP}", role: "Loss prevention associate, Harbor Mart",
                        direct: ["\"There was no receipt and no sale in the system.\""],
                        cross: ["\"I didn't see {D.him} hide anything.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see at the exit?", "\"A 65-inch TV going out the door with no receipt and no bag. That's one of our most stolen items. I asked for the receipt and {D.he} kept walking.\"", "\"Big TV, no receipt, heading for the doors fast. I asked to see the receipt and {D.he} wouldn't stop.\""),
                            .direct("What did you do?", "\"I stepped in front of the cart and held it. I told {D.him} no receipt, no TV.\""),
                            .direct("Did you check the register?", "\"I radioed the front end. They said there was no completed sale for a TV at register 7.\""),
                            .cross("You didn't see {DL} conceal anything or skip a register?", "\"No. I didn't see the register part.\""),
                            .cross("Your store's policy says you can't physically stop a customer unless you saw the theft yourself.", "\"I know what the policy says. I thought {D.he} was stealing it.\"", "\"That's the policy. I made a call.\""),
                            .cross("The register 7 printer was jammed that afternoon?", "\"I found out later there was a ticket on it. I didn't know at the time.\"")
                        ]),
            WitnessSeed(name: "{OFFICER}", role: "Deputy, Hollis County Sheriff's Office (off-duty detail at Harbor Mart)",
                        direct: ["\"{D.He} wouldn't show a receipt and pulled away from me.\""],
                        cross: ["\"It's store policy, not a law. I misspoke.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find when you walked up?", "\"Loss prevention holding a cart with a TV in it and the customer saying {D.he} paid. No receipt. The store said no sale had gone through.\""),
                            .direct("Why did you arrest {DL}?", "\"The store told me the TV wasn't paid for, {D.he} was trying to leave with it, and when I went to secure the phone {D.he} pulled away from me.\""),
                            .cross("{DL} asked you if the law required {D.him} to show a receipt. You said yes.", "\"I did say that. It's the store's policy. It isn't a law. I misspoke.\"", "\"I said yes. That was wrong. No law requires a customer to show a receipt.\""),
                            .cross("Why did you take the phone?", "\"I wanted to stop the recording so I could talk to {D.him}. It was escalating things.\"", "\"It was in my face and it was escalating things.\""),
                            .cross("Was the phone evidence of anything?", "\"Not of the larceny, no.\""),
                            .cross("Did you check {DL}'s bank app before you arrested {D.him}?", "\"{D.He} tried to show me. I told {D.him} to save it for court.\"")
                        ]),
            WitnessSeed(name: nil, role: "Front-end manager, Harbor Mart",
                        direct: ["\"The sale was suspended, never completed.\""],
                        cross: ["\"A jammed printer can hang a sale.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What does the register journal show?", "\"The TV scanned at 5:39. At 5:41, the transaction went to suspended. There's no completed sale for it before the arrest.\""),
                            .direct("What does suspended mean?", "\"The sale stopped before it finished. Sometimes the card was charged, sometimes it wasn't.\""),
                            .cross("A jammed printer can leave a sale hanging?", "\"It can. The printer has to confirm before the sale closes. We've had it happen.\""),
                            .cross("Did the sale post later that night?", "\"I didn't check that night. The vendor would have the full log.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Cashier, register 7, Harbor Mart",
                        direct: ["\"The card beeped approved. The printer jammed.\""],
                        cross: ["\"I didn't see the screen say complete.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened when {DL} paid?", "\"{D.He} tapped the card, the reader beeped like it does when it's approved, and then the printer just ground and stopped. No receipt.\""),
                            .direct("What did you tell {D.him}?", "\"I told {D.him} customer service could reprint it. The line there was twenty people deep. {D.He} said {D.he} was late for work.\""),
                            .direct("Had the printer jammed before that day?", "\"Twice that afternoon. I'd asked for somebody to come look at it.\""),
                            .cross("Did your screen say the sale was complete?", "\"I didn't look at the screen. I was fighting with the printer.\""),
                            .cross("So you don't know whether the sale actually went through.", "\"I know the card beeped. I can't tell you what the computer did after that.\"")
                        ])
        ],
        prosecutionTheory: ["The register shows no completed sale. {DL} walked a $1,098 television out the door without paying, then fought the deputy who stopped {D.him}."],
        defenseTheory: ["{DL} paid. The bank shows the charge, the printer jammed, and a store employee and a deputy treated a store policy as the law, then took {D.his} phone to stop {D.him} from recording it."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"I paid for that TV. I just wanted to get to work. I'm sorry it got as far as it did.\""],
        guiltyTruths: ["The bank later confirmed the $1,184.33 charge was an authorization that dropped off two days later; the sale never completed, and the card reader had shown \"Transaction not complete\" when {DL} walked away."],
        innocentTruths: ["The register vendor's log showed the jammed printer had held a completed sale for forty-three minutes; it posted at 6:24 p.m., while {DL} was being booked. Harbor Mart's charge never came off {D.his} card."],
        moods: [.divided], doctrines: ["burdenOfProof", "searchSeizure", "lesserIncluded"],
        extras: ["LP": ["Travis Kinlaw", "Brandon Strickland", "Corey Lassiter"], "OFFICER": ["Deputy Ray Tyndall", "Deputy Shane Ivey", "Deputy Kyle Pope"]],
        story: StoryExtras(
            timeline: [(0, "5:39 p.m.: television scanned at register 7. 5:41 p.m.: card tapped; the printer jams; the sale shows suspended. 5:43 p.m.: {LP} blocks the cart at the exit. 5:46 p.m.: the off-duty deputy arrives; {DL} asks whether the law requires a receipt; the deputy takes the phone; {DL} arrested."), (0, "5:44 p.m.: maintenance ticket opened for the register 7 printer."), (1, "{DL} screenshots the pending $1,184.33 charge from the bank app."), (3, "Phone returned to {DL} at the jail; the recording is still on it.")],
            howIdentified: "Stopped at the exit by loss prevention with the television in the cart.",
            notDone: ["Nobody asked the register vendor for the full transaction log before charging the case.", "The deputy didn't look at the bank app {DL} offered at the scene."],
            defendantExam: [
                .direct("Did you pay for the television?", "\"Yes. I tapped my card, it beeped, and the printer jammed. The cashier told me to go to customer service, and that line was out the door.\""),
                .direct("Why didn't you wait?", "\"I was due at work at six. I'd already paid. I didn't think I needed a piece of paper to leave with something I bought.\""),
                .direct("Why did you start recording?", "\"Because a man grabbed my cart and wouldn't let go. I wanted a record of it.\""),
                .direct("What happened with the phone?", "\"I asked the deputy if it was the law that I had to show a receipt. He said yes, then he snatched my phone and tried to shut it off. I pulled my arm back because he grabbed me.\""),
                .cross("You saw the screen on the card reader?", "\"I heard it beep. I didn't read the screen.\"", "\"It beeped. That's what it does when it goes through.\""),
                .cross("You refused to show a receipt to a deputy.", "\"I didn't have one to show. I offered him my bank app.\""),
                .cross("And you pulled away from him.", "\"From his hand on my wrist, yes.\"")
            ],
            prosecutionOpening: "No receipt, no completed sale, and a $1,098 television headed out the door.",
            defenseOpening: "A paid-for TV, a jammed printer, and a store policy treated like the law.",
            prosecutionClosing: "The store's own system says that sale never finished, and {DL} knew {D.he} had no receipt. Then {D.he} pulled away from a deputy doing his job.",
            defenseClosing: "The bank shows the charge, the cashier heard the approval, and a maintenance ticket shows the printer was broken. No law makes a customer show a receipt, and a deputy can't take a phone because he doesn't like being filmed.",
            time: "5:40 p.m."
        )
    )
}
