CREATE TABLE IF NOT EXISTS locales (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    language VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS names (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    locale_id INTEGER NOT NULL REFERENCES locales(id),
    name VARCHAR(100) NOT NULL,
    name_type VARCHAR(10) NOT NULL
        CHECK (name_type IN ('first', 'middle', 'last', 'title')),
    gender VARCHAR(20)
);

CREATE INDEX IF NOT EXISTS idx_names_locale_type
    ON names(locale_id, name_type);

CREATE TABLE IF NOT EXISTS address (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    locale_id INTEGER NOT NULL REFERENCES locales(id),
    component VARCHAR(100) NOT NULL,
    component_type VARCHAR(20) NOT NULL
        CHECK (component_type IN ('street_name', 'street_type', 'building_number'))
);

CREATE INDEX IF NOT EXISTS idx_address_locale_type
    ON address(locale_id, component_type);

CREATE TABLE IF NOT EXISTS email_domains (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    locale_id INTEGER NOT NULL REFERENCES locales(id),
    domain VARCHAR(100) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_email_domains_locale
    ON email_domains(locale_id);

CREATE TABLE IF NOT EXISTS eye_colors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    locale_id INTEGER NOT NULL REFERENCES locales(id),
    color VARCHAR(30) NOT NULL,
    selection_weight INTEGER NOT NULL DEFAULT 1
        CHECK (selection_weight > 0),
    UNIQUE (locale_id, color)
);