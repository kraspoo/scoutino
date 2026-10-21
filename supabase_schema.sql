-- Scoutino - Supabase schema (للمرحلة الجاية لما تربط الباك إند)

create table if not exists players (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  full_name text not null,
  age int check (age between 6 and 20),
  position text,
  city text,
  preferred_foot text,
  overall_score int,
  created_at timestamptz default now()
);

create table if not exists skill_videos (
  id uuid primary key default gen_random_uuid(),
  player_id uuid references players(id) on delete cascade,
  skill text not null,
  video_url text not null,
  created_at timestamptz default now()
);

create table if not exists ai_results (
  id uuid primary key default gen_random_uuid(),
  player_id uuid references players(id) on delete cascade,
  speed int,
  dribbling int,
  shooting int,
  ball_control int,
  stamina int,
  created_at timestamptz default now()
);

alter table players enable row level security;
alter table skill_videos enable row level security;
alter table ai_results enable row level security;

create policy "players are readable by everyone" on players for select using (true);
create policy "owner manages player" on players for all using (auth.uid() = user_id);

create policy "videos readable" on skill_videos for select using (true);
create policy "owner manages videos" on skill_videos for all
  using (exists (select 1 from players p where p.id = player_id and p.user_id = auth.uid()));

create policy "results readable" on ai_results for select using (true);
create policy "owner manages results" on ai_results for all
  using (exists (select 1 from players p where p.id = player_id and p.user_id = auth.uid()));
