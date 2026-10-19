import Foundation

/// One line of a defendant's personal history, with what it requires of the person.
struct BackgroundLine {
    let text: String
    /// Youngest age the line makes sense for.
    var minAge: Int = 18
    /// Only for people out of school and working age (not current students).
    var adult: Bool = false
}

/// Several hundred distinct backgrounds so that no two defendants in a career share one.
/// Every line is gender-neutral; {HOOD} becomes a county town.
enum BackgroundLines {
    private typealias B = BackgroundLine

    static let all: [BackgroundLine] = upbringing + family + work + military + health + community + turningPoints + laterLife

    // MARK: Growing up

    private static let upbringing: [BackgroundLine] = [
        B(text: "Grew up in {HOOD}; the first in the family to finish high school."),
        B(text: "Raised by a grandmother after both parents struggled with addiction."),
        B(text: "Was in foster care from age 9 to 18."),
        B(text: "Grew up on a tobacco farm outside {HOOD}, the youngest of seven."),
        B(text: "Raised by a single parent who worked nights at the poultry plant."),
        B(text: "Moved between four schools by the eighth grade as the family chased work."),
        B(text: "Grew up above the family's laundromat on Fifth Street."),
        B(text: "Spent two years of childhood in a homeless shelter in Wilmington."),
        B(text: "Was a state wrestling qualifier at Hollis County High School."),
        B(text: "Grew up in a church where a parent was the choir director."),
        B(text: "Raised in {HOOD} by an aunt after a parent was deported."),
        B(text: "Was held back in the third grade and diagnosed with dyslexia at fourteen."),
        B(text: "Grew up caring for a younger sibling with cerebral palsy."),
        B(text: "Spent summers working a parent's shrimp boat out of Port Hollis."),
        B(text: "Lost a parent to an overdose at age eleven."),
        B(text: "Was a promising trumpet player until a hand injury at sixteen."),
        B(text: "Grew up in a trailer park off Route 17 that flooded twice."),
        B(text: "Raised by grandparents on a small farm; still helps with the hay every summer."),
        B(text: "Moved to Hollis County from Puerto Rico at age ten, speaking no English."),
        B(text: "Grew up the oldest of five, cooking dinner for siblings from age twelve."),
        B(text: "Spent a year in a juvenile facility at fifteen; the record was sealed."),
        B(text: "Was the starting point guard on a team that reached the state semifinals."),
        B(text: "Grew up in a military family and lived on four bases before age twelve."),
        B(text: "Raised in {HOOD} by a parent who ran a small auto shop."),
        B(text: "Ran away from home at sixteen and lived with a friend's family."),
        B(text: "Grew up in a house with no running water until age eight."),
        B(text: "Was a regular at the Port Hollis Boys & Girls Club growing up."),
        B(text: "Lost a sibling to gun violence at fourteen."),
        B(text: "Moved here from Ohio at twelve after a parent's plant closed."),
        B(text: "Grew up speaking Spanish at home and translated for the family's doctor visits."),
        B(text: "Raised Jehovah's Witness; left the faith at nineteen and lost contact with family."),
        B(text: "Grew up in {HOOD} and has never lived more than ten miles from the house they were born in."),
        B(text: "Spent childhood summers with relatives in the Outer Banks."),
        B(text: "Was a junior beekeeper in 4-H and still keeps two hives."),
        B(text: "Grew up in a Lumbee family in Robeson County before moving to {HOOD}."),
        B(text: "Raised by a parent who was paralyzed in a logging accident."),
        B(text: "Taught to fix engines by a grandparent in a backyard shop."),
        B(text: "Was adopted at age four from a Guatemalan orphanage."),
        B(text: "Grew up in public housing in Port Hollis, the child of a school custodian."),
        B(text: "Lived in a car with a parent for most of one school year.")
    ]

    // MARK: Family

