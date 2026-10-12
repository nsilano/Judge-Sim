import Foundation

enum NameBank {
    static let firstNames = [
        "Marcus", "Elena", "Jamal", "Priya", "Tyler", "Rosa", "Darnell", "Mei", "Connor", "Aaliyah",
        "Diego", "Hannah", "Kwame", "Sofia", "Brandon", "Yasmin", "Luis", "Grace", "Andre", "Nadia",
        "Wesley", "Fatima", "Cody", "Imani", "Victor", "Leah", "Tomás", "Brooke", "Malik", "Ingrid",
        "Raymond", "Keisha", "Hiroshi", "Molly", "Desmond", "Carmen", "Austin", "Zara", "Nikolai", "Tamika",
        "Gavin", "Lucia", "Omar", "Erin", "Ellis", "Jordan", "Avery", "Riley", "Quinn", "Sam",
        "Dakota", "Noor", "Pedro", "Allison", "Terrence", "Bao", "Shawn", "Renee", "Arjun", "Colleen",
        "Isaiah", "Valentina", "Dmitri", "Maya", "Curtis", "Esperanza", "Frank", "Delilah", "Kenji", "Shannon"
    ]

    static let lastNames = [
        "Whitfield", "Okafor", "Ramirez", "Chen", "Kowalski", "Washington", "Nguyen", "O'Brien", "Patel", "Holloway",
        "Delgado", "Brennan", "Abernathy", "Kim", "Moreau", "Jefferson", "Castillo", "Lindqvist", "Haddad", "Mercer",
        "Thornton", "Alvarez", "Fitzgerald", "Osei", "Bianchi", "Calloway", "Sato", "Reyes", "Gallagher", "Mbeki",
        "Duquesne", "Hargrove", "Novak", "Pemberton", "Salazar", "Vance", "Achterberg", "Bishop", "Crowley", "Dorsey",
        "Esposito", "Fairbanks", "Greer", "Huxley", "Ibarra", "Jansen", "Kincaid", "Lockwood", "Montoya", "Nakamura",
        "Ortega", "Prescott", "Quintero", "Rhodes", "Szabo", "Tran", "Underwood", "Varga", "Winslow", "Yilmaz",
        "Zamora", "Ashby", "Baptiste", "Coleridge", "Dunmore", "Everly", "Farouk", "Goldberg", "Hayashi", "Ivanova"
    ]

    static let streets = [
        "Harbor Street", "Pell Avenue", "Kestrel Road", "Fifth Street", "Marlowe Boulevard", "Old Mill Lane",
        "Juniper Court", "Canal Street", "Ridgeview Drive", "Saint Agnes Way", "Brickyard Road", "Lantern Row"
    ]

    static let times = [
        "11:40 p.m.", "2:15 a.m.", "6:05 p.m.", "9:30 p.m.", "3:50 a.m.", "12:20 a.m.", "7:45 p.m.", "1:10 a.m."
    ]

    static let dates = [
        "March 3", "April 19", "June 7", "July 22", "August 30", "September 14", "October 2", "November 26",
        "December 11", "January 18", "February 9", "May 25"
    ]

    static let neighborhoods = [
        "Eastgate", "the Flats", "Hollis Heights", "Riverbend", "the Iron District", "Southport", "Cedar Hill", "Marrow Park"
    ]

    static let occupations = [
        "warehouse worker", "nursing assistant", "rideshare driver", "line cook", "unemployed", "college student",
        "electrician's apprentice", "retail manager", "barber", "delivery driver", "software tester", "home health aide",
        "construction laborer", "dental hygienist", "bartender", "school bus driver"
    ]

    static let backgrounds = [
        "Grew up in {HOOD}; the first in the family to finish high school.",
        "Moved to Port Hollis four years ago after losing a job upstate.",
        "Raised by a grandmother after both parents struggled with addiction.",
        "Volunteers weekends at a church food pantry, according to letters filed with the court.",
        "Has lived in the same apartment in {HOOD} for eleven years.",
        "Dropped out of community college to care for a sick parent.",
        "Served four years in the Navy; honorably discharged.",
        "Has a documented history of depression and anxiety.",
        "Coaches a youth soccer team in {HOOD}.",
        "Was in foster care from age 9 to 18."
    ]

    static let priorOffenses = [
        "Petty Theft (misdemeanor), 6 months probation",
        "Possession of a Controlled Substance, completed Drug Court",
        "Disorderly Conduct, $300 fine",
        "DUI, 3 years probation",
        "Simple Assault, 30 days jail",
        "Criminal Mischief, restitution ordered",
        "Receiving Stolen Property (felony), 14 months prison",
        "Burglary (felony), 3 years prison",
        "Resisting Arrest, 10 days jail",
        "Grand Theft (felony), 2 years probation"
    ]

    static func person(using rng: inout SeededRNG, excluding used: inout Set<String>) -> String {
        for _ in 0..<40 {
            let name = "\(rng.pick(firstNames)) \(rng.pick(lastNames))"
            let last = name.components(separatedBy: " ").last ?? name
            if !used.contains(name) && !used.contains(last) {
                used.insert(name)
                used.insert(last)
                return name
            }
        }
        return "\(rng.pick(firstNames)) \(rng.pick(lastNames))"
    }
}
