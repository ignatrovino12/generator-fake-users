first_male = [
    "Alexander", "Andreas", "Anton", "Benjamin", "Bernd",
    "Christian", "Christoph", "Daniel", "David", "Dennis",
    "Dieter", "Dirk", "Dominik", "Elias", "Emil",
    "Erik", "Ernst", "Fabian", "Felix", "Florian",
    "Frank", "Friedrich", "Gabriel", "Georg", "Gerhard",
    "Hans", "Heinrich", "Jakob", "Jan", "Jens",
    "Joachim", "Johannes", "Jonas", "Jonathan", "Josef",
    "Julian", "Julius", "Kai", "Karl", "Kevin",
    "Klaus", "Leon", "Leonard", "Liam", "Lorenz",
    "Luca", "Lukas", "Manfred", "Marcel", "Marco",
    "Mario", "Markus", "Martin", "Matthias", "Max",
    "Maximilian", "Michael", "Moritz", "Niklas", "Noah",
    "Oliver", "Oskar", "Otto", "Paul", "Peter",
    "Philipp", "Rainer", "Ralf", "Richard", "Robert",
    "Roland", "Rudolf", "Sebastian", "Simon", "Stefan",
    "Steffen", "Theodor", "Thomas", "Tim", "Tobias",
    "Uwe", "Valentin", "Victor", "Vincent", "Walter",
    "Werner", "Wilhelm", "Wolfgang", "Yannick", "Adrian",
    "Aaron", "Armin", "Bastian", "Carl", "Frederik",
    "Henrik", "Lennard", "Mats", "Till", "Leopold"
]

first_female = [
    "Anna", "Marie", "Maria", "Sophie", "Sophia",
    "Emma", "Mia", "Emilia", "Hannah", "Hanna",
    "Lena", "Lea", "Mila", "Lina", "Laura",
    "Johanna", "Clara", "Charlotte", "Amelie", "Lilly",
    "Luisa", "Luna", "Ella", "Frieda", "Ida",
    "Greta", "Mathilda", "Paula", "Martha", "Elisa",
    "Katharina", "Christina", "Julia", "Sarah", "Lisa",
    "Jennifer", "Nicole", "Sandra", "Petra", "Sabine",
    "Monika", "Claudia", "Andrea", "Susanne", "Ursula",
    "Ingrid", "Helga", "Brigitte", "Renate", "Heike"
]

last_names = [
    "Müller", "Schmidt", "Schneider", "Fischer", "Weber",
    "Meyer", "Wagner", "Becker", "Schulz", "Hoffmann",
    "Schäfer", "Koch", "Bauer", "Richter", "Klein",
    "Wolf", "Schröder", "Neumann", "Schwarz", "Zimmermann",
    "Braun", "Krüger", "Hofmann", "Hartmann", "Lange",
    "Schmitt", "Werner", "Schmitz", "Krause", "Meier",
    "Lehmann", "Schmid", "Schulze", "Maier", "Köhler",
    "Herrmann", "König", "Walter", "Mayer", "Huber",
    "Kaiser", "Fuchs", "Peters", "Lang", "Scholz",
    "Möller", "Weiß", "Jung", "Hahn", "Schubert",
    "Vogel", "Friedrich", "Keller", "Günther", "Frank",
    "Berger", "Winkler", "Roth", "Beck", "Lorenz",
    "Baumann", "Franke", "Albrecht", "Schuster", "Simon",
    "Ludwig", "Böhm", "Winter", "Kraus", "Martin",
    "Schumacher", "Krämer", "Vogt", "Stein", "Jäger",
    "Otto", "Sommer", "Groß", "Seidel", "Heinrich"
]

titles = [
    "Herr", "Frau", "Dr.", "Prof.", "Prof. Dr."
]

def sql_escape(value):
    return value.replace("'", "''")

rows = []

for name in first_male:
    rows.append((name, "first", "male"))
    rows.append((name, "middle", "male"))

for name in first_female:
    rows.append((name, "first", "female"))
    rows.append((name, "middle", "female"))

for name in last_names:
    rows.append((name, "last", None))

for title in titles:
    rows.append((title, "title", None))

print("""
INSERT INTO names (locale_id, name, name_type, gender)
SELECT l.id, v.name, v.name_type, v.gender
FROM locales l
CROSS JOIN (
    VALUES
""".strip())

for i, (name, name_type, gender) in enumerate(rows):
    name_sql = "'" + sql_escape(name) + "'"
    type_sql = "'" + name_type + "'"
    gender_sql = "NULL" if gender is None else "'" + gender + "'"

    comma = "," if i < len(rows) - 1 else ""
    print(f"({name_sql}, {type_sql}, {gender_sql}){comma}")

print("""
) AS v(name, name_type, gender)
WHERE l.code = 'de-DE';
""".strip())