    private static let family: [BackgroundLine] = [
        B(text: "Dropped out of community college to care for a sick parent.", minAge: 20, adult: true),
        B(text: "Is the primary caregiver for a parent with early-onset Alzheimer's.", minAge: 25, adult: true),
        B(text: "Is raising a niece and nephew after a sibling went to prison.", minAge: 24, adult: true),
        B(text: "Lost a child to sudden infant death syndrome six years ago.", minAge: 26),
        B(text: "Has full custody of a child with autism and works around therapy appointments.", minAge: 25, adult: true),
        B(text: "Went through a bitter custody fight that ended last year.", minAge: 25),
        B(text: "Sends money every month to grandparents in Honduras.", minAge: 20, adult: true),
        B(text: "Became a parent at seventeen and finished school at night.", minAge: 21),
        B(text: "Is a foster parent to two teenagers through Hollis County DSS.", minAge: 30, adult: true),
        B(text: "Cares for a spouse disabled in a workplace accident.", minAge: 30, adult: true),
        B(text: "Moved back in with a parent after a divorce two years ago.", minAge: 28),
        B(text: "Is the only sibling still speaking to an estranged father.", minAge: 22),
        B(text: "Helped raise four younger siblings after a parent's stroke.", minAge: 22),
        B(text: "Has a twin who is serving a sentence in another state.", minAge: 22),
        B(text: "Became a grandparent at thirty-eight.", minAge: 38),
        B(text: "Is going through a divorce after fourteen years of marriage.", minAge: 34),
        B(text: "Adopted a former foster child last year.", minAge: 30, adult: true),
        B(text: "Lost a spouse to cancer three years ago.", minAge: 32),
        B(text: "Has a teenage child in residential treatment out of state.", minAge: 34),
        B(text: "Pays for a younger sibling's college with a second job.", minAge: 24, adult: true),
        B(text: "Reconnected with a birth parent through a DNA test two years ago.", minAge: 22),
        B(text: "Is the guardian of a younger sibling with Down syndrome.", minAge: 24, adult: true),
        B(text: "Moved to {HOOD} to be near a grandchild born premature.", minAge: 42),
        B(text: "Has five children, the oldest of whom just enlisted.", minAge: 38),
        B(text: "Has been married to a high school sweetheart for twenty years.", minAge: 38),
        B(text: "Was widowed young and raised two children alone.", minAge: 32),
        B(text: "Cares for a grandmother with dementia every weekend.", minAge: 20),
        B(text: "Lost the family home to a foreclosure in 2019.", minAge: 28),
        B(text: "Is estranged from both children after a long addiction.", minAge: 38),
        B(text: "Moved to Port Hollis four years ago to be closer to a partner's family.", minAge: 23)
    ]

    // MARK: Work and money

    private static let work: [BackgroundLine] = [
        B(text: "Moved to Port Hollis four years ago after losing a job upstate.", minAge: 23, adult: true),
        B(text: "Has lived in the same apartment in {HOOD} for eleven years.", minAge: 30),
        B(text: "Was laid off when the paper mill closed and has not found steady work since.", minAge: 30, adult: true),
        B(text: "Started a lawn care business with one mower and now has three crews.", minAge: 25, adult: true),
        B(text: "Filed for bankruptcy two years ago after a failed food truck.", minAge: 26, adult: true),
        B(text: "Worked the same shift at the same warehouse for twelve years.", minAge: 30, adult: true),
        B(text: "Was named employee of the year at a regional trucking company.", minAge: 24, adult: true),
        B(text: "Lost a job after a back injury and spent a year on disability.", minAge: 28, adult: true),
        B(text: "Owes about $40,000 in medical debt from an uninsured surgery.", minAge: 25),
        B(text: "Has worked two jobs for most of the past decade.", minAge: 28, adult: true),
        B(text: "Was a union steward at the Port Hollis docks for six years.", minAge: 32, adult: true),
        B(text: "Ran a small barbecue stand on weekends until a fire destroyed the smoker.", minAge: 25, adult: true),
        B(text: "Was fired from a hospital job after a dispute with a supervisor.", minAge: 26, adult: true),
        B(text: "Got a commercial driver's license at 22 and drove long-haul for eight years.", minAge: 30, adult: true),
        B(text: "Went back to school at thirty for a welding certificate.", minAge: 32, adult: true),
        B(text: "Spent three years working on fishing boats in Alaska.", minAge: 26, adult: true),
        B(text: "Built a small online business selling refurbished phones.", minAge: 22, adult: true),
        B(text: "Was evicted twice in the past three years.", minAge: 24),
        B(text: "Worked as a carnival ride operator for five seasons.", minAge: 25, adult: true),
        B(text: "Inherited a failing family hardware store and kept it open for six years.", minAge: 32, adult: true),
        B(text: "Gambled away a $60,000 insurance settlement over two years.", minAge: 30),
        B(text: "Earned a real estate license but sold only one house.", minAge: 25, adult: true),
        B(text: "Has been self-employed as a handyman for most of adult life.", minAge: 28, adult: true),
        B(text: "Worked in a Charlotte bank call center for five years before moving home.", minAge: 28, adult: true),
        B(text: "Was a line supervisor at a textile plant until it moved to Mexico.", minAge: 40, adult: true),
        B(text: "Turned down a college scholarship to work and support the family.", minAge: 22, adult: true),
        B(text: "Has paid child support without missing a month for nine years.", minAge: 28, adult: true),
        B(text: "Lost a small restaurant during the pandemic shutdowns.", minAge: 30, adult: true),
        B(text: "Drove for a rideshare app full-time after a layoff.", minAge: 24, adult: true),
        B(text: "Cleans offices overnight while taking online classes by day.", minAge: 20, adult: true)
    ]

