import Foundation

enum Gender { case male, female

    var label: String { self == .female ? "Female" : "Male" }
    var he: String { self == .female ? "she" : "he" }
    var him: String { self == .female ? "her" : "him" }
    var his: String { self == .female ? "her" : "his" }
    var hers: String { self == .female ? "hers" : "his" }
    var himself: String { self == .female ? "herself" : "himself" }

    /// Pronoun tokens for a person whose name token is `key`: {D.he}, {D.He}, {D.him}, {D.his}, {D.His}, {D.hers}, {D.himself}.
    func tokens(for key: String) -> [String: String] {
        ["\(key).he": he, "\(key).He": he.capitalizedFirst, "\(key).him": him, "\(key).his": his,
         "\(key).His": his.capitalizedFirst, "\(key).hers": hers, "\(key).himself": himself]
    }
}

enum NameBank {
    static let firstNames = [
        "Marcus", "Elena", "Jamal", "Priya", "Tyler", "Rosa", "Darnell", "Mei", "Connor", "Aaliyah",
        "Diego", "Hannah", "Kwame", "Sofia", "Brandon", "Yasmin", "Luis", "Grace", "Andre", "Nadia",
        "Wesley", "Fatima", "Cody", "Imani", "Victor", "Leah", "Tomás", "Brooke", "Malik", "Ingrid",
        "Raymond", "Keisha", "Hiroshi", "Molly", "Desmond", "Carmen", "Austin", "Zara", "Nikolai", "Tamika",
        "Gavin", "Lucia", "Omar", "Erin", "Ellis", "Jordan", "Avery", "Riley", "Quinn", "Sam",
        "Dakota", "Noor", "Pedro", "Allison", "Terrence", "Bao", "Shawn", "Renee", "Arjun", "Colleen",
        "Isaiah", "Valentina", "Dmitri", "Maya", "Curtis", "Esperanza", "Frank", "Delilah", "Kenji", "Shannon",
        "Abigail", "Adrian", "Alonzo", "Amara", "Ambrose", "Anika", "Antoine", "Ariel", "Arlo", "Ashton",
        "Beatrice", "Benito", "Bethany", "Bianca", "Blake", "Bridget", "Bryce", "Caleb", "Camille", "Carlos",
        "Cassandra", "Cecil", "Celeste", "Chandler", "Charlene", "Chester", "Chiara", "Clayton", "Cleo", "Corinne",
        "Dalia", "Damon", "Dana", "Daphne", "Darius", "Deandre", "Denise", "Devon", "Dolores", "Dominic",
        "Donovan", "Dorothy", "Earl", "Ebony", "Eduardo", "Eleanor", "Elijah", "Eloise", "Emeka", "Emmett",
        "Enrique", "Esther", "Ezra", "Felicia", "Fernando", "Fiona", "Floyd", "Gabriel", "Gemma", "Gilbert",
        "Gloria", "Gordon", "Gwen", "Harold", "Harriet", "Hector", "Hollis", "Hugo", "Irene", "Ivan",
        "Jacinta", "Jada", "Jalen", "Janelle", "Jasper", "Javier", "Jerome", "Jillian", "Joaquin", "Josephine",
        "Julius", "Kai", "Kara", "Keith", "Kendra", "Kiara", "Kofi", "Lamar", "Lana", "Latoya",
        "Lawrence", "Leon", "Leonora", "Lionel", "Lorena", "Lucas", "Lydia", "Mabel", "Mason", "Matteo",
        "Maurice", "Mavis", "Miguel", "Mira", "Monique", "Nathaniel", "Nell", "Nolan", "Ophelia", "Orlando",
        "Otis", "Paloma", "Patrice", "Paulette", "Percy", "Phoebe", "Porter", "Rafael", "Ramona", "Reggie",
        "Rhiannon", "Roderick", "Rowan", "Ruby", "Rufus", "Sabrina", "Santiago", "Savannah", "Selena", "Silas",
        "Simone", "Solomon", "Stella", "Sterling", "Tabitha", "Tariq", "Teresa", "Thaddeus", "Tobias", "Trina",
        "Ulysses", "Vanessa", "Vernon", "Viola", "Wallace", "Wanda", "Xavier", "Yolanda", "Yusuf", "Zachary",
        "Zelda", "Aditya", "Ayesha", "Chidi", "Dariela", "Emre", "Farah", "Gideon", "Hamza", "Ines",
        "Jovan", "Kalani", "Leilani", "Magnus", "Nia", "Olamide", "Pilar", "Rashida", "Soren", "Thandiwe",
        "Uriel", "Wren",
        "Adaeze", "Alana", "Alicia", "Alma", "Anita", "Annette", "Antoinette", "April", "Ayanna", "Bernadette",
        "Blanca", "Bonnie", "Candace", "Carla", "Carolyn", "Cecilia", "Chandra", "Charmaine", "Cheryl", "Christina",
        "Clarissa", "Constance", "Crystal", "Danielle", "Darlene", "Deborah", "Desiree", "Destiny", "Diana", "Dominique",
        "Edith", "Eileen", "Elaine", "Elisa", "Emilia", "Estelle", "Eva", "Evelyn", "Faith", "Frances",
        "Geneva", "Georgia", "Gina", "Hazel", "Heather", "Helena", "Hope", "Ivy", "Jasmine", "Jeanette",
        "Joanna", "Jocelyn", "Joy", "Juanita", "Judith", "Julia", "Kathleen", "Kimberly", "Lakisha", "Laurel",
        "Lena", "Lillian", "Lorraine", "Lucille", "Lynette", "Marisol", "Marlene", "Martina", "Maxine", "Melinda",
        "Mercedes", "Miriam", "Nadine", "Naomi", "Natasha", "Nina", "Noelle", "Octavia", "Olive", "Pamela",
        "Penelope", "Rachel", "Regina", "Rita", "Rochelle", "Rosalind", "Roxanne", "Shanice", "Sheila", "Sherry",
        "Sonia", "Sylvia", "Tanya", "Tasha", "Tiana", "Valerie", "Vera", "Veronica", "Vivian", "Whitney",
        "Winona", "Xiomara", "Yvette", "Zoe", "Bettina", "Shayla", "Marisa", "Abel", "Alvin", "Anton",
        "Archie", "Arturo", "Augustus", "Barrett", "Benedict", "Bernard", "Booker", "Boyd", "Bradley", "Byron",
        "Calvin", "Cedric", "Clarence", "Clifford", "Cornelius", "Cyrus", "Dale", "Dexter", "Edgar", "Efrain",
        "Elliott", "Ernesto", "Everett", "Fabian", "Felix", "Franklin", "Herman", "Horace", "Ignacio", "Jarvis",
        "Kendrick", "Lonnie", "Lucius", "Malcolm", "Marlon", "Milton", "Mitchell", "Montgomery", "Nelson", "Norman",
        "Quentin", "Ramon", "Reginald", "Roland", "Roscoe", "Russell", "Stanley", "Travis", "Virgil", "Warren",
        "Wendell", "Wilbur", "Winston", "Ezekiel", "Moses", "Rodney"
    ]

