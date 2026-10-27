import Foundation

/// What follows the batch AG written cases. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
extension StoryAftermath {
    static let beatsAG: [String: [Beat]] = [
        "story.softballBat": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Driver says {DL} swung bat at car window in traffic",
                 body: "A driver says {D} got out at a red light with a softball bat and swung at the open window, smashing the side mirror. Dash camera video has been turned over to deputies. Judge {JUDGE} heard {DL}'s earlier case over a bat swing at a county ballfield.",
                 followUps: ["story.followup.roadRageBat"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 20...150,
                 headline: "Rec league director reports threatening voicemail",
                 body: "The director of the county recreation league says a player banned after a bat swing in the parking lot left a voicemail promising \"you'll get your turn.\" Deputies have identified the caller as {D}, whose case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.leagueThreats"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 10...90,
                 headline: "County rec league adds rule: bats stay in the dugout",
                 body: "After the case of {D}, the county recreation league says players must leave equipment bags in the dugout until the parking lot clears, and a parks employee will stay until the last car leaves on game nights. {V} is still recovering from surgery."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "New video shows {VL} lunging before bat swing",
                 body: "A second phone video from the night at the ballfield shows {V} lunging at {D} with a cocked fist just before the swing. {DL}'s lawyer has asked Judge {JUDGE} for a new trial on self-defense.")
        ],
        "story.farmGateShots": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Neighbor's dog shot near Shiloh Road pasture",
                 body: "A family on Shiloh Road says their eleven-year-old Labrador was shot on the road shoulder by {D}, who says the dog was attacking a calf. Animal control is investigating. Judge {JUDGE} heard {DL}'s case over shots fired into a truck at {D.his} farm gate.",
                 followUps: ["story.followup.pastureDog"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Surveyor says farmer raised rifle over power line easement",
                 body: "A surveyor marking a power line easement says {D} drove up on a tractor and raised a rifle. The power company says it had mailed notice two weeks earlier. {DL}'s earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.surveyorRifle"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 10...90,
                 headline: "Sheriff adds night patrol on Shiloh Road after farm thefts",
                 body: "After a string of equipment thefts and the shooting at the farm of {D}, in which an 18-year-old passenger was hurt, the sheriff has assigned a deputy to patrol the Shiloh Road area overnight. Farmers there say they've asked for one for years."),
            Beat(triggers: [.probation, .prison], chance: 0.3, days: 30...150,
                 headline: "{VL}, hurt in farm gate shooting, graduates",
                 body: "{V}, who was hit by glass when shots were fired into a truck at the farm of {D}, walked at graduation this spring. {V.He} plans to study nursing. \"I'm not going to let one night decide everything,\" {V.he} said.")
        ],
        "story.lockoutBreakIn": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...200,
                 headline: "Parent from lockout case arrested at extended-stay motel",
                 body: "{D}, who broke back into an apartment after a landlord changed the locks without a court order, was arrested for trespass at an extended-stay motel after refusing to leave an unpaid room. {DL} says five weeks there made it {D.his} home. Judge {JUDGE} heard the earlier case.",
                 followUps: ["story.followup.motelHoldover"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...260,
                 headline: "Repossessed car driven off lot with spare key",
                 body: "A repossession company says {D} walked onto its lot after hours and drove off in the car it had taken for missed payments. {DL} says the title is in {D.his} name. Judge {JUDGE} heard {DL}'s earlier case after a lockout.",
                 followUps: ["story.followup.repoLot"]),
            Beat(triggers: [.cleared, .freed], chance: 0.5, days: 20...120,
                 headline: "Legal aid: landlords can't change the locks without a court order",
                 body: "Legal aid lawyers in Hollis County say calls about lockouts have doubled since the case of {D}, a tenant charged after breaking back into an apartment the landlord had locked without going to court. \"Self-help eviction is illegal in North Carolina,\" one lawyer said. {V} has since filed for eviction the proper way."),
            Beat(triggers: [.probation, .prison], chance: 0.4, days: 20...120,
                 headline: "Tenant advocates criticize conviction in lockout case",
                 body: "Tenant advocates say the conviction of {D}, who broke a window to get back into a unit the landlord had locked without a court order, sends the wrong message. The landlord, {V}, says {V.he} has since learned the eviction process.")
        ],
        "story.securityGuardShot": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Former bar guard found carrying pistol while drinking",
                 body: "{D}, the former security guard whose shooting of a patron holding a phone was heard by Judge {JUDGE}, was charged with carrying a concealed handgun while drinking after a deputy saw the pistol during a bar fight {DL} was not part of.",
                 followUps: ["story.followup.barCarry"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Pistol pulled in grocery store parking dispute",
                 body: "A driver who double-parked to pick up a prescription says {D} pointed a pistol through the windshield. {DL} says the driver came at {D.him} with a tire iron. {DL}'s earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.blockedInPistol"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 15...100,
                 headline: "Bar owners weigh unarmed security after door shooting",
                 body: "Two downtown bar owners say they've moved to unarmed door staff after the shooting of {V}, who was holding a phone when a guard fired. \"A bouncer's job is to keep the peace,\" one said. \"Not to be the last word.\""),
            Beat(triggers: [.prison, .probation], chance: 0.35, days: 60...240,
                 headline: "{VL} walks without cane for first time since shooting",
                 body: "{V}, shot in the hip outside a bar by guard {D}, says {V.he} walked a full block without a cane last week. {V.He} has quit drinking. \"I'm not proud of that night,\" {V.he} said. \"I'm proud of this block.\"")
        ],
        "story.parkingDeckRobbery": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Stolen cards used at four gas stations in three hours",
                 body: "Two debit cards taken from cars at an apartment complex were used at four gas stations in one night. Deputies say video shows {D}, whose hospital parking deck robbery case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.pumpCards"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 90...330,
                 headline: "Four cars broken into overnight on hospital deck",
                 body: "Night-shift workers came out to smashed windows on the top level of the hospital parking deck. Deputies say blood on one window has been matched to {D}. {DL}'s earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.deckBreakIns"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.6, days: 10...60,
                 headline: "Hospital adds security escorts after parking deck robbery",
                 body: "After a nurse was robbed at knifepoint on level 3 of its parking deck, the hospital says security officers will walk staff to their cars at shift change on request, and new cameras now cover the stairwells. The case against {D} went before Judge {JUDGE}."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Man arrested in second deck robbery had nurse's badge",
                 body: "A man arrested for robbing another hospital worker had the badge taken from {V} in the robbery {D} was convicted of. His cousin goes by Junior. {DL}'s lawyer has asked Judge {JUDGE} to set aside the robbery conviction.")
        ]
    ]
}