    // MARK: Service

    private static let military: [BackgroundLine] = [
        B(text: "Served four years in the Navy; honorably discharged.", minAge: 24, adult: true),
        B(text: "Served two tours in Afghanistan with the Army; honorably discharged.", minAge: 30, adult: true),
        B(text: "Served six years in the Marine Corps, including one deployment to Iraq.", minAge: 32, adult: true),
        B(text: "Served in the Air Force as an aircraft mechanic; honorably discharged.", minAge: 26, adult: true),
        B(text: "Served three years in the Coast Guard out of Wilmington.", minAge: 24, adult: true),
        B(text: "Spent eight years in the North Carolina National Guard, including hurricane deployments.", minAge: 28, adult: true),
        B(text: "Enlisted in the Army at eighteen and was medically discharged after a training injury.", minAge: 22, adult: true),
        B(text: "Was a volunteer firefighter in {HOOD} for six years.", minAge: 26, adult: true),
        B(text: "Worked as an EMT for four years before burning out.", minAge: 26, adult: true),
        B(text: "Was a corrections officer at a state prison for three years.", minAge: 26, adult: true)
    ]

    // MARK: Health

    private static let health: [BackgroundLine] = [
        B(text: "Has a documented history of depression and anxiety."),
        B(text: "Was diagnosed with bipolar disorder at twenty-two and takes medication inconsistently.", minAge: 23),
        B(text: "Has been in recovery from opioid addiction for three years, with one relapse.", minAge: 24),
        B(text: "Survived a serious car crash at nineteen and lives with chronic pain.", minAge: 21),
        B(text: "Has type 1 diabetes and was hospitalized twice last year.", minAge: 18),
        B(text: "Was diagnosed with PTSD after a home invasion seven years ago.", minAge: 25),
        B(text: "Has completed two inpatient alcohol treatment programs.", minAge: 25),
        B(text: "Lost hearing in one ear after a workplace explosion.", minAge: 25, adult: true),
        B(text: "Has epilepsy and lost a driver's license for a year after a seizure.", minAge: 20),
        B(text: "Is a kidney transplant recipient and is on lifelong medication.", minAge: 24),
        B(text: "Has a traumatic brain injury from a fall at a construction site.", minAge: 25, adult: true),
        B(text: "Was diagnosed with ADHD as an adult and says it explained a lot.", minAge: 24),
        B(text: "Has struggled with methamphetamine use since a back injury in their twenties.", minAge: 28),
        B(text: "Attends Narcotics Anonymous meetings in {HOOD} twice a week.", minAge: 22),
        B(text: "Survived breast cancer at thirty-one.", minAge: 33),
        B(text: "Was hospitalized after a suicide attempt four years ago and is in therapy.", minAge: 22),
        B(text: "Has an intellectual disability; reads at about a sixth-grade level.", minAge: 18),
        B(text: "Is a recovering gambler who self-excluded from both state casinos.", minAge: 26),
        B(text: "Uses a wheelchair since a motorcycle crash at twenty-four.", minAge: 26),
        B(text: "Has severe asthma and was hospitalized during the last wildfire smoke season.", minAge: 18),
        B(text: "Has been sober for eleven years after a DWI crash.", minAge: 32),
        B(text: "Was diagnosed with schizophrenia at twenty and has been stable on medication for years.", minAge: 25),
        B(text: "Lives with chronic migraines that cost two jobs.", minAge: 25, adult: true),
        B(text: "Has sickle cell disease and spends several weeks a year in the hospital.", minAge: 18),
        B(text: "Completed Drug Treatment Court in another county five years ago.", minAge: 25)
    ]

