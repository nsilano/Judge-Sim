import Foundation

/// Stock reasons and positions for the calendar call, in pools large enough that a long career doesn't run through them.
/// They are drawn through `Variety`, which remembers what has come up and favors what hasn't.
enum Excuses {
    /// What defense counsel tells the court when a client doesn't answer the calendar call.
    static let missedCourtDefense: [String] = [
        // Getting there
        "Car broke down on the way; asks for the afternoon.",
        "The ride fell through this morning; asks for a new date.",
        "Flat tire on a county road with no signal; asks the court to hold the matter until the afternoon.",
        "The county bus route was cancelled; asks for an hour.",
        "Ran out of gas on Highway 17 and is walking in; asks for the afternoon session.",
        "Car was towed from the lot behind the courthouse; asks for an hour to sort it out.",
        "License is suspended and the family member who drives had a shift change; asks for a new date.",
        "The road to my client's house was flooded overnight; asks for a new date.",
        "Stopped at the railroad crossing for forty minutes behind a stalled freight train; asks for the afternoon.",
        "The bridge on the county road is closed and the detour added an hour; asks for the afternoon session.",
        "The rideshare driver cancelled three times; asks for a new date.",
        "Walking from the edge of town because there was no ride; asks for an hour.",
        "Is in the security line downstairs with a long backup; asks the court to hold the matter for ten minutes.",
        "Circled the lot looking for a space and is on the stairs now; asks for ten minutes.",
        "Spent the morning at the district court building across town by mistake; asks for the afternoon.",
        // Health
        "Possible hospital visit; asks for a day.",
        "Was in the emergency room overnight and has the discharge papers; asks for a new date.",
        "Has a fever and the clerk's office asked sick people to stay home; asks for a new date.",
        "Dialysis appointment ran long; asks for the afternoon session.",
        "Had a panic attack in the parking lot and is with the courthouse nurse; asks for an hour.",
        "Surgery date was moved up to this week; asks for a continuance of three weeks.",
        "Injured at work yesterday and is waiting on an X-ray; asks for a new date.",
        "Pregnancy complications sent my client to the hospital this morning; asks for a new date.",
        "Medication made my client unable to drive this morning; asks for the afternoon.",
        "Is in an inpatient crisis unit this week; asks for a new date once discharged.",
        "Child came down with a high fever at school and my client is at the pediatrician; asks for the afternoon.",
        "Migraine since last night; asks for a new date and will bring a doctor's note.",
        "Is quarantined after a household member tested positive; asks for a new date.",
        // Family
        "Funeral service for my client's parent is this morning; asks for a new date.",
        "A close relative died on Sunday and the family is traveling; asks for a new date.",
        "Childcare fell through and there is no one for a toddler; asks for the afternoon.",
        "Caring for a relative on hospice; asks for a new date.",
        "A court-ordered custody exchange is this morning in another county; asks for the afternoon.",
        "Spouse was admitted to the hospital overnight; asks for a new date.",
        "Has a newborn at home and the baby was up all night in the emergency room; asks for the afternoon.",
        "Had to take a parent to a cancer appointment two hours away; asks for a new date.",
        // Work
        "The employer refused to let my client leave a shift; asks for the afternoon.",
        "Works a double shift at the plant and thought the afternoon session was the morning; asks for the afternoon.",
        "Drives a truck and is stuck in Georgia on a load; asks for a new date.",
        "Is deployed with the National Guard on a storm response; asks for a new date.",
        "Works on an offshore job and cannot be reached until Friday; asks for a new date.",
        "The harvest has to be in before the rain; asks for a new date.",
        "Was told by a supervisor that missing work meant being let go; asks for a new date.",
        "Seasonal work out of the county ends in three weeks; asks for a new date after that.",
        "Is a home health aide and the patient has no one else this morning; asks for the afternoon.",
        // Notice and confusion
        "May have confused the date; asks for the afternoon.",
        "The notice went to an old address and my client never saw it; asks for a new date.",
        "My client says the last court date was moved and believed this was next week; asks for a new date.",
        "I gave my client the wrong date. That is my error, not my client's; asks for a new date.",
        "Went to the wrong courtroom and sat there until the call ended; asks for the afternoon session.",
        "Believed the case was continued after a call from the clerk's office; asks the court to check the record before issuing an order for arrest.",
        "The text reminder said tomorrow; asks for a new date.",
        "Has no phone since the carrier shut it off, and no way to be reminded; asks for a new date.",
        "Moved in with family in another county and mail did not follow; asks for a new date.",
        "Thought a different judge was hearing the matter and went to the wrong floor; asks for an hour.",
        "Was told by a deputy at the door that the calendar had already been called; asks for a new date.",
        // Custody and other obligations
        "Is being held in the neighboring county's jail on a probation violation; the jail has confirmed it, and counsel asks the court not to issue an order for arrest while the transfer is arranged.",
        "Is in federal custody on an unrelated matter; asks for a new date.",
        "Is held in another state on a detainer; asks for a new date.",
        "Is in a residential treatment program that will not release my client until Friday; asks for a new date.",
        "Was arrested this morning on another charge and is at the sheriff's office; asks for the afternoon session.",
        "Is at the probation office for a required check-in that ran over; asks for an hour.",
        "Has a hearing in district court at the same hour; asks the court to hold the matter until the afternoon.",
        // Emergencies and everything else
        "A house fire last night; my client is with the Red Cross; asks for a new date.",
        "Evacuating after the storm warning; asks for a new date.",
        "A family emergency out of state; asks for a new date.",
        "Lost the wallet and the ID needed to get past security; asks for the afternoon.",
        "Phone died and the charger is in the car that won't start; asks for the afternoon.",
        "Wrecked on the way here and is giving a statement to the trooper; asks for the afternoon.",
        "Is at the magistrate's office taking out a protective order after a threat overnight; asks for the afternoon.",
        "My client is afraid to come to the courthouse because the other party is expected to be here; asks for a new date.",
        // Candor
        "Counsel knew the date and has no explanation to offer for the absence.",
        "Counsel has not been able to reach the client this morning and asks for the afternoon to try again.",
        "My client has not answered my calls in three weeks, and I expect to move to withdraw.",
        "I have no explanation to offer and will not make one up.",
        "Left a message at the number on file and got no answer; asks the court to hold the matter until the afternoon while I keep trying to reach my client.",
        "My client told me last week the plan was to come; I do not know what changed. Asks for the afternoon.",
        "No contact since the bond hearing; asks for three weeks and a new notice.",
        "My client texted this morning that there was no ride and then stopped answering; asks for the afternoon.",
        "My client says the pretrial release officer told them they did not need to come. I am trying to confirm that; asks for an hour."
    ]

