import Foundation

/// What a probation violation was: the excuse offered has to fit it.
enum ViolationKind {
    case drugs, alcohol, service, money, curfew, treatment, contact, visits, moved, travel, work, school, arrest, abscond, newCrime
}

/// The reasons a probationer gives for falling short, by kind of violation. Each reason is written three ways, so the
/// same excuse rarely reads the same twice. Only reasons the record allows are offered: nothing about children
/// unless the person has them.
enum ViolationExcuses {

    static func pick(for kind: ViolationKind, name dl: String, supervised: Bool, town: String, kids: Int,
                     rng: inout SeededRNG) -> String {
        let pool = excuses(name: dl, supervised: supervised, town: town, kids: kids)
        let reasons = pool[kind] ?? pool[.visits] ?? [[""]]
        return rng.pick(rng.pick(reasons))
    }

    private static func excuses(name dl: String, supervised: Bool, town: String, kids: Int) -> [ViolationKind: [[String]]] {
        let office = supervised ? "the probation office" : "the courthouse"
        let child = kids == 1 ? "a young child" : "the children"
        var out: [ViolationKind: [[String]]] = [
            .visits: [
                ["\(dl) has no car, and \(office) is a 40-minute bus ride each way.",
                 "Without a car, getting to \(office) means two buses and most of a day for \(dl).",
                 "\(dl) lost the car in the spring. The bus to \(office) runs twice a morning, and \(dl) missed it more than once."],
                ["\(dl) was hospitalized for eight days during the reporting period.",
                 "\(dl) spent more than a week in the hospital with pneumonia, right when the visits were due.",
                 "The missed visits line up with a hospital stay. \(dl) has the discharge papers."],
                ["\(dl)'s shift schedule changed every week, and the office would only see \(dl) on weekday mornings.",
                 "\(dl) works a rotating schedule, and the office hours never lined up with a day off.",
                 "Every appointment fell on a shift \(dl) couldn't trade. \(dl) asked for evenings and was told no."],
                ["The officer changed three times in four months. \(dl) kept getting voicemails with appointment times that had already passed.",
                 "\(dl) had three different officers this year, and nobody told \(dl) when the appointments moved.",
                 "The file changed hands twice. The appointment letters went to an old address."],
                ["\(dl) was evicted and spent six weeks in a shelter that took phones at 9 p.m., so the reminder calls never came through.",
                 "\(dl) lost housing and was in a shelter without a working phone for most of those weeks.",
                 "After the eviction, \(dl) was moving between a shelter and a friend's couch, and the calls weren't getting through."],
                ["\(dl) was caring for a parent after a stroke and couldn't leave the house for long.",
                 "\(dl)'s mother had a stroke in the spring, and \(dl) is the only one at home to look after her.",
                 "\(dl) became a full-time caregiver for a parent overnight and let everything else slide."],
                ["\(dl)'s phone was cut off for nonpayment, and the office only called; it never wrote.",
                 "With the phone shut off, \(dl) had no way to get the appointment reminders.",
                 "The office's only way of reaching \(dl) was a phone that had been disconnected."],
                ["\(dl) thought the visits had been switched to phone check-ins after a call with the officer.",
                 "\(dl) understood the officer to say the next few check-ins could be done by phone.",
                 "There was a misunderstanding about phone reporting. \(dl) called in; the officer was expecting \(dl) in person."]
            ],
            .money: [
                ["\(dl) lost a job at a warehouse two months in and has been staying with different friends since.",
                 "The warehouse let \(dl) go early on, and there hasn't been a steady paycheck since.",
                 "\(dl) was laid off from the warehouse and has been couch-surfing ever since."],
                ["\(dl) paid what \(dl) could; most months that was rent or the lights, not court costs.",
                 "It came down to rent or the court costs most months, and \(dl) kept the lights on.",
                 "\(dl) paid something nearly every month. It just wasn't the full amount."],
                ["\(dl)'s hours were cut to part-time in the spring.",
                 "The restaurant cut \(dl) down to twenty hours a week.",
                 "\(dl) went from full-time to part-time with no warning, and the payments fell behind."],
                ["\(dl)'s car was repossessed, and with it the delivery job that paid the fines.",
                 "When the car went back to the lender, the delivery work went with it.",
                 "\(dl) drove for a delivery app until the car was repossessed. That was the money for the fines."],
                ["\(dl) has been working double shifts to cover rent and court costs, and still came up short.",
                 "\(dl) is working two jobs and is still behind.",
                 "Double shifts most weeks, and the arrears still kept growing."],
                ["A medical bill from an emergency room visit took what \(dl) had set aside.",
                 "\(dl) had an ER bill come due the same month as the payments and couldn't do both.",
                 "\(dl)'s savings went to a hospital bill after a fall at work."]
            ],
            .drugs: [
                ["\(dl) relapsed after a death in the family and asked the officer for a treatment bed before the report was filed.",
                 "\(dl)'s brother died in March. The relapse started that week, and \(dl) asked for help before anyone asked \(dl).",
                 "\(dl) went back to using after a funeral, then called the officer to ask for treatment."],
                ["\(dl)'s treatment provider closed its Hollis County office, and the nearest one has a two-month waitlist.",
                 "When the clinic closed, \(dl) lost treatment and the waitlist elsewhere is months long.",
                 "There's no treatment provider left in the county that takes \(dl)'s coverage."],
                ["\(dl) was prescribed pain medication after a work injury and didn't know it had to be reported.",
                 "The positive test was from a prescription after a back injury; \(dl) didn't bring the bottle.",
                 "\(dl) had a valid prescription and didn't understand it had to be disclosed first."],
                ["\(dl) has been using since the age of fifteen. The month before this was the first clean month in years.",
                 "This is a lifelong addiction, Judge, and \(dl) had just put together a clean month.",
                 "\(dl) is fighting something that started in high school, and was winning until this."],
                ["\(dl) was living with people who were using, with nowhere else to go.",
                 "The only place \(dl) could stay was with old friends who still use.",
                 "\(dl) couldn't get away from it at home, and the only other option was the street."]
            ],
            .alcohol: [
                ["\(dl) says the readings came from a long weekend after a funeral. \(dl) doesn't dispute drinking.",
                 "It was the weekend of a family funeral. \(dl) drank and admits it.",
                 "\(dl) went home for a burial and drank with family. \(dl) isn't denying it."],
                ["\(dl) works construction in the heat and says the strap kept slipping. The tampering alerts started the week the job started.",
                 "The obstruction alerts began when \(dl) started outdoor work; the strap kept sliding with the sweat.",
                 "\(dl)'s new job is on a roofing crew, and the bracelet didn't sit right through the workday."],
                ["\(dl) used a mouthwash and a hand sanitizer at work that the monitoring company says can trip the sensor.",
                 "Some of the readings are low enough to be the hand sanitizer \(dl) uses at the nursing home.",
                 "\(dl) works in a kitchen with alcohol-based cleaner all day."]
            ],
            .service: [
                ["The only community service site that would take \(dl) is in \(town), with no bus line.",
                 "The service site is out in \(town), and \(dl) has no way to get there.",
                 "\(dl) was assigned to a site in \(town) that no bus reaches."],
                ["\(dl) started a second job, and the service site is only open during working hours.",
                 "The site is open nine to three on weekdays, and \(dl) works nine to five.",
                 "\(dl) can't do the hours without quitting the job that pays the costs."],
                ["\(dl) did hours at a church that never sent in the paperwork.",
                 "\(dl) worked the hours at a food pantry; the signed sheet never made it to the office.",
                 "The hours were done. The volunteer coordinator who signed them has since left."],
                ["\(dl) hurt a knee in the spring and the only site available is physical labor.",
                 "The service site is roadside cleanup, and \(dl) has been on crutches.",
                 "\(dl)'s doctor said no lifting for eight weeks, and every open site was manual work."]
            ],
            .curfew: [
                ["\(dl) works a closing shift; the store keeps staff past curfew to finish inventory.",
                 "The manager keeps the closing crew late, and \(dl) can't leave early without losing the job.",
                 "Most of the alerts are nights the store ran late on a truck delivery."],
                ["Several alerts came from the monitor losing signal in \(dl)'s mobile home.",
                 "The signal drops at the back of the trailer where \(dl) sleeps.",
                 "The monitoring company has had signal problems on that road before."],
                ["\(dl) took a sick relative to the emergency room one night and didn't call it in.",
                 "One of the nights was an ambulance ride with an aunt to the ER.",
                 "\(dl) was at the hospital with a family member past curfew and forgot to call."],
                ["\(dl)'s ride home from work kept falling through, and the walk takes an hour.",
                 "\(dl) depends on a coworker for rides, and the coworker kept running late.",
                 "Without a car, getting home by curfew after a late shift wasn't always possible."]
            ],
            .treatment: [
                ["\(dl)'s treatment provider closed its Hollis County office in the spring.",
                 "The program \(dl) was ordered into shut down mid-course.",
                 "\(dl) was halfway through the program when the office closed its doors."],
                ["\(dl) couldn't pay the program's weekly fee after losing Medicaid coverage.",
                 "Without insurance, the program wanted $60 a week, and \(dl) didn't have it.",
                 "\(dl)'s coverage lapsed, and the program stopped seeing \(dl)."],
                ["The program met at 10 a.m. on weekdays, and \(dl)'s employer wouldn't give the time off.",
                 "\(dl) had to choose between group sessions and keeping the job.",
                 "The only sessions were during work hours."],
                ["\(dl) says the counselor was dismissive, and \(dl) stopped going before finding another.",
                 "\(dl) didn't get along with the counselor and asked to switch. The switch never happened.",
                 "\(dl) walked out after a bad session and meant to come back."]
            ],
            .contact: [
                ["\(dl) says the victim reached out first, about a shared phone bill.",
                 "The messages were about money they both owe on a phone plan, and the victim started the conversation.",
                 "\(dl) says the contact was answering the victim, not starting it."],
                ["\(dl) says they ran into each other by chance and \(dl) left as soon as words were exchanged.",
                 "It was a chance meeting, and \(dl) walked away.",
                 "\(dl) didn't know the victim would be there and left within minutes."],
                ["The contact was about returning property: clothes and a dog left at the old apartment.",
                 "\(dl) wanted personal things back and went about it the wrong way.",
                 "It was about getting belongings back. \(dl) should have gone through a lawyer."]
            ],
            .moved: [
                ["\(dl)'s landlord sold the house with thirty days' notice.",
                 "The house was sold out from under \(dl), and \(dl) had a month to get out.",
                 "\(dl) had to move fast when the rental was sold."],
                ["\(dl) left the approved address after a fight there and was afraid to go back.",
                 "Things turned violent at the old address, and \(dl) left that night.",
                 "\(dl) left a dangerous house and didn't think about the paperwork."],
                ["Mold and a broken furnace made the approved place unlivable.",
                 "The approved apartment failed a city inspection, and \(dl) moved in with a friend.",
                 "\(dl) moved out of a place with no heat in January."]
            ],
            .travel: [
                ["\(dl) went to see a dying grandparent and didn't think to ask first.",
                 "\(dl)'s grandmother was in hospice in another state, and \(dl) drove up without asking.",
                 "It was a last visit with a grandparent. \(dl) should have asked and didn't."],
                ["\(dl) says the officer approved the trip by phone. The officer has no record of it.",
                 "\(dl) believes the trip was cleared on a call; there's nothing in the notes.",
                 "\(dl) asked about the trip and thought the answer was yes."],
                ["The trip was for a job interview two states away.",
                 "\(dl) went to interview for a better-paying job and was back in two days.",
                 "A cousin set up an interview out of state, and \(dl) went."]
            ],
            .work: [
                ["\(dl) was laid off when the plant cut its second shift.",
                 "The plant eliminated \(dl)'s shift entirely.",
                 "\(dl) was one of forty let go when the second shift closed."],
                ["\(dl) has applied for dozens of jobs; the record keeps coming up on background checks.",
                 "Every application dies at the background check.",
                 "\(dl) has the rejection emails. Most cite the conviction."],
                ["\(dl) has had a back injury since the winter and can't do the only work \(dl) knows.",
                 "\(dl) has worked construction for years, and the injury ended that.",
                 "The doctor's note says no heavy work, and that's all \(dl) has ever done."]
            ],
            .school: [
                ["The GED class moved to a campus \(dl) can't get to without a car.",
                 "The class moved across the county, out of reach.",
                 "\(dl) was doing fine until the class moved to the college campus."],
                ["\(dl) has a learning disability that was never assessed, and the class moved too fast.",
                 "\(dl) struggled with the reading and was too embarrassed to say so.",
                 "\(dl) has never been tested for a learning disability and fell behind in the first week."]
            ],
            .arrest: [
                ["\(dl) thought a citation wasn't an arrest and didn't need reporting.",
                 "\(dl) understood a ticket to be different from an arrest.",
                 "Nobody put \(dl) in handcuffs, so \(dl) didn't think it counted."]
            ],
            .abscond: [
                ["\(dl) panicked after missing one visit and stopped coming in, afraid of being locked up.",
                 "\(dl) missed one appointment, got scared, and stayed away.",
                 "\(dl) assumed a warrant was coming and hid from it instead of facing it."],
                ["\(dl) was living in a car and moving between counties after losing housing.",
                 "\(dl) has been homeless and sleeping in a car in different towns.",
                 "With no address, \(dl) drifted between counties and lost touch with the office."],
                ["\(dl) was in a relationship that \(dl) says wasn't safe to leave, and the partner controlled the phone.",
                 "\(dl) says a partner kept \(dl) from leaving the house or answering calls.",
                 "\(dl) was living with someone who controlled where \(dl) went and who \(dl) talked to."]
            ],
            .newCrime: [
                ["\(dl) denies the new charge, and it hasn't been tried yet.",
                 "The new charge is only a charge; \(dl) says it isn't true.",
                 "\(dl) intends to fight the new charge in district court."],
                ["The new charge came out of the worst month \(dl) has had, and \(dl) is ready to answer for it in district court.",
                 "\(dl) isn't making excuses for the new charge. It came at a bad time.",
                 "That arrest came after \(dl) lost the job and the apartment in the same week."]
            ]
        ]
        if kids > 0 {
            out[.visits, default: []].append(
                ["\(dl) had no one to watch \(child) during office hours.",
                 "Childcare fell through, and \(dl) couldn't bring \(child) into the office.",
                 "\(dl) is raising \(child) alone and had no sitter for the morning appointments."])
            out[.money, default: []].append(
                ["\(dl) chose between the court costs and the daycare bill every month.",
                 "Daycare for \(child) takes most of what \(dl) earns.",
                 "Every month it was the court costs or \(child == "a young child" ? "the child's" : "the children's") daycare."])
            out[.curfew, default: []].append(
                ["One night was a sick child and a pharmacy run after curfew.",
                 "\(dl) went out late for medicine when \(child == "a young child" ? "the child" : "one of the children") had a fever.",
                 "A fever and an all-night pharmacy explain one of the nights."])
        }
        return out
    }
}
