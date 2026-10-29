import os
from pathlib import Path
import sys
import time

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

import django
django.setup()
from django.db import connection

SEED = 141232
LOCALE = "en-US"
BATCH_SIZE = 100
NUMBER_OF_BATCHES = 100

def benchmark_generation():
    total_users = 0
    start_time = time.perf_counter()

    with connection.cursor() as cursor:
        for batch_index in range(NUMBER_OF_BATCHES):
            start_user_index = batch_index * BATCH_SIZE
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM generate_users_batch(%s, %s, %s, %s, %s)
                """,
                [
                    SEED,
                    LOCALE,
                    batch_index,
                    BATCH_SIZE,
                    start_user_index,
                ],
            )
            total_users += cursor.fetchone()[0]

    elapsed_time = time.perf_counter() - start_time
    users_per_second = total_users / elapsed_time if elapsed_time else 0

    print(f"Total users: {total_users:,}")
    print(f"Elapsed time: {elapsed_time:.2f} seconds")
    print(f"Generation speed: {users_per_second:,.2f} users/second")

if __name__ == "__main__":
    benchmark_generation()
