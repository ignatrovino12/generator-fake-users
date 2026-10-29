from django.db import connection
from django.shortcuts import redirect, render
from .forms import GenerationForm

SESSION_KEY = "user_generator"

def generator(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT code, language, country FROM locales ORDER BY code")
        locales = cursor.fetchall()

    locale_choices = [(code, f"{code} - {language}, {country}")
                      for code, language, country in locales]
    saved_generation = request.session.get(SESSION_KEY)

    if request.method == "POST":
        form = GenerationForm(request.POST, locale_choices=locale_choices)
        if form.is_valid():
            request.session[SESSION_KEY] = {
                "seed": form.cleaned_data["seed"],
                "locale": form.cleaned_data["locale"],
                "batch_size": form.cleaned_data["batch_size"],
                "number_of_batches": form.cleaned_data["number_of_batches"],
            }
            return redirect("generator")
    else:
        form = GenerationForm(initial=saved_generation, locale_choices=locale_choices)

    context = {
        "form": form,
        "rows": [],
        "generation": saved_generation,
        "batch_index": None,
        "start_user_index": None,
        "end_user_index": None,
        "total_users": None,
        "previous_batch": None,
        "next_batch": None,
    }

    if not saved_generation:
        return render(request, "generator/index.html", context)

    try:
        batch_index = int(request.GET.get("batch", "0"))
    except ValueError:
        form.add_error(None, "Batch index must be a whole number.")
        return render(request, "generator/index.html", context)

    number_of_batches = saved_generation["number_of_batches"]
    if batch_index < 0 or batch_index >= number_of_batches:
        form.add_error(None, "Batch not in generation interval.")
        return render(request, "generator/index.html", context)

    start_user_index = batch_index * saved_generation["batch_size"]
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT *
            FROM generate_users_batch(%s, %s, %s, %s, %s)
            """,
            [
                saved_generation["seed"],
                saved_generation["locale"],
                batch_index,
                saved_generation["batch_size"],
                start_user_index,
            ],
        )
        columns = [column[0] for column in cursor.description]
        rows = [
            {"user_index": start_user_index + offset, **dict(zip(columns, values))}
            for offset, values in enumerate(cursor.fetchall())]

    context.update(
        {
            "rows": rows,
            "batch_index": batch_index,
            "start_user_index": start_user_index,
            "end_user_index": start_user_index + saved_generation["batch_size"] - 1,
            "total_users": (saved_generation["batch_size"] * saved_generation["number_of_batches"]),
            "previous_batch": batch_index - 1 if batch_index > 0 else None,
            "next_batch": ( batch_index + 1 if batch_index + 1 < number_of_batches else None),
        }
    )
    return render(request, "generator/index.html", context)
