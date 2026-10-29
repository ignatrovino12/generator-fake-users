CREATE OR REPLACE FUNCTION random_deterministic(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER
)
RETURNS DOUBLE PRECISION
LANGUAGE SQL
IMMUTABLE
STRICT
AS $function$
    SELECT (
        (
            ('x' || SUBSTRING(
                MD5(
                    CONCAT_WS('|', seed, locale, batch_index, user_index, field_index)
                ),1, 8
            ))::BIT(32)::BIGINT
        ) / POWER(2, 32)
    )::DOUBLE PRECISION;
$function$;

CREATE OR REPLACE FUNCTION random_int(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER,
    min INTEGER,
    max INTEGER
)
RETURNS INTEGER
LANGUAGE SQL
IMMUTABLE
STRICT
AS $function$
    SELECT min + FLOOR(
        random_deterministic( seed, locale, batch_index, user_index,field_index) * (max - min + 1)
    )::INTEGER;
$function$;

CREATE OR REPLACE FUNCTION pick_name(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER,
    p_name_type TEXT
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
AS $function$
DECLARE
    selected_locale_id INTEGER;
    name_count INTEGER;
    name_offset INTEGER;
    v_name TEXT;
BEGIN
    -- Find the locale.
    SELECT id
    INTO selected_locale_id 
    FROM locales
    WHERE code = locale;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown locale: %', locale;
    END IF;

    SELECT COUNT(*)::INTEGER
    INTO name_count
    FROM names
    WHERE locale_id = selected_locale_id
      AND name_type = p_name_type;

    IF name_count = 0 THEN
        RAISE EXCEPTION
            'No names found for locale % and type %',
            locale, p_name_type;
    END IF;

    name_offset := random_int(seed, locale, batch_index, user_index, field_index, 0, name_count - 1);

    SELECT name
    INTO v_name
    FROM names
    WHERE locale_id = selected_locale_id
      AND name_type = p_name_type
    ORDER BY id
    OFFSET name_offset
    LIMIT 1;

    RETURN v_name;
END;
$function$;

CREATE OR REPLACE FUNCTION generate_name(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
AS $function$
DECLARE
    first_name TEXT;
    middle_name TEXT;
    last_name TEXT;
    title TEXT;
    include_middle BOOLEAN;
    include_title BOOLEAN;
BEGIN
    first_name := pick_name( seed, locale, batch_index, user_index, 1, 'first');

    last_name := pick_name( seed, locale, batch_index, user_index, 2, 'last');

    include_middle := random_deterministic( seed, locale, batch_index, user_index, 3
    ) < 0.35;

    IF include_middle THEN
        middle_name := pick_name(seed, locale, batch_index, user_index, 4, 'middle');

        IF middle_name = first_name THEN
            middle_name := NULL;
        END IF;
    END IF;

    include_title := random_deterministic(seed, locale, batch_index, user_index, 5
    ) < 0.05;

    IF include_title THEN
        title := pick_name(seed, locale, batch_index, user_index, 6, 'title');
    END IF;

    RETURN CONCAT_WS(' ', title, first_name, middle_name, last_name);
END;
$function$;

CREATE OR REPLACE FUNCTION pick_address_component(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER,
    p_component_type TEXT
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    selected_locale_id INTEGER;
    count INTEGER;
    component_offset INTEGER;
    v_component TEXT;
BEGIN
    SELECT id
    INTO selected_locale_id
    FROM locales
    WHERE code = locale;

    IF selected_locale_id IS NULL THEN
        RAISE EXCEPTION 'Unknown locale: %', locale;
    END IF;

    SELECT COUNT(*)::INTEGER
    INTO count
    FROM address
    WHERE locale_id = selected_locale_id
      AND component_type = p_component_type;

    IF count = 0 THEN
        RAISE EXCEPTION
            'No address components for locale % and type %',
            locale, p_component_type;
    END IF;

    component_offset := random_int(seed, locale, batch_index, user_index, field_index, 0, count - 1);

    SELECT a.component
    INTO v_component
    FROM address AS a
    WHERE a.locale_id = selected_locale_id
      AND a.component_type = p_component_type
    ORDER BY a.id
    OFFSET component_offset
    LIMIT 1;

    RETURN v_component;
END;
$function$;

CREATE OR REPLACE FUNCTION generate_address(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    street_name TEXT;
    street_type TEXT;
    building_number TEXT;
BEGIN
    street_name := pick_address_component(
        seed, locale, batch_index,
        user_index, 7, 'street_name');

    street_type := pick_address_component(
        seed, locale, batch_index,
        user_index, 8, 'street_type');

    building_number := pick_address_component(
        seed, locale, batch_index,
        user_index, 9, 'building_number');

    IF locale = 'de-DE' THEN
        RETURN CONCAT(street_name, ' ', street_type, ' ', building_number);
    ELSE
        RETURN CONCAT(building_number, ' ', street_name, ' ', street_type);
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION pick_email_domain(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    selected_locale_id INTEGER;
    count INTEGER;
    email_offset INTEGER;
    v_domain TEXT;
BEGIN
    SELECT id
    INTO selected_locale_id
    FROM locales
    WHERE code = locale;

    IF selected_locale_id IS NULL THEN
        RAISE EXCEPTION 'Unknown locale: %', locale;
    END IF;

    SELECT COUNT(*)::INTEGER
    INTO count
    FROM email_domains
    WHERE locale_id = selected_locale_id;

    IF count = 0 THEN
        RAISE EXCEPTION 'No email domains for locale %', locale;
    END IF;

    email_offset := random_int(seed, locale, batch_index, user_index, field_index, 0, count - 1);

    SELECT ed.domain
    INTO v_domain
    FROM email_domains AS ed
    WHERE ed.locale_id = selected_locale_id
    ORDER BY ed.id
    OFFSET email_offset
    LIMIT 1;

    RETURN v_domain;
END;
$function$;

CREATE OR REPLACE FUNCTION generate_email(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    first_name TEXT;
    last_name TEXT;
    username TEXT;
    domain TEXT;
BEGIN

    first_name := pick_name(seed, locale, batch_index, user_index, 1, 'first');
    last_name := pick_name(seed, locale, batch_index, user_index, 2, 'last');
    username := LOWER(first_name || '.' || last_name);
    username := TRANSLATE(username,'äöüß','aous');

    domain := pick_email_domain(seed, locale, batch_index, user_index, 10);

    RETURN username || '@' || domain;
END;
$function$;

CREATE OR REPLACE FUNCTION pick_eye_color(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    selected_locale_id INTEGER;
    total_weight INTEGER;
    random_value INTEGER;
    selected_color TEXT;
BEGIN
    SELECT l.id
    INTO selected_locale_id
    FROM locales AS l
    WHERE l.code = locale;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown locale: %', locale;
    END IF;

    SELECT COALESCE(SUM(ec.selection_weight), 0)::INTEGER
    INTO total_weight
    FROM eye_colors AS ec
    WHERE ec.locale_id = selected_locale_id;

    IF total_weight = 0 THEN
        RAISE EXCEPTION 'No eye colors found for locale %', locale;
    END IF;

    random_value := random_int(
        seed, locale, batch_index, user_index,
        field_index, 1, total_weight);

    SELECT ec.color
    INTO selected_color
    FROM (
        SELECT
            color,
            SUM(selection_weight) OVER (ORDER BY id) AS cumulative_weight
        FROM eye_colors
        WHERE locale_id = selected_locale_id
    ) AS ec
    WHERE ec.cumulative_weight >= random_value
    ORDER BY ec.cumulative_weight
    LIMIT 1;

    RETURN selected_color;
END;
$function$;

CREATE OR REPLACE FUNCTION generate_eye_color(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
BEGIN
    RETURN pick_eye_color(seed, locale, batch_index, user_index, 11);
END;
$function$;

CREATE OR REPLACE FUNCTION generate_phone(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TEXT
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    area_code INTEGER;
    phone_number INTEGER;
BEGIN
    IF locale = 'en-US' THEN

        area_code := random_int(seed, locale, batch_index, user_index, 12, 200, 999);
        phone_number := random_int(seed, locale, batch_index, user_index, 21, 0, 9999999);

        RETURN '(' || area_code::TEXT || ') ' || LPAD(phone_number::TEXT, 7, '0');

    ELSIF locale = 'de-DE' THEN

        area_code := random_int(seed, locale, batch_index, user_index, 12, 10, 999);
        phone_number := random_int(seed, locale, batch_index, user_index, 21, 0, 99999999);

        RETURN '0' || area_code::TEXT || ' ' || LPAD(phone_number::TEXT, 8, '0');

    ELSE
        RAISE EXCEPTION 'Unsupported locale: %', locale;
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION random_normal_distribution(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER,
    field_index INTEGER
)
RETURNS DOUBLE PRECISION
LANGUAGE PLPGSQL
IMMUTABLE
STRICT
AS $function$
DECLARE
    first_random DOUBLE PRECISION;
    second_random DOUBLE PRECISION;
BEGIN
    first_random := GREATEST(random_deterministic(seed, locale, batch_index, user_index, field_index * 2), 1e-10);
    second_random := random_deterministic(seed, locale, batch_index, user_index, field_index * 2 + 1);

    RETURN SQRT(-2 * LN(first_random)) * COS(2 * PI() * second_random);
END;
$function$;

CREATE OR REPLACE FUNCTION generate_height(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS NUMERIC
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    height_value DOUBLE PRECISION;
BEGIN
    height_value := 170 + 10 * random_normal_distribution(seed, locale, batch_index, user_index, 13);

    RETURN ROUND( GREATEST(140, LEAST(210, height_value))::NUMERIC, 1);
END;
$function$;

CREATE OR REPLACE FUNCTION generate_bmi(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS NUMERIC
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    bmi_value DOUBLE PRECISION;
BEGIN
    bmi_value := 24 + 6 * random_normal_distribution( seed, locale, batch_index, user_index, 14);

    RETURN ROUND(GREATEST(16, LEAST(45, bmi_value))::NUMERIC, 1);
END;
$function$;

CREATE OR REPLACE FUNCTION generate_weight(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS NUMERIC
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
DECLARE
    height NUMERIC;
    bmi NUMERIC;
BEGIN
    height := generate_height(seed, locale, batch_index, user_index) / 100.0;
    bmi := generate_bmi(seed, locale, batch_index, user_index);

    RETURN ROUND(bmi * height * height, 1);
END;
$function$;

CREATE OR REPLACE FUNCTION generate_coordinates(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TABLE (
    latitude NUMERIC,
    longitude NUMERIC
)
LANGUAGE plpgsql
STABLE
STRICT
AS $function$
DECLARE
    latitude_random DOUBLE PRECISION;
    longitude_random DOUBLE PRECISION;
    latitude_value DOUBLE PRECISION;
    longitude_value DOUBLE PRECISION;
BEGIN
    latitude_random := random_deterministic(seed, locale, batch_index, user_index, 15);
    longitude_random := random_deterministic(seed, locale, batch_index, user_index, 16);

    latitude_value := DEGREES(ASIN(2 * latitude_random - 1));
    longitude_value := 360 * longitude_random - 180;

    latitude := ROUND(latitude_value::NUMERIC, 6);
    longitude := ROUND(longitude_value::NUMERIC, 6);

    RETURN NEXT;
END;
$function$;

CREATE OR REPLACE FUNCTION generate_user(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    user_index INTEGER
)
RETURNS TABLE (
    full_name TEXT,
    v_address TEXT,
    email TEXT,
    phone TEXT,
    eye_color TEXT,
    height_cm NUMERIC,
    bmi NUMERIC,
    weight_kg NUMERIC,
    latitude NUMERIC,
    longitude NUMERIC
)
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
BEGIN
    full_name := generate_name(seed, locale, batch_index, user_index);
    v_address := generate_address(seed, locale, batch_index, user_index);
    email := generate_email(seed, locale, batch_index, user_index);
    phone := generate_phone(seed, locale, batch_index, user_index);
    eye_color := generate_eye_color(seed, locale, batch_index, user_index);
    height_cm := generate_height(seed, locale, batch_index, user_index);
    bmi := generate_bmi(seed, locale, batch_index, user_index);
    weight_kg := generate_weight(seed, locale, batch_index, user_index);

    SELECT coordinates.latitude, coordinates.longitude
    INTO latitude, longitude
    FROM generate_coordinates(seed, locale, batch_index, user_index) AS coordinates;

    RETURN NEXT;
END;
$function$;

CREATE OR REPLACE FUNCTION generate_users_batch(
    seed BIGINT,
    locale TEXT,
    batch_index BIGINT,
    batch_size INTEGER,
    start_user_index INTEGER DEFAULT 0
)
RETURNS TABLE (
    full_name TEXT,
    user_address TEXT,
    email TEXT,
    phone TEXT,
    eye_color TEXT,
    height_cm NUMERIC,
    bmi NUMERIC,
    weight_kg NUMERIC,
    latitude NUMERIC,
    longitude NUMERIC
)
LANGUAGE PLPGSQL
STABLE
STRICT
AS $function$
BEGIN
    IF batch_size <= 0 THEN
        RAISE EXCEPTION 'Batch size must be positive';
    END IF;

    IF start_user_index < 0 THEN
        RAISE EXCEPTION 'Start index must be positive';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM locales AS l
        WHERE l.code = locale
    ) THEN
        RAISE EXCEPTION 'Unknown locale: %', locale;
    END IF;

    RETURN QUERY
    SELECT generated_user.*
    FROM generate_series(start_user_index, start_user_index + batch_size - 1) 
    AS users(user_index)
    CROSS JOIN LATERAL generate_user(seed, locale, batch_index, users.user_index) AS generated_user;
END;
$function$;