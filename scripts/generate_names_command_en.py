first_male = [
    "James", "John", "Robert", "Michael", "William",
    "David", "Richard", "Joseph", "Thomas", "Charles",
    "Christopher", "Daniel", "Matthew", "Anthony", "Mark",
    "Donald", "Steven", "Paul", "Andrew", "Joshua",
    "Kenneth", "Kevin", "Brian", "George", "Edward",
    "Ronald", "Timothy", "Jason", "Jeffrey", "Ryan",
    "Jacob", "Nicholas", "Eric", "Jonathan", "Stephen",
    "Larry", "Justin", "Scott", "Brandon", "Benjamin",
    "Samuel", "Alexander", "Patrick", "Jack", "Dennis",
    "Aaron", "Adam", "Nathan", "Diego", "Tony"
]

first_female = [
    "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth",
    "Barbara", "Susan", "Jessica", "Sarah", "Karen",
    "Nancy", "Lisa", "Margaret", "Betty", "Sandra",
    "Ashley", "Dorothy", "Kimberly", "Emily", "Donna",
    "Michelle", "Carol", "Amanda", "Melissa", "Deborah",
    "Stephanie", "Rebecca", "Laura", "Sharon", "Cynthia",
    "Kathleen", "Amy", "Shirley", "Angela", "Helen",
    "Anna", "Brenda", "Pamela", "Nicole", "Samantha",
    "Katherine", "Christine", "Emma", "Olivia", "Sophia",
    "Rachel", "Victoria", "Grace", "Hannah", "Natalie"
]

last_names = [
    "Smith", "Johnson", "Williams", "Brown", "Jones",
    "Miller", "Davis", "Wilson", "Anderson", "Taylor",
    "Thomas", "Moore", "Jackson", "Martin", "Lee",
    "Perez", "Thompson", "White", "Harris", "Sanchez",
    "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
    "Young", "Allen", "King", "Wright", "Scott",
    "Torres", "Nguyen", "Hill", "Flores", "Green",
    "Adams", "Nelson", "Baker", "Hall", "Rivera",
    "Campbell", "Mitchell", "Carter", "Roberts", "Gomez",
    "Phillips", "Evans", "Turner", "Diaz", "Parker",
    "Cruz", "Edwards", "Collins", "Reyes", "Stewart",
    "Morris", "Morales", "Murphy", "Cook", "Rogers",
    "Gutierrez", "Ortiz", "Morgan", "Cooper", "Peterson",
    "Bailey", "Reed", "Kelly", "Howard", "Ramos",
    "Kim", "Cox", "Ward", "Richardson", "Watson",
    "Brooks", "Chavez", "Wood", "Bennett", "Gray"
]

titles = [
    "Mr.", "Mrs.", "Ms.", "Miss", "Dr.", "Prof.", "Rev.", "Hon.", "Sir", "Dame"
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
    print(f"        ({name_sql}, {type_sql}, {gender_sql}){comma}")

print("""
) AS v(name, name_type, gender)
WHERE l.code = 'en-US';
""".strip())
