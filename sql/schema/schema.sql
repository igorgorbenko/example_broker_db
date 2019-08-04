-----------------------------------------------------------------
-- 1. Создать структуру БД, наполнить тестовыми данными. Часть 1
-----------------------------------------------------------------

if schema_id('default_s') is null
    exec('create schema default_s');
if schema_id('billing') is null
    exec('create schema billing');
if schema_id('orderstat') is null
    exec('create schema orderstat');

drop table if exists billing.tb_operations;
drop table if exists orderstat.tb_orders;
drop table if exists default_s.tb_logins;
drop table if exists default_s.tb_users;


create table default_s.tb_users
    (
        id_num_row          int identity,
        uid                 uniqueidentifier 
            constraint guid_default default
            newsequentialid() rowguidcol,
        registration_date   datetime2(0),
        country             varchar(100)
        constraint guid_pk primary key (uid) 
    )
;

create table default_s.tb_logins
    (
        id_num_row      int identity,
        user_uid        uniqueidentifier
            constraint fk_tb_users_uid foreign key (user_uid)
            references default_s.tb_users (uid),
        login           uniqueidentifier 
            constraint guid_login_default default
            newsequentialid() rowguidcol,
        account_type    varchar(50),
        constraint login_pk primary key (login),
        constraint check_logins_account_type
            check (account_type in ('real', 'demo'))
    )
;


create table billing.tb_operations
    (
        operation_type  varchar(20),
        operation_date  datetime2(0),
        login           uniqueidentifier
            constraint tb_operations_login foreign key (login)
            references default_s.tb_logins (login),
        amount          float,

        constraint check_operations_operation_type
            check (operation_type in ('deposit', 'withdrawal'))
    )
;

create table orderstat.tb_orders
    (
        login           uniqueidentifier
            constraint tb_operations_login foreign key (login)
            references default_s.tb_logins (login),
        order_close_date  datetime2(0),
        date_edit datetime2(0) default getdate()
    )
;