    /// What the State asks for when a defendant doesn't answer the calendar call.
    static let missedCourtState: [String] = [
        "Order for arrest; forfeit the bond.",
        "Order for arrest, no bond.",
        "Order for arrest; double the bond.",
        "Order for arrest and a $5,000 increase in the bond; this is a failure to appear under G.S. 15A-305.",
        "Order for arrest. The defendant has been told the date in open court.",
        "The State would hold the matter until the afternoon, but asks for an order for arrest if the defendant doesn't appear.",
        "Order for arrest; the State will agree to reduce the bond once the defendant is back before the court.",
        "Order for arrest and forfeit the bond; the State has a victim in the courtroom who took the day off.",
        "Order for arrest. The State also asks that the bond be secured, not unsecured, when the defendant returns.",
        "No objection to holding the matter open until the afternoon.",
        "The State will take a continuance of three weeks and a new notice, with a warning that the next missed date means an order for arrest.",
        "Order for arrest; officers have been to the address twice.",
        "Order for arrest and forfeit the bond; the surety has been notified.",
        "The State asks for the order for arrest but not forfeiture, to give the surety time to surrender the defendant.",
        "Order for arrest; this is the defendant's second missed setting.",
        "The State will wait until the afternoon if the defense can tell the court where the defendant is.",
        "Order for arrest. Witnesses have been subpoenaed and are here today.",
        "Order for arrest; the defendant was served with the notice by a deputy.",
        "The State asks that the court find willful failure to appear (G.S. 15A-543) and double the bond.",
        "No position on the afternoon; the State asks the court to hear from the defense on whether the defendant has been reachable."
    ]

