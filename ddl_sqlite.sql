drop table if exists hashtag;
drop table if exists subscription;
drop table if exists subscription_log;
drop table if exists post;
drop table if exists user_account;

pragma foreign_keys = on;

create table user_account (
    id integer primary key,
    username text not null,
    email text not null,
    registration_date text default CURRENT_DATE not null,
	unique (username collate nocase),
	unique (email collate nocase)
);

create table post (
    id integer primary key,
    user_id integer references user_account(id) on delete cascade not null,
    content text not null,
    publication_date text default CURRENT_DATE not null
);

create table subscription (
    id integer primary key,
    subscriber_user_id integer references user_account(id) on delete cascade not null,
    subscribed_user_id integer references user_account(id) on delete cascade not null,
    unique (subscriber_user_id, subscribed_user_id),
	check (subscriber_user_id != subscribed_user_id)
);

create table subscription_log (
    subscriber_user_id integer references user_account(id) on delete cascade not null,
    subscribed_user_id integer references user_account(id) on delete cascade not null,
    action_date text default CURRENT_DATE not null,
    action text not null check ( action in ('subscribe', 'cancel') )
);

create table hashtag (
    id integer primary key,
    post_id integer references post(id) on delete cascade not null,
    text text not null,
    unique (post_id, text)
);

alter table post add column lat real;
alter table post add column lng real
check ( (lat is not null and lng is not null) or (lat is null and lng is null) );

-- all inserts

create trigger log_subscription_insert
after insert on subscription for each row
begin
    insert into subscription_log (subscriber_user_id, subscribed_user_id, action)
    values (new.subscriber_user_id, new.subscribed_user_id, 'subscribe');
end;

create trigger log_subscription_delete
after delete on subscription for each row
begin
    insert into subscription_log (subscriber_user_id, subscribed_user_id, action)
    values (old.subscriber_user_id, old.subscribed_user_id, 'cancel');
end;