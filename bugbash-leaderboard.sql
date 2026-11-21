-- Bug Bash leaderboard for asher-lee.com
-- Run this once in Supabase: SQL Editor > New query > paste > Run.
-- Then copy Project URL and the anon public key (Project Settings > API)
-- into the LEADERBOARD block at the top of the <script> in index.html.

create table if not exists public.bugbash_scores (
  id          bigint generated always as identity primary key,
  name        text        not null default 'Anonymous',
  score       integer     not null,
  grade       text        not null,
  created_at  timestamptz not null default now(),
  -- basic sanity limits so the public board stays clean
  constraint name_length  check (char_length(name) between 1 and 14),
  constraint score_range  check (score between 0 and 50000),
  constraint grade_value  check (grade in ('S', 'A', 'B', 'C', 'D'))
);

create index if not exists bugbash_scores_score_idx
  on public.bugbash_scores (score desc, created_at asc);

-- Row Level Security: anyone can read the board and add a score,
-- nobody can edit or delete scores from the browser.
alter table public.bugbash_scores enable row level security;

drop policy if exists "read scores" on public.bugbash_scores;
create policy "read scores" on public.bugbash_scores
  for select to anon using (true);

drop policy if exists "add a score" on public.bugbash_scores;
create policy "add a score" on public.bugbash_scores
  for insert to anon with check (true);

-- To wipe test runs later (run as the project owner, not from the site):
-- truncate public.bugbash_scores;
