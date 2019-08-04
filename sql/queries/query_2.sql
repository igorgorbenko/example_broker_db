----------------------------------------------------------------------
-- Клиенты по странам, у которых средний депозит >=1000
----------------------------------------------------------------------

-- сумма депозита на каждом счете
with sum_depo as (
    select 
        o.login, 
        sum(
            case
                when o.operation_type = 'withdrawal'
                    then -o.amount
                else
                    o.amount
            end) as sum_depo
    from billing.tb_operations o
    group by
        o.login
), 
avg_depo_by_client as (
    select 
        l.user_uid,
        avg(sd.sum_depo) as avg_depo,
        case
            when avg(sd.sum_depo) >= 1000
                then 1
            else
                0
        end as is_more_1000
    from default_s.tb_logins l
    join sum_depo sd
        on l.login = sd.login
    where l.account_type = 'real'    -- берем только реальные счета
    group by
        l.user_uid
)
select 
    u.country,
    count(distinct u.uid) as count_clients_all,
    sum(is_more_1000) as count_clienrs_more_1000USD        
from default_s.tb_users u
left join avg_depo_by_client d
    on u.uid = d.user_uid
group by
    u.country
order by 
    u.country
 ;