    // MARK: Community and interests

    private static let community: [BackgroundLine] = [
        B(text: "Volunteers weekends at a church food pantry, according to letters filed with the court."),
        B(text: "Coaches a youth soccer team in {HOOD}.", minAge: 22),
        B(text: "Sings in the choir at a Baptist church in {HOOD}.", minAge: 18),
        B(text: "Builds wheelchair ramps with a church volunteer crew.", minAge: 22),
        B(text: "Plays bass in a local bluegrass band that plays fish fries."),
        B(text: "Fosters rescue dogs for the Hollis County animal shelter.", minAge: 22),
        B(text: "Organizes a free Thanksgiving dinner in {HOOD} every year.", minAge: 25),
        B(text: "Mentors teenagers through a Big Brothers Big Sisters program.", minAge: 24),
        B(text: "Restores old pickup trucks and shows them at county fairs.", minAge: 22),
        B(text: "Is a deacon at a small church in {HOOD}.", minAge: 35),
        B(text: "Competes in amateur barbecue contests across the state.", minAge: 25),
        B(text: "Runs a youth fishing tournament at the Port Hollis pier.", minAge: 28),
        B(text: "Tutors adults studying for the GED at the public library.", minAge: 25),
        B(text: "Plays in a men's and women's church softball league every summer."),
        B(text: "Is known around {HOOD} for fixing neighbors' cars for free.", minAge: 22),
        B(text: "Delivers Meals on Wheels on Tuesday mornings.", minAge: 25),
        B(text: "Was a regular volunteer at the county's hurricane shelters.", minAge: 22),
        B(text: "Leads a weekly AA meeting at a {HOOD} church.", minAge: 30),
        B(text: "Coaches a Little League team that a child plays on.", minAge: 28),
        B(text: "Grows vegetables in a community garden and gives most of them away."),
        B(text: "Rescued two children from a house fire in 2021, according to a news clipping in the file.", minAge: 22),
        B(text: "Paints murals for local businesses in {HOOD}."),
        B(text: "Is a competitive powerlifter who trains at a {HOOD} gym."),
        B(text: "Hunts deer every fall with the same group of friends since high school.", minAge: 22),
        B(text: "Plays drums at a Pentecostal church three nights a week."),
        B(text: "Is a regular at the Port Hollis farmers' market, selling honey and jam.", minAge: 25),
        B(text: "Runs a social media page about local high school football with 9,000 followers."),
        B(text: "Collects vintage vinyl records and has more than 2,000."),
        B(text: "Volunteers at the animal shelter in {HOOD} on weekends."),
        B(text: "Organized a neighborhood watch after a string of break-ins.", minAge: 30),
        B(text: "Has run the same bowling league team for a decade.", minAge: 30),
        B(text: "Builds furniture in a garage shop and sells it at craft fairs.", minAge: 25),
        B(text: "Is learning to fly and has logged forty hours toward a pilot's license.", minAge: 22),
        B(text: "Races dirt-track cars at the county speedway on Saturday nights."),
        B(text: "Helps run a free clothing closet at a {HOOD} church.", minAge: 25),
        B(text: "Gives haircuts at the homeless shelter one Sunday a month.", minAge: 22),
        B(text: "Plays chess in the park every Saturday and has a local rating."),
        B(text: "Writes poetry and has read at open mics in Port Hollis."),
        B(text: "Is an amateur boxer with a 6-2 record."),
        B(text: "Spends weekends restoring a 1970s sailboat at the Port Hollis marina.", minAge: 28)
    ]

    // MARK: Turning points