    /// The defense's reason for asking to continue a trial.
    static let continuanceDefense: [String] = [
        "Lab report just arrived; needs an expert.",
        "Newly appointed; hasn't met the client.",
        "A defense witness is deployed until next month.",
        "Four hours of new bodycam video to review.",
        "Stuck in a murder trial in another county.",
        "Client is in inpatient treatment for 28 days.",
        "The State produced 600 pages of discovery on Friday; needs three weeks to read them.",
        "A key defense witness is in the hospital after surgery.",
        "The defense investigator has not been able to locate the second eyewitness.",
        "Counsel has a conflicting trial in federal court that was set first.",
        "The cell-phone extraction came back yesterday and the defense expert has not seen it.",
        "Counsel's father died last week and counsel is out of the office until the end of the month.",
        "The State just disclosed a jailhouse informant; the defense needs time to investigate.",
        "A translator for a defense witness cannot be scheduled for this date.",
        "A defense witness is a long-haul trucker who will be on the road until the end of the month.",
        "The defense is still waiting on medical records the hospital promised weeks ago.",
        "The defense expert is testifying in another state that week.",
        "Counsel is on a medical leave that began last week; the office asks for a new date.",
        "Photographs of the scene were just turned over and counsel has not been able to visit the location.",
        "The client has been moved to another facility and counsel has not been able to meet with them.",
        "The defense needs to subpoena a custodian of records who was out of the country.",
        "A new charge was added to the indictment last week and the defense needs time to prepare for it.",
        "The defense is waiting on the State Crime Lab's second analysis requested under discovery.",
        "A defense witness was in a car accident on the way and cannot testify this week.",
        "The client is cooperating in a separate investigation and the State asked the defense to wait.",
        "The surveillance video the State relies on was only enhanced and re-sent on Monday.",
        "Counsel was just appointed after the first lawyer withdrew and has had the file for four days.",
        "The defense has asked the court for funds for an independent expert and the order was only signed last week.",
        "A defense witness is a nursing mother with no one to cover; asks for a date in the fall.",
        "Counsel has a jury trial that started on Monday and is expected to run all week.",
        "The client's family is raising money for the retained lawyer's fee and the lawyer has not entered an appearance.",
        "An alibi witness is serving overseas with the Navy and cannot be reached until next month.",
        "The defense just learned the lead detective has an unreported disciplinary history and needs to subpoena the personnel file.",
        "A hurricane evacuation kept the defense team out of the office for a week.",
        "The client had surgery on Tuesday and cannot sit through a trial.",
        "The defense received a plea offer yesterday with a deadline and needs time to review it with the client.",
        "The defense needs the transcript of the suppression hearing, which the reporter has not finished.",
        "A DNA retest is scheduled and the results are due before the new date.",
        "Counsel's co-counsel is the only attorney who handled the pretrial and is out on leave.",
        "The defendant's mother, the main defense witness, is in the hospital.",
        "The defense is awaiting a ruling on a motion in another case that will decide a legal issue in this one.",
        "Counsel received a diagnosis last week and asks for three weeks to arrange coverage.",
        "A defense witness refuses to come without a subpoena and the sheriff cannot serve it before the date.",
        "The defendant needs a mental-health evaluation the defense requested last month; the appointment is next week.",
        "The State substituted a new prosecutor yesterday, and the defense does not object to a short continuance for both sides.",
        "The defense received the victim's medical records yesterday; they run to 900 pages.",
        "The defense is waiting on a crash reconstruction report.",
        "A defense witness's employer will not release them during the harvest.",
        "The firearms examiner the defense retained has a family emergency.",
        "Newly retained counsel needs time to prepare after the client fired the first lawyer on Friday.",
        "The defense just learned of a possible second suspect and needs time to run it down.",
        "Counsel is awaiting the results of a polygraph the State requested last week.",
        "The client is eligible for a treatment court program, and the intake is the week after the trial date.",
        "An out-of-state witness has agreed to testify but needs 30 days to arrange travel.",
        "The defense is asking for the continuance to allow the client to finish a job-training program required for release.",
        "A fire at the defense office destroyed part of the file, and counsel is rebuilding it.",
        "The client is in the middle of a custody hearing set for the same day.",
        "The defense needs to inspect the vehicle, which the State just agreed to release from the impound lot.",
        "The video forensic examiner the defense retained cannot begin until the State turns over the original file.",
        "Counsel was in the hospital over the weekend and has not been able to prepare.",
        "The client has a sentencing in another county the same week.",
        "The defense expects to receive a revised toxicology report within days."
    ]

