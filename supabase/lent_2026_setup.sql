-- Lent 2026 setup for multi-week Thursday 9PM -> Friday 7PM adoration
-- Run in Supabase SQL editor.

BEGIN;

-- 1) Add week dimensions to slots (safe if run multiple times)
ALTER TABLE public.slots ADD COLUMN IF NOT EXISTS week_start_date DATE;
ALTER TABLE public.slots ADD COLUMN IF NOT EXISTS week_label TEXT;

-- 2) Tag existing rows as first week if they are still untagged
UPDATE public.slots
SET week_start_date = '2026-02-19',
    week_label      = 'Feb 19'
WHERE week_start_date IS NULL;

-- 3) Duplicate all time slots into each remaining Lenten week.
--    Important: do NOT depend on only one "base" week row for times,
--    because some environments already have partial rows with NULL times.
--    We build a canonical row per sort_order using any non-null times found.
WITH canonical AS (
  SELECT DISTINCT ON (sort_order)
    day_text,
    start_time,
    end_time,
    display_label,
    sort_order
  FROM public.slots
  ORDER BY
    sort_order,
    (start_time IS NULL),
    (end_time IS NULL),
    week_start_date NULLS FIRST,
    id
),
weeks(week_start_date, week_label) AS (
  VALUES
    ('2026-02-26'::date, 'Feb 26'),
    ('2026-03-05'::date, 'Mar 5'),
    ('2026-03-12'::date, 'Mar 12'),
    ('2026-03-19'::date, 'Mar 19'),
    ('2026-03-26'::date, 'Mar 26')
)
INSERT INTO public.slots (
  day_text,
  start_time,
  end_time,
  display_label,
  sort_order,
  week_start_date,
  week_label
)
SELECT
  c.day_text,
  c.start_time,
  c.end_time,
  c.display_label,
  c.sort_order,
  w.week_start_date,
  w.week_label
FROM canonical c
CROSS JOIN weeks w
WHERE c.start_time IS NOT NULL
  AND c.end_time IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.slots s
    WHERE s.sort_order = c.sort_order
      AND s.week_start_date = w.week_start_date
  );

-- 4) Helpful uniqueness guard to prevent duplicate slot per week/time
CREATE UNIQUE INDEX IF NOT EXISTS slots_week_sort_unique
  ON public.slots (week_start_date, sort_order);

COMMIT;
