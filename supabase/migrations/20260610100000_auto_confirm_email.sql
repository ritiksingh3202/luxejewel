-- Simple sign-up: mark new accounts as email-confirmed so users can sign in immediately.
create or replace function public.auto_confirm_email()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email_confirmed_at is null then
    new.email_confirmed_at := now();
  end if;
  return new;
end;
$$;
revoke all on function public.auto_confirm_email() from public, anon, authenticated;

drop trigger if exists auto_confirm_email on auth.users;
create trigger auto_confirm_email
  before insert on auth.users
  for each row execute function public.auto_confirm_email();

-- Confirm any accounts that signed up before this migration.
update auth.users set email_confirmed_at = now() where email_confirmed_at is null;
