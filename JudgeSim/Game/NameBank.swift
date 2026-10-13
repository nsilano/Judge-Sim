import Foundation

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
        "Uriel", "Wren"
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
        "Rasmussen", "Sorensen", "Takahashi", "Uchenna", "Volkov", "Wojcik", "Xiong", "Zielinski"
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
