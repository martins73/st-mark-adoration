# Saint Mark Adoration

## Do I need to change Supabase for multi-week Lent signups?
Yes. The app can show/select multiple Fridays only if your `slots` table contains one row per **time slot per week**.

If Supabase only has one week's rows, users will only see one Friday to sign up for.


## Use this migration file as the source of truth
If you changed the website over time, ignore any old inline SQL snippets you may have copied earlier.
Always run `supabase/lent_2026_setup.sql` from this repo as the canonical version.

## One-time DB setup
Run this SQL file in Supabase SQL editor:

- `supabase/lent_2026_setup.sql`

It will:
- Add `week_start_date` and `week_label` columns (if missing).
- Tag existing rows as `2026-02-19` (`Feb 19`).
- Seed rows for the remaining Lenten weeks.
- Preserve your original `start_time`/`end_time` columns while seeding.
- Add a uniqueness index to avoid duplicate week/time slots.

## Verify data seeded correctly
Use this quick check in Supabase SQL editor:

```sql
select week_start_date, week_label, count(*) as slot_count
from public.slots
group by week_start_date, week_label
order by week_start_date;
```

You should see one row per Thursday date in Lent, each with the same `slot_count`.

## App behavior notes
- Multi-week signup in the modal works once multiple weeks exist in `slots`.
- A warning banner appears when expected Lent weeks are missing.


## Important for your original schema
Your original `slots` table has `start_time` and `end_time` as `NOT NULL`.
The migration script in this repo now copies those fields when creating each new week, so it works with your exact schema.


## Troubleshooting (if you saw `null value in column "start_time"`)
If Supabase shows an error like:

`null value in column "start_time" of relation "slots" violates not-null constraint`

it means some existing slot rows had incomplete time data.
The migration script now auto-selects canonical rows with non-null `start_time`/`end_time` per `sort_order` and only inserts complete rows.

Optional diagnostic query:

```sql
select sort_order, count(*) as rows_with_missing_times
from public.slots
where start_time is null or end_time is null
group by sort_order
order by sort_order;
```