    /// The defense's argument when a client held on a bond asks the court to reduce it.
    static let bondReductionDefense: [String] = [
        "My client can't make this bond. That's not a bond, it's a detention order. A job is waiting.",
        "My client has been held more than three months on a charge that carries less time than that. The bond has become the punishment.",
        "The State's case has gotten weaker since the bond was set: the main witness has changed the account.",
        "My client has a place in a residential treatment program that will hold the bed for one week.",
        "A family member has offered a place to stay in another county and will drive my client to every setting.",
        "My client has lost an apartment and a job while held, and each week makes it harder to come back to either.",
        "My client is the only caregiver for a disabled parent, who is now alone.",
        "The jail has not been able to give my client the medication prescribed for a serious condition.",
        "My client has no record of failing to appear and has kept every date in this case.",
        "My client has been compliant with every condition of pretrial supervision in an earlier case.",
        "The bond was set before the lab results came back, and the report is favorable.",
        "The co-defendant, who has the same charge and a longer record, was released on a lower bond.",
        "My client offers a monitor, a curfew, and weekly reporting to pretrial services.",
        "A bondsman will write a bond at the lower figure but not at this one.",
        "My client's employer has held the job open for eleven weeks and cannot wait any longer."
    ]

    /// The State's position on a motion to reduce a bond.
    static let bondReductionState: [String] = [
        "The State opposes. The defendant has two prior failures to appear.",
        "The State would agree to a modest reduction with electronic monitoring.",
        "The State opposes; the victim is afraid and has asked that the defendant remain held.",
        "The State would agree to a reduction if the bond is secured and the defendant is on a curfew.",
        "The State opposes. The new information the defense relies on isn't new; it was before the court at the first appearance.",
        "The State takes no position on a reduction with a no-contact condition and a monitor.",
        "The State opposes. The defendant was on pretrial release in another case when this offense happened.",
        "The State would agree to a reduction to a figure that a bondsman will write, not to an unsecured bond.",
        "The State opposes any reduction until the defendant has a stable address.",
        "The State does not oppose release to the treatment program if the defendant stays through completion and reports back to the court.",
        "The State opposes. The facts of the offense haven't changed, and neither has the danger."
    ]

    /// The defense's reasons when someone asks the court for an evaluation of capacity to stand trial.
    static let capacityDefense: [String] = [
        "Client thinks counsel works for the DA and won't talk.",
        "Client believes the case is about a plot by neighbors and cannot say what the charge is.",
        "Client cannot explain what a plea is or what the judge does after three meetings.",
        "Client answers questions about the case with unrelated stories and has stopped taking medication.",
        "Client was found to lack capacity in an earlier case two years ago and has not been treated since.",
        "Client hears voices telling them not to trust anyone in the courtroom.",
        "Client has a traumatic brain injury and cannot hold a conversation for more than a few minutes.",
        "Client thinks a conviction means a prize and wants a trial immediately.",
        "Client refuses to speak with counsel and says the lawyer is a government agent.",
        "A jail psychiatrist wrote that the client is delusional and not oriented to time.",
        "Client's family says the decline began last year with a diagnosis of dementia.",
        "Client has an intellectual disability and does not understand the difference between guilty and not guilty."
    ]

    /// The State's position on a capacity motion.
    static let capacityState: [String] = [
        "No position; seemed oriented at the bond hearing.",
        "The State does not oppose an evaluation; the State has also seen the behavior counsel describes.",
        "The State opposes a delay. The defendant answered the court's questions clearly at the first appearance.",
        "The State asks for a local screening first, since a full evaluation takes months.",
        "The State agrees an evaluation is appropriate and asks that the report come back to both sides.",
        "The State takes no position but asks that the defendant be held while the evaluation is pending."
    ]

    /// The defense's explanation after a stay-away order was broken.
    static let contemptDefense: [String] = [
        "Says it was a chance meeting; asks for a warning.",
        "Didn't know the order still applied; asks for a warning.",
        "Accepts responsibility; asks for a fine.",
        "My client was invited to the other person's house and didn't think of it as a violation; asks for a warning.",
        "Both of them were at the same store; my client left as soon as they saw each other.",
        "The other person called first; my client regrets answering and asks for a fine.",
        "My client's workplace and the protected person's workplace share a parking lot.",
        "A relative gave my client the wrong address and my client went there not knowing it was covered.",
        "My client was never served with the renewed order; asks for a warning.",
        "My client says the two were reconciling; I have advised that the order still applies.",
        "My client's phone was used by a family member; asks for a warning.",
        "My client acknowledges it was a mistake and has already moved out of town."
    ]

    /// What the State asks when a stay-away order was broken.
    static let contemptState: [String] = [
        "30 days in jail; the protected person is afraid.",
        "Find willful contempt; active time.",
        "Find contempt.",
        "Find willful contempt and a $500 fine; the order was clear and the contact was deliberate.",
        "Find contempt; the State will take ten days if the defendant agrees to the order's renewal.",
        "Find willful contempt; this is the second report in two months.",
        "Find contempt and continue the order; the protected person asks only that it be followed."
    ]
}
