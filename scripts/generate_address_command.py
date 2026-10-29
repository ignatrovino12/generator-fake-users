street_names = {
    "en-US": [
        "Oak", "Maple", "Pine", "Cedar", "Elm",
        "Willow", "Cherry", "Birch", "Ash", "Walnut",
        "Hill", "Lake", "River", "Forest", "Meadow",
        "Park", "Garden", "Highland", "Sunset", "Riverside",
        "Washington", "Jefferson", "Lincoln", "Madison", "Franklin",
        "Adams", "Jackson", "Monroe", "Wilson", "Roosevelt",
        "Church", "School", "Mill", "Spring", "Bridge",
        "Main", "Market", "Center", "Union", "College",
        "Broad", "Grand", "High", "North", "South",
        "East", "West", "Hillcrest", "Fairview", "Greenwood",
        "Brookside", "Woodland", "Highland Park", "Pleasant Valley",
        "Deerfield", "Fox Run", "Meadowbrook", "Stonebridge",
        "Springfield", "Canyon", "Valley", "Summit", "Orchard",
        "Magnolia", "Poplar", "Sycamore", "Chestnut", "Dogwood",
        "Hickory", "Laurel", "Aspen", "Hawthorne", "Juniper",
        "Redwood", "Silver Lake", "Bluebird", "Eagle", "Liberty",
        "Victory", "Veterans", "Memorial", "Sunrise", "Sunflower",
    ],

    "de-DE": [
        "Berliner", "Haupt", "Bahnhof", "Kirch", "Schul",
        "Garten", "Wald", "Berg", "Tal", "Bach",
        "Brunnen", "Linden", "Birken", "Eichen", "Buchen",
        "Rosen", "Blumen", "Friedrich", "Kaiser", "Goethe",
        "Schiller", "Mozart", "Beethoven", "Bismarck", "Humboldt",
        "Schwarzwald", "Rosenberg", "Sonnen", "Mond", "Stern",
        "Wiesen", "Feld", "Wiesenweg", "Mühlen", "Dorf",
        "Markt", "Rathaus", "Schloss", "Brücken", "Ufer",
        "Wasser", "Quellen", "Felsen", "Birkenwald", "Tannen",
        "Fichten", "Ahorn", "Kastanien", "Ulmen", "Eschen",
        "Heide", "Kiefern", "Edelweiß", "Alpen", "Bären",
        "Finken", "Lerchen", "Adler", "Tauben", "Falken",
        "Neustadt", "Altstadt", "Friedens", "Freiheits", "Einheits",
        "Industrie", "Ring", "Park", "Sport", "Wiesenau",
        "Sonnenberg", "Blumenau", "Bergmann", "Schubert", "Schumann",
        "Lessing", "Kant", "Dürer", "Bach", "Heine",
        "Lessing", "Wagner", "Schopenhauer", "Mörike", "Fontane",
    ],
}

street_types = {
    "en-US": [
        "Street", "Avenue", "Road", "Boulevard", "Drive",
        "Lane", "Court", "Place", "Way", "Circle",
        "Terrace", "Parkway", "Trail", "Highway",
    ],

    "de-DE": [
        "Straße", "Strasse", "Weg", "Allee", "Platz",
        "Gasse", "Ring", "Damm", "Ufer", "Chaussee",
    ],
}

def sql_escape(value):
    return value.replace("'", "''")

rows = []

for locale_code, names in street_names.items():
    for name in names:
        rows.append((locale_code, name, "street_name"))

for locale_code, types in street_types.items():
    for street_type in types:
        rows.append((locale_code, street_type, "street_type"))

    print("""
INSERT INTO address (locale_id, component, component_type)
SELECT l.id, v.component, v.component_type
FROM locales l
JOIN (
    VALUES
""".strip() + "\n")

    for i, (locale_code, component, component_type) in enumerate(rows):
        comma = "," if i < len(rows) - 1 else ""
        print(f"('{locale_code}','{sql_escape(component)}','{component_type}'){comma}")

    print("""
) AS v(locale_code, component, component_type)
    ON TRUE
JOIN locales l2 ON l2.code = v.locale_code
WHERE l.id = l2.id;
""")
