drop table if exists hashtag;
drop table if exists subscription;
drop table if exists subscription_log;
drop table if exists post;
drop table if exists user_account;

create table user_account (
    id int auto_increment primary key,
    username varchar(255) unique not null,
    email varchar(255) unique not null,
    registration_date date default CURRENT_DATE not null
);

create table post (
    id int auto_increment primary key,
    user_id int not null,
    content text not null,
    publication_date date default CURRENT_DATE not null,
    lat decimal(8,6),
    lng decimal(9,6),
    constraint foreign key (user_id) references user_account (id) on delete cascade,
    check ( (lat is not null and lng is not null) or (lat is null and lng is null) )
);

create table subscription (
    id int auto_increment primary key,
    subscriber_user_id int not null,
    subscribed_user_id int not null,
    constraint foreign key (subscriber_user_id) references user_account(id) on delete cascade,
    constraint foreign key (subscribed_user_id) references user_account(id) on delete cascade,
    unique (subscriber_user_id, subscribed_user_id),
	check (subscriber_user_id != subscribed_user_id)
);

create table subscription_log (
    subscriber_user_id int not null,
    subscribed_user_id int not null,
    action_date date default CURRENT_DATE not null,
    action varchar(10) not null check ( action in ('subscribe', 'cancel') ),
    constraint foreign key (subscriber_user_id) references user_account(id) on delete cascade,
    constraint foreign key (subscribed_user_id) references user_account(id) on delete cascade
);

create table hashtag (
    id int auto_increment primary key,
    post_id int not null,
    text varchar(50) not null,
    constraint foreign key (post_id) references post(id) on delete cascade,
    unique (post_id, text)
);

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