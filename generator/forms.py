from django import forms
from django.core.exceptions import ValidationError

MAX_BATCH_SIZE = 1_000
MAX_NUMBER_OF_BATCHES = 2**31 - 1
MAX_SEED = 2**63 - 1
MIN_SEED = -(2**63)
MAX_TOTAL_USERS = 50_000_000


class GenerationForm(forms.Form):
    locale = forms.ChoiceField(label="Locale")
    seed = forms.IntegerField(
        label="Seed",
        min_value=MIN_SEED,
        max_value=MAX_SEED,
        initial=1,
    )
    batch_size = forms.IntegerField(
        label="Users per batch",
        min_value=1,
        max_value=MAX_BATCH_SIZE,
        initial=1_000,
    )
    number_of_batches = forms.IntegerField(
        label="Number of batches",
        min_value=1,
        max_value=MAX_NUMBER_OF_BATCHES,
        initial=100,
    )

    def __init__(self, *args, locale_choices=(), **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["locale"].choices = locale_choices
        if locale_choices and not self.initial.get("locale"):
            self.fields["locale"].initial = locale_choices[0][0]

    def clean(self):
        cleaned_data = super().clean()
        batch_size = cleaned_data.get("batch_size")
        number_of_batches = cleaned_data.get("number_of_batches")

        if ( batch_size is not None and number_of_batches is not None and batch_size * number_of_batches > MAX_TOTAL_USERS):
            raise ValidationError(f"The total number of users cannot exceed {MAX_TOTAL_USERS}.")

        return cleaned_data
