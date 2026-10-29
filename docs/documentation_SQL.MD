# SQL Fake User Generator - Function Reference

## 1. Overview

Brief description of the SQL 'faker' generator for user data based on supported locales.

## 2. Functions for randomness and distributions

### 1) `random_deterministic`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.

**Role**

Generates a deterministic pseudo-random value between 0 and 1 using MD5 hashing. Identical inputs always produce the same output, allowing reproducible data generation.

### 2) `random_int`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.
- `min`: Minimum allowed integer.
- `max`: Maximum allowed integer.

**Role**

Generates a deterministic random integer within the range `[min, max]`. It uses `random_deterministic` to generate a value between 0 and 1, then maps it to the specified integer range.

### 3) `random_normal_distribution`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.

**Role**

Generates a deterministic value following a standard normal distribution using the Box-Muller transform. It uses `random_deterministic` to generate 2 deterministic pseudo-random values.

## 3. Functions for data generation

### 1) `pick_name`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.
- `p_name_type`: Type of name to select: `first`, `middle`, `last`, or `title`.

**Role**

Selects a name of the specified type from the `names` table for the chosen locale. The selection use `random_int` to choose an entry from the available names.

### 2) `generate_name`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates a full name by combining a first name and a last name and by probability it can add a middle name and title. It uses `pick_name` to select locale-specific values.

### 3) `pick_address_component`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.
- `p_component_type`: Type of address component to select: `street_name`, `street_type`, or `building_number`.

**Role**

Selects an address component of the specified type from the `address` table for the requested locale. It uses `random_int` to choose an entry.

### 4) `generate_address`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates a formatted address by selecting street names, street types, and building numbers using `pick_address_component` and are combined based on locale specific formats.

### 5) `pick_email_domain`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.

**Role**

Selects an email domain from the `email_domains` table for the picked locale. It uses `random_int` to select an entry.

### 6) `generate_email`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates an email address by combining a first name and last name from `pick_name` with a domain selected using `pick_email_domain`. The username is converted to lowercase, and certain German characters are normalized for compatibility.

### 7) `pick_eye_color`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.
- `field_index`: Identifier of the generated field.

**Role**

Selects an eye color from the `eye_colors` table for the requested locale, using pre-configured selection weights. Colors with higher weights have a greater probability of being selected.

### 8) `generate_eye_color`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates an eye color by calling `pick_eye_color`.

### 9) `generate_phone`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates a phone number formatted according to the selected locale. The number is constructed using 'random_int' values and locale-specific formatting rules.

### 10) `generate_height`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates a height in centimeters using `random_normal_distribution` with a mean of 170 cm and a standard deviation of 10 cm. The result is limited to the range of 140-210 cm.

### 11) `generate_bmi`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates a BMI value using `random_normal_distribution` with a mean of 24 and a standard deviation of 6. The result is limited to the range of 16-40.

### 12) `generate_weight`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Calculates weight in kilograms using the generated BMI and height, applying the specific formula  of `weight = BMI * (height)^2`, where height is expressed in meters.

### 13) `generate_coordinates`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates latitude and longitude coordinates distributed uniformly over a sphere. Latitude is calculated using the inverse sine transformation, while longitude is generated uniformly between -180 and 180 degrees.

## 4. Functions for user generation

### 1) `generate_user`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `user_index`: User index.

**Role**

Generates a complete user record by calling all the individual functions used for generating each field.

### 2) `generate_users_batch`

**Arguments**
- `seed`: Seed used for reproducibility.
- `locale`: Locale code.
- `batch_index`: Batch identifier.
- `batch_size`: Number of users to generate.
- `start_user_index`: Starting user index.

**Role**

Generates a batch of users by calling `generate_user` for each user index in the specified range. 