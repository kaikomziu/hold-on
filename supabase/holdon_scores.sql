-- HOLD ON 世界ランキング用テーブル
-- Supabaseプロジェクト kifnzvktwbomxthzvvgy の SQL Editor で一度だけ実行してください。
-- (このプロジェクトは隠語クイズ・めっちゃカメレオン・反射神経DELUXE等と相乗りのため、
--  このサイト専用の接頭辞 "holdon_" のテーブルのみ扱います)

create table if not exists public.holdon_scores (
  id bigint generated always as identity primary key,
  name text not null check (char_length(trim(name)) between 1 and 12),
  -- ズレ合計(ミリ秒)。小さいほど上位。5ラウンド分。
  total_ms numeric not null check (total_ms >= 0 and total_ms < 60000),
  -- 一番良かったラウンドのズレ(ミリ秒)。同点時のタイブレークと表示用。
  best_round_ms numeric not null check (best_round_ms >= 0 and best_round_ms < 20000),
  -- 各ラウンドの {t: お題ms, h: キープしたms} 配列(表示・検証用、省略可)
  rounds jsonb,
  created_at timestamptz not null default now()
);

alter table public.holdon_scores enable row level security;

-- 再実行しても安全なように、既存ポリシーがあれば削除してから作り直す
drop policy if exists "holdon_scores_public_read" on public.holdon_scores;
drop policy if exists "holdon_scores_public_insert" on public.holdon_scores;

-- 誰でも閲覧可能(世界ランキング表示のため)
create policy "holdon_scores_public_read"
  on public.holdon_scores for select
  to anon
  using (true);

-- 誰でも登録可能(妥当性はCHECK制約で担保、更新・削除は不可)
create policy "holdon_scores_public_insert"
  on public.holdon_scores for insert
  to anon
  with check (true);

-- 上位取得を速くするためのインデックス
create index if not exists holdon_scores_total_ms_idx on public.holdon_scores (total_ms asc);
