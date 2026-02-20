# Saint Mark Adoration

## Do I need to change Supabase for multi-week Lent signups?
Yes. The app can show/select multiple Fridays only if your `slots` table contains one row per **time slot per week**.

If Supabase only has one week's rows, users will only see one Friday to sign up for.

## One-time DB setup
Run this SQL file in Supabase SQL editor:

- `supabase/lent_2026_setup.sql`

It will:
- Add `week_start_date` and `week_label` columns (if missing).
- Tag existing rows as `2026-02-19` (`Feb 19`).
- Seed rows for the remaining Lenten weeks.
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