    static let lastNames = [
        "Whitfield", "Okafor", "Ramirez", "Chen", "Kowalski", "Washington", "Nguyen", "O'Brien", "Patel", "Holloway",
        "Delgado", "Brennan", "Abernathy", "Kim", "Moreau", "Jefferson", "Castillo", "Lindqvist", "Haddad", "Mercer",
        "Thornton", "Alvarez", "Fitzgerald", "Osei", "Bianchi", "Calloway", "Sato", "Reyes", "Gallagher", "Mbeki",
        "Duquesne", "Hargrove", "Novak", "Pemberton", "Salazar", "Vance", "Achterberg", "Bishop", "Crowley", "Dorsey",
        "Esposito", "Fairbanks", "Greer", "Huxley", "Ibarra", "Jansen", "Kincaid", "Lockwood", "Montoya", "Nakamura",
        "Ortega", "Prescott", "Quintero", "Rhodes", "Szabo", "Tran", "Underwood", "Varga", "Winslow", "Yilmaz",
        "Zamora", "Ashby", "Baptiste", "Coleridge", "Dunmore", "Everly", "Farouk", "Goldberg", "Hayashi", "Ivanova",
        "Acosta", "Adeyemi", "Aldridge", "Ambrose", "Arceneaux", "Atwater", "Bachman", "Baird", "Barksdale", "Beaumont",
        "Bellamy", "Benavides", "Blackwell", "Boateng", "Bolton", "Bramlett", "Breedlove", "Brinkley", "Buchanan", "Burkhart",
        "Cabrera", "Calderon", "Carmichael", "Castellanos", "Chambers", "Chavis", "Coker", "Colvin", "Cortez", "Crenshaw",
        "Cruz", "Dalton", "Daugherty", "Deans", "Devereaux", "Dixon", "Dominguez", "Draper", "Dunbar", "Eldridge",
        "Ellington", "Emerson", "Espinoza", "Faircloth", "Farrow", "Ferrell", "Figueroa", "Flanagan", "Fontaine", "Gaines",
        "Galindo", "Garrison", "Gentry", "Godwin", "Granger", "Guerrero", "Hadley", "Hamilton", "Hardison", "Hatcher",
        "Hawkins", "Herrera", "Hines", "Holcomb", "Honeycutt", "Horne", "Ingram", "Ivey", "Jacobs", "Jernigan",
        "Juarez", "Kaminski", "Keller", "Kendrick", "Knox", "Lambert", "Langston", "Larkin", "Ledbetter", "Locklear",
        "Lowery", "Lucero", "Lyles", "Macias", "Maddox", "Mangum", "Marsh", "Massey", "McAllister", "McCrory",
        "McLeod", "Medina", "Merritt", "Monroe", "Moss", "Murchison", "Nash", "Navarro", "Norwood", "Oakley",
        "Ochoa", "Oxendine", "Pace", "Padilla", "Parrish", "Peebles", "Pennington", "Petrov", "Pinckney", "Pope",
        "Pruitt", "Quarles", "Ragland", "Rainey", "Ransom", "Redd", "Renfrow", "Rios", "Robeson", "Rollins",
        "Sampson", "Sauls", "Sellers", "Shepherd", "Silva", "Simmons", "Singletary", "Slade", "Spivey", "Stallings",
        "Strickland", "Suggs", "Swinson", "Talley", "Tate", "Teague", "Toledo", "Townsend", "Tyndall", "Upchurch",
        "Valdez", "Vick", "Wadsworth", "Walston", "Warrick", "Weatherspoon", "Whitley", "Wilder", "Womack", "Woodard",
        "Wyatt", "Yancey", "Yates", "Zimmerman", "Achebe", "Bergstrom", "Cavanaugh", "Dimitriou", "Eklund", "Ferreira",
        "Grabowski", "Hashemi", "Iwasaki", "Jablonski", "Kaur", "Lindgren", "Mahmoud", "Nwosu", "Oyelaran", "Papadopoulos",
        "Rasmussen", "Sorensen", "Takahashi", "Uchenna", "Volkov", "Wojcik", "Xiong", "Zielinski",
        "Ainsworth", "Ammons", "Arrington", "Atkinson", "Babcock", "Barefoot", "Batts", "Beasley", "Bledsoe", "Boykin",
        "Brantley", "Braswell", "Caldwell", "Canady", "Carraway", "Coble", "Cogdell", "Corbett",
        "Crumpler", "Culbreth", "Daughtry", "Deese", "Dudley", "Eason", "Edmondson", "Ellerbe", "Estrada", "Fennell",
        "Finch", "Fulcher", "Futrell", "Gaskins", "Grady", "Grantham", "Gurganus", "Hales", "Herring", "Hinson",
        "Holloman", "Hux", "Ipock", "Joyner", "Kearney", "Kornegay", "Langley", "Lassiter", "Lucas",
        "Mabry", "Matthis", "McKoy", "McLamb", "McNeill", "Medlin", "Melvin", "Mobley", "Moye", "Mumford",
        "Nobles", "Pate", "Peele", "Pender", "Perdue", "Pittman", "Purvis", "Quinlan", "Ragsdale", "Raynor",
        "Revels", "Rouse", "Sasser", "Satterfield", "Scarborough", "Skinner", "Smallwood", "Stancil", "Sutton",
        "Tew", "Thigpen", "Tillery", "Vann", "Varner", "Weathers", "Wiggins", "Worley", "Yarborough",
        "Aguilar", "Cardenas", "Escobar", "Mendoza", "Pacheco", "Serrano", "Trujillo", "Villanueva", "Afolabi", "Mensah",
        "Pham", "Hoang", "Park", "Choi", "Shah", "Desai", "Mehta", "Iyer", "Huang", "Lin",
        "Zhou", "Khoury", "Nasser", "Rahman", "Siddiqui", "Olsen", "Donnelly", "Keane", "Kavanagh", "Thibodeaux",
        "Boudreaux", "Fontenot", "Duplantis",
        "Alston", "Bagwell", "Ballard", "Barnhill", "Beaman", "Blalock", "Bowden", "Britt", "Bullard", "Burroughs",
        "Byrd", "Cannady", "Carver", "Causey", "Chadwick", "Chestnut", "Clodfelter", "Cooke", "Crisp", "Cuthbertson",
        "Dail", "Draughon", "Edgerton", "Etheridge", "Everhart", "Faison", "Farrior", "Fogleman", "Fountain",
        "Frye", "Gaddy", "Gainey", "Garriss", "Gatling", "Gibbs", "Gilchrist", "Goforth", "Guthrie", "Hailey",
        "Hamlet", "Harrell", "Hedgepeth", "Hollowell", "Holt", "Hoyle", "Jarman", "Jessup", "Kinlaw", "Koonce",
        "Lanier", "Lockamy", "Lytle", "Manning", "Massengill", "Maynard", "Mizelle", "Mozingo", "Overby",
        "Pegram", "Pilkington", "Poindexter", "Pridgen", "Rascoe", "Respass", "Shearin", "Speight",
        "Sumner", "Swindell", "Teachey", "Tolson", "Truitt", "Uzzell", "Waddell", "Whaley", "Winstead", "Wooten",
        "Yount", "Abiodun", "Banerjee", "Gutierrez", "Ishikawa", "Jankowski", "Laszlo", "Rosario", "Sandoval", "Ueda",
        "Vasquez", "Watanabe"
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

    /// A background line that fits the person's age and situation.
    static func background(age: Int, occupation: String, rng: inout SeededRNG) -> String {
        let lower = occupation.lowercasedPhrase
        let inHighSchool = lower.contains("high school")
        let inCollege = lower.contains("student") || lower.contains("freshman")
        let fits = backgrounds.filter { line in
            if line.contains("finish high school") { return !inHighSchool }
            if line.contains("losing a job") { return age >= 23 && !inHighSchool && !inCollege }
            if line.contains("eleven years") { return age >= 30 }
            if line.contains("Dropped out of community college") { return age >= 20 && !inCollege && !inHighSchool }
            if line.contains("Navy") { return age >= 24 && !inHighSchool && !inCollege }
            if line.contains("Coaches") { return age >= 22 }
            if line.contains("foster care from age 9 to 18") { return age >= 18 }
            return true
        }
        return rng.pick(fits.isEmpty ? backgrounds : fits)
    }

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

    static let femaleFirstNames: Set<String> = ["Elena", "Priya", "Rosa", "Mei", "Aaliyah", "Hannah", "Sofia", "Yasmin", "Grace", "Nadia", "Fatima", "Imani", "Leah", "Brooke", "Ingrid", "Keisha", "Molly", "Carmen", "Zara", "Tamika", "Lucia", "Erin", "Avery", "Riley", "Quinn", "Dakota", "Noor", "Allison", "Renee", "Colleen", "Valentina", "Maya", "Esperanza", "Delilah", "Shannon", "Abigail", "Amara", "Anika", "Ariel", "Beatrice", "Bethany", "Bianca", "Bridget", "Camille", "Cassandra", "Celeste", "Charlene", "Chiara", "Cleo", "Corinne", "Dalia", "Dana", "Daphne", "Denise", "Dolores", "Dorothy", "Ebony", "Eleanor", "Eloise", "Esther", "Felicia", "Fiona", "Gemma", "Gloria", "Gwen", "Harriet", "Irene", "Jacinta", "Jada", "Janelle", "Jillian", "Josephine", "Kara", "Kendra", "Kiara", "Lana", "Latoya", "Leonora", "Lorena", "Lydia", "Mabel", "Mavis", "Mira", "Monique", "Nell", "Ophelia", "Paloma", "Patrice", "Paulette", "Phoebe", "Ramona", "Rhiannon", "Ruby", "Sabrina", "Savannah", "Selena", "Simone", "Stella", "Tabitha", "Teresa", "Trina", "Vanessa", "Viola", "Wanda", "Yolanda", "Zelda", "Ayesha", "Dariela", "Farah", "Ines", "Kalani", "Leilani", "Nia", "Pilar", "Rashida", "Thandiwe", "Wren", "Adaeze", "Alana", "Alicia", "Alma", "Anita", "Annette", "Antoinette", "April", "Ayanna", "Bernadette", "Blanca", "Bonnie", "Candace", "Carla", "Carolyn", "Cecilia", "Chandra", "Charmaine", "Cheryl", "Christina", "Clarissa", "Constance", "Crystal", "Danielle", "Darlene", "Deborah", "Desiree", "Destiny", "Diana", "Dominique", "Edith", "Eileen", "Elaine", "Elisa", "Emilia", "Estelle", "Eva", "Evelyn", "Faith", "Frances", "Geneva", "Georgia", "Gina", "Hazel", "Heather", "Helena", "Hope", "Ivy", "Jasmine", "Jeanette", "Joanna", "Jocelyn", "Joy", "Juanita", "Judith", "Julia", "Kathleen", "Kimberly", "Lakisha", "Laurel", "Lena", "Lillian", "Lorraine", "Lucille", "Lynette", "Marisol", "Marlene", "Martina", "Maxine", "Melinda", "Mercedes", "Miriam", "Nadine", "Naomi", "Natasha", "Nina", "Noelle", "Octavia", "Olive", "Pamela", "Penelope", "Rachel", "Regina", "Rita", "Rochelle", "Rosalind", "Roxanne", "Shanice", "Sheila", "Sherry", "Sonia", "Sylvia", "Tanya", "Tasha", "Tiana", "Valerie", "Vera", "Veronica", "Vivian", "Whitney", "Winona", "Xiomara", "Yvette", "Zoe", "Bettina", "Shayla", "Marisa"]

    static func gender(of fullName: String) -> Gender {
        femaleFirstNames.contains(fullName.components(separatedBy: " ").first ?? "") ? .female : .male
    }

    static func person(using rng: inout SeededRNG, excluding used: inout Set<String>, gender: Gender?) -> String {
        guard let gender else { return person(using: &rng, excluding: &used) }
        for _ in 0..<60 {
            var trial = used
            let name = person(using: &rng, excluding: &trial)
            if self.gender(of: name) == gender { used = trial; return name }
        }
        return person(using: &rng, excluding: &used)
    }

    /// Surnames that also name places in the county, so no one shares a name with a street, town, or county.
    static let placeWords: Set<String> = {
        let places = streets + ["Port Hollis", "Wexley", "Cane Creek", "Dunmore Mills", "Bayard", "Hollis", "Robeson", "Riverbend", "Harbor Point", "Cedar Hill"]
        return Set(places.flatMap { $0.components(separatedBy: " ") })
    }()
    static let personSurnames = lastNames.filter { !placeWords.contains($0) }

    static func person(using rng: inout SeededRNG, excluding used: inout Set<String>) -> String {
        for _ in 0..<40 {
            let name = "\(rng.pick(firstNames)) \(rng.pick(personSurnames))"
            let last = name.components(separatedBy: " ").last ?? name
            if !used.contains(name) && !used.contains(last) {
                used.insert(name)
                used.insert(last)
                return name
            }
        }
        return "\(rng.pick(firstNames)) \(rng.pick(personSurnames))"
    }
}
