----------------------------------------------------------------------
-- среднее время перехода пользователей между этапами воронки:
--     - От регистрации до внесения депозита
--     - От внесения депозита до первой сделки на реальном счёте
----------------------------------------------------------------------
with base_info as (
    select 
        u.uid,
        u.registration_date,
        u.country,
        l.login
    from default_s.tb_users u
    join default_s.tb_logins l
        on u.uid = l.user_uid
    where l.account_type = 'real'
        and u.registration_date >= dateadd(day, -90, cast(floor(cast(getdate() as float)) as datetime))    -- выборка за последние 90 дней
), 
group_by_country as (    -- количество клиентов по странам, берем только тех, которые имеют реальные счета и были зареганы за последние 90 дней
    select 
        a.country,
        count(u1.uid) as count_by_country
    from
        (
            select 
                distinct country
            from default_s.tb_users
        ) as a
    left join default_s.tb_users u1
        on a.country = u1.country
        and exists    
        (
            select 1
            from base_info u2
            where u1.uid = u2.uid
        )
    group by
        a.country
),
first_depo as (
    select 
        o.login,
        min(o.operation_date) as first_depo
    from billing.tb_operations o
    where o.operation_type = 'deposit'
    group by 
        o.login
), 
first_deal as (
select 
    ord.login,
    min(ord.order_close_date) as first_deal
from orderstat.tb_orders ord
group by
    ord.login
), 
accum_data as (
    select 
        b.uid,
        b.country,
        f.login,
        b.registration_date,
        f.first_depo,
        datediff(day, b.registration_date, f.first_depo) as days_from_registration,    -- время перехода от ргистрации до пополнения в днях
        d.first_deal,
        datediff(day, f.first_depo, d.first_deal) as days_from_depo                    -- время перехода от первого пополнения до закрытия первой сделки
    from base_info b
    left join first_depo f        -- на случай, если пользоваетель еще не имеет реального счета или еще не пополнял
        on b.login = f.login
    left join first_deal d        -- на случай, если не было торговых операций, но есть реальный счет + депозит
        on d.login = b.login
) 
select 
    c.country,
    avg(days_from_registration) as avg_days_from_registration,
    avg(days_from_depo) as avg_days_from_deposit,
    c.count_by_country
from group_by_country c
left join accum_data b
    on b.country = c.country
group by
    c.country,
    c.count_by_country
order by c.count_by_country desc
;