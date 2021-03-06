drop table if exists ttl_00933_1;

create table ttl_00933_1 (d DateTime, a Int ttl d + interval 1 second, b Int ttl d + interval 1 second) engine = MergeTree order by tuple() partition by toMinute(d);
insert into ttl_00933_1 values (now(), 1, 2);
insert into ttl_00933_1 values (now(), 3, 4);
select sleep(1.1) format Null;
optimize table ttl_00933_1 final;
select a, b from ttl_00933_1;

drop table if exists ttl_00933_1;

create table ttl_00933_1 (d DateTime, a Int ttl d + interval 1 DAY) engine = MergeTree order by tuple() partition by toDayOfMonth(d);
insert into ttl_00933_1 values (toDateTime('2000-10-10 00:00:00'), 1);
insert into ttl_00933_1 values (toDateTime('2000-10-10 00:00:00'), 2);
insert into ttl_00933_1 values (toDateTime('2000-10-10 00:00:00'), 3);
select sleep(0.7) format Null; -- wait if very fast merge happen
optimize table ttl_00933_1 final;
select * from ttl_00933_1 order by d;

drop table if exists ttl_00933_1;

create table ttl_00933_1 (d DateTime, a Int) engine = MergeTree order by tuple() partition by tuple() ttl d + interval 1 day;
insert into ttl_00933_1 values (toDateTime('2000-10-10 00:00:00'), 1);
insert into ttl_00933_1 values (toDateTime('2000-10-10 00:00:00'), 2);
insert into ttl_00933_1 values (toDateTime('2100-10-10 00:00:00'), 3);
select sleep(0.7) format Null; -- wait if very fast merge happen
optimize table ttl_00933_1 final;
select * from ttl_00933_1 order by d;

drop table if exists ttl_00933_1;

create table ttl_00933_1 (d Date, a Int) engine = MergeTree order by a partition by toDayOfMonth(d) ttl d + interval 1 day;
insert into ttl_00933_1 values (toDate('2000-10-10'), 1);
insert into ttl_00933_1 values (toDate('2100-10-10'), 2);
select sleep(0.7) format Null; -- wait if very fast merge happen
optimize table ttl_00933_1 final;
select * from ttl_00933_1 order by d;

set send_logs_level = 'none';

drop table if exists ttl_00933_1;

create table ttl_00933_1 (d DateTime ttl d) engine = MergeTree order by tuple() partition by toSecond(d); -- { serverError 44}
create table ttl_00933_1 (d DateTime, a Int ttl d) engine = MergeTree order by a partition by toSecond(d); -- { serverError 44}
create table ttl_00933_1 (d DateTime, a Int ttl 2 + 2) engine = MergeTree order by tuple() partition by toSecond(d); -- { serverError 450 }
create table ttl_00933_1 (d DateTime, a Int ttl toDateTime(1)) engine = MergeTree order by tuple() partition by toSecond(d); -- { serverError 450 }
create table ttl_00933_1 (d DateTime, a Int ttl d - d) engine = MergeTree order by tuple() partition by toSecond(d); -- { serverError 450 }

drop table if exists ttl_00933_1;

/*

Alexey Milovidov, [17.04.19 20:09]
sleep(0.7)
sleep(1.1)
- почему? @Alesapin

Alexander Sapin, [17.04.19 23:16]
[In reply to Alexey Milovidov]
1.1 по логике теста, я попробовал с 0.5 и у меня флапнуло. С 1 не флапало, но работало долго. Попробовал 0.7 и тоже не флапает.

Alexey Milovidov, [17.04.19 23:18]
Слабо такой комментарий добавить прямо в тест? :)

Alexander Sapin, [17.04.19 23:20]
как-то неловко :)

*/
