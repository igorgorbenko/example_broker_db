----------------------------------------------------------------------
-- первые 3 депозита каждого клиента
----------------------------------------------------------------------
with depo as(
    select 
        row_number() over(
            partition by  
                u.uid 
            order by 
                o.operation_date) as row_numb,
        u.uid,
        l.login,
        o.operation_date
    from default_s.tb_users u
    join default_s.tb_logins l
        on u.uid = l.user_uid
    join billing.tb_operations o
        on o.login = l.login 
    where o.operation_type = 'deposit'
)
select 
    d.uid,
    d.login,
    d.operation_date,
    d.row_numb
from depo d
where d.row_numb <= 3
order by
    d.uid,
    d.operation_date
;