    private static let turningPoints: [BackgroundLine] = [
        B(text: "Was shot in a robbery at nineteen and still carries the bullet.", minAge: 21),
        B(text: "Lost everything in Hurricane Florence and lived in a FEMA trailer for a year.", minAge: 24),
        B(text: "Was the victim of a carjacking two years ago and testified at that trial.", minAge: 20),
        B(text: "Spent six months in county jail at twenty on charges later dismissed.", minAge: 22),
        B(text: "Won $50,000 in the state lottery four years ago and spent it within a year.", minAge: 25),
        B(text: "Was exonerated of a robbery charge in another county after DNA testing.", minAge: 26),
        B(text: "Testified for the State in a murder trial three years ago.", minAge: 22),
        B(text: "Was the target of a scam that drained a retirement account.", minAge: 40),
        B(text: "Survived a house fire that killed a roommate.", minAge: 22),
        B(text: "Was a key witness in a police misconduct lawsuit.", minAge: 24),
        B(text: "Found a parent dead of a heart attack at age sixteen."),
        B(text: "Moved to {HOOD} from Atlanta after a violent relationship ended.", minAge: 24),
        B(text: "Had a child removed by DSS and regained custody after two years.", minAge: 26),
        B(text: "Was struck by a drunk driver at twenty-three and spent months in rehabilitation.", minAge: 25),
        B(text: "Recently got engaged and was planning a wedding for next spring.", minAge: 22),
        B(text: "Bought a first home last year after a decade of saving.", minAge: 28, adult: true),
        B(text: "Was recently baptized and says faith changed everything.", minAge: 18),
        B(text: "Returned to {HOOD} after fifteen years away to care for family.", minAge: 33),
        B(text: "Quit drinking the day a child was born and has stayed sober since.", minAge: 24),
        B(text: "Was homeless for most of last year and now lives in transitional housing.", minAge: 20),
        B(text: "Earned a GED in prison and an associate degree after release.", minAge: 26),
        B(text: "Was a high school dropout who went back and graduated at twenty-five.", minAge: 26),
        B(text: "Survived a mass shooting at a Charlotte nightclub in 2019.", minAge: 25),
        B(text: "Is a member of a recovery group for people who lost children to overdose.", minAge: 40),
        B(text: "Was a promising college football player until a knee injury.", minAge: 22)
    ]

    // MARK: Later life

    private static let laterLife: [BackgroundLine] = [
        B(text: "Has lived on the same street in {HOOD} for thirty-five years.", minAge: 50),
        B(text: "Retired early after a heart attack at fifty-two.", minAge: 54),
        B(text: "Has seven grandchildren and keeps most of them after school.", minAge: 50),
        B(text: "Was a respected high school shop teacher for twenty years before resigning.", minAge: 48, adult: true),
        B(text: "Recently lost a pension when a former employer went bankrupt.", minAge: 55),
        B(text: "Served two terms on the {HOOD} town board.", minAge: 45),
        B(text: "Ran a successful hardware store for thirty years before selling it.", minAge: 55),
        B(text: "Has been a Sunday school teacher for twenty-five years.", minAge: 45),
        B(text: "Is a widow or widower for the second time.", minAge: 55),
        B(text: "Started using opioids after a hip replacement at sixty.", minAge: 61),
        B(text: "Has cared for a disabled adult child for over thirty years.", minAge: 52),
        B(text: "Was an assistant principal in another county until retiring.", minAge: 56),
        B(text: "Moved to {HOOD} to retire after a career in Baltimore.", minAge: 60),
        B(text: "Is a longtime member of the county's Veterans of Foreign Wars post.", minAge: 50),
        B(text: "Has volunteered at the hospital gift shop for fifteen years.", minAge: 55)
    ]

    /// A background that fits the person, avoiding any already given to someone else in this career.
    static func pick(age: Int, occupation: String, used: Set<String>, towns: [String], rng: inout SeededRNG) -> String {
        let lower = occupation.lowercasedPhrase
        let inSchool = lower.hasPrefix("high school") || lower.contains("student") || lower.hasPrefix("college ")
        let fits = all.filter { line in
            guard age >= line.minAge else { return false }
            if inSchool && line.adult { return false }
            if lower.hasPrefix("high school") && line.text.contains("finish high school") { return false }
            if lower.contains("retired") && line.text.contains("currently") { return false }
            return true
        }
        // A line counts as used when someone already has it, in any town.
        func taken(_ line: BackgroundLine) -> Bool {
            guard line.text.contains("{HOOD}") else { return used.contains(line.text) }
            return towns.contains { used.contains(line.text.replacingOccurrences(of: "{HOOD}", with: $0)) }
        }
        let fresh = fits.filter { !taken($0) }
        let pool = fresh.isEmpty ? fits : fresh
        return rng.pick(pool.isEmpty ? all : pool).text
    }
}
