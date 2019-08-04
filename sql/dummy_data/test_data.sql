-----------------------------------------------------------------
-- 1. Создать структуру БД, наполнить тестовыми данными. Часть 2
-----------------------------------------------------------------

set nocount on;

create table #tmp_countries
    (
        id_num_row  int identity,
        country     varchar(50)
    )
;

insert into #tmp_countries(country)
values
    ('Afghanistan'),
    ('Albania'),
    ('Algeria'),
    ('Andorra'),
    ('Angola'),
    ('Antigua & Deps'),
    ('Argentina'),
    ('Armenia'),
    ('Australia'),
    ('Austria'),
    ('Azerbaijan'),
    ('Bahamas'),
    ('Bahrain'),
    ('Bangladesh'),
    ('Barbados'),
    ('Belarus'),
    ('Belgium'),
    ('Belize'),
    ('Benin'),
    ('Bhutan'),
    ('Bolivia'),
    ('Bosnia Herzegovina'),
    ('Botswana'),
    ('Brazil'),
    ('Brunei'),
    ('Bulgaria'),
    ('Burkina'),
    ('Burundi'),
    ('Cambodia'),
    ('Cameroon'),
    ('Canada'),
    ('Cape Verde'),
    ('Central African Rep'),
    ('Chad'),
    ('Chile'),
    ('China'),
    ('Colombia'),
    ('Comoros'),
    ('Congo'),
    ('Congo {Democratic Rep}'),
    ('Costa Rica'),
    ('Croatia'),
    ('Cuba'),
    ('Cyprus'),
    ('Czech Republic'),
    ('Denmark'),
    ('Djibouti'),
    ('Dominica'),
    ('Dominican Republic'),
    ('East Timor'),
    ('Ecuador'),
    ('Egypt'),
    ('El Salvador'),
    ('Equatorial Guinea'),
    ('Eritrea'),
    ('Estonia'),
    ('Ethiopia'),
    ('Fiji'),
    ('Finland'),
    ('France'),
    ('Gabon'),
    ('Gambia'),
    ('Georgia'),
    ('Germany'),
    ('Ghana'),
    ('Greece'),
    ('Grenada'),
    ('Guatemala'),
    ('Guinea'),
    ('Guinea-Bissau'),
    ('Guyana'),
    ('Haiti'),
    ('Honduras'),
    ('Hungary'),
    ('Iceland'),
    ('India'),
    ('Indonesia'),
    ('Iran'),
    ('Iraq'),
    ('Ireland {Republic}'),
    ('Israel'),
    ('Italy'),
    ('Ivory Coast'),
    ('Jamaica'),
    ('Japan'),
    ('Jordan'),
    ('Kazakhstan'),
    ('Kenya'),
    ('Kiribati'),
    ('Korea North'),
    ('Korea South'),
    ('Kosovo'),
    ('Kuwait'),
    ('Kyrgyzstan'),
    ('Laos'),
    ('Latvia'),
    ('Lebanon'),
    ('Lesotho'),
    ('Liberia'),
    ('Libya'),
    ('Liechtenstein'),
    ('Lithuania'),
    ('Luxembourg'),
    ('Macedonia'),
    ('Madagascar'),
    ('Malawi'),
    ('Malaysia'),
    ('Maldives'),
    ('Mali'),
    ('Malta'),
    ('Marshall Islands'),
    ('Mauritania'),
    ('Mauritius'),
    ('Mexico'),
    ('Micronesia'),
    ('Moldova'),
    ('Monaco'),
    ('Mongolia'),
    ('Montenegro'),
    ('Morocco'),
    ('Mozambique'),
    ('Myanmar, {Burma}'),
    ('Namibia'),
    ('Nauru'),
    ('Nepal'),
    ('Netherlands'),
    ('New Zealand'),
    ('Nicaragua'),
    ('Niger'),
    ('Nigeria'),
    ('Norway'),
    ('Oman'),
    ('Pakistan'),
    ('Palau'),
    ('Panama'),
    ('Papua New Guinea'),
    ('Paraguay'),
    ('Peru'),
    ('Philippines'),
    ('Poland'),
    ('Portugal'),
    ('Qatar'),
    ('Romania'),
    ('Russian Federation'),
    ('Rwanda'),
    ('St Kitts & Nevis'),
    ('St Lucia'),
    ('Saint Vincent & the Grenadines'),
    ('Samoa'),
    ('San Marino'),
    ('Sao Tome & Principe'),
    ('Saudi Arabia'),
    ('Senegal'),
    ('Serbia'),
    ('Seychelles'),
    ('Sierra Leone'),
    ('Singapore'),
    ('Slovakia'),
    ('Slovenia'),
    ('Solomon Islands'),
    ('Somalia'),
    ('South Africa'),
    ('South Sudan'),
    ('Spain'),
    ('Sri Lanka'),
    ('Sudan'),
    ('Suriname'),
    ('Swaziland'),
    ('Sweden'),
    ('Switzerland'),
    ('Syria'),
    ('Taiwan'),
    ('Tajikistan'),
    ('Tanzania'),
    ('Thailand'),
    ('Togo'),
    ('Tonga'),
    ('Trinidad & Tobago'),
    ('Tunisia'),
    ('Turkey'),
    ('Turkmenistan'),
    ('Tuvalu'),
    ('Uganda'),
    ('Ukraine'),
    ('United Arab Emirates'),
    ('United Kingdom'),
    ('United States'),
    ('Uruguay'),
    ('Uzbekistan'),
    ('Vanuatu'),
    ('Vatican City'),
    ('Venezuela'),
    ('Vietnam'),
    ('Yemen'),
    ('Zambia'),
    ('Zimbabwe')


--------------------------------------------------
-- Заполнение таблицы tb_users
--------------------------------------------------
declare @rand_lookup int
declare @random int
declare @rand_country varchar(50)
declare @rand_date datetime2(0)
declare @max_int int
declare @fromdate datetime2(0)

-- Случайное значение номера строки из таблицы #tmp_countries
select @max_int = max(id_num_row) from #tmp_countries
select @fromdate = dateadd(day, -365, getdate())

declare @seconds int = datediff(second, @fromdate, getdate())

-- Вставка 5К пользователей
declare @iCount int = 0
declare @iNumRows int = 5000

while @iCount < @iNumRows
begin
    select @rand_lookup = (abs(checksum(newid()) % @max_int) + 1)
    select @rand_country = country from #tmp_countries where id_num_row = @rand_lookup

    select @random = round(((@seconds - 1) * rand()), 0)
    select @rand_date = dateadd(second, @random, @fromdate)

    insert into default_s.tb_users(registration_date, country)
    values (@rand_date, @rand_country)
        
    set @iCount = @iCount + 1
end

-- Индекс по таблице
create nonclustered index ix_tb_users_id_num_row
    on default_s.tb_users (id_num_row);  

--------------------------------------------------
-- Заполнение таблицы tb_logins
--------------------------------------------------
-- Случайное значение номера строки из таблицы tb_users
declare @user_uid uniqueidentifier
declare @rand_lookup_mini smallint

select @max_int = max(id_num_row) from default_s.tb_users

-- Вставка 10К счетов
set @iCount = 0
set @iNumRows = 10000

while @iCount < @iNumRows
begin
    select @rand_lookup = (abs(checksum(newid()) % @max_int) + 1)
    select @user_uid = u.uid from default_s.tb_users u where u.id_num_row = @rand_lookup

    select @rand_lookup_mini = (abs(checksum(newid()) % 2) + 1)
    
    insert into default_s.tb_logins(user_uid, account_type)
    select @user_uid, choose(@rand_lookup_mini, 'real', 'demo') 
    
    set @iCount = @iCount + 1
end

-- Индекс по таблице
create nonclustered index ix_tb_logins_id_num_row
    on default_s.tb_logins (id_num_row);  

create nonclustered index ix_tb_logins_useruid
    on default_s.tb_logins (user_uid)  
    include (account_type);

--------------------------------------------------
-- Заполнение таблицы billing.tb_operations
--------------------------------------------------
declare @user_login uniqueidentifier

-- Вставка 30К записей
set @iCount = 0
set @iNumRows = 30000

select @max_int = max(id_num_row) from default_s.tb_logins

while @iCount < @iNumRows
begin
    select @rand_lookup = (abs(checksum(newid()) % @max_int) + 1)
    select @user_login = l.login from default_s.tb_logins l where l.id_num_row = @rand_lookup

    -- Дата операции по счету не может быть раньше регистрации клиента
    select 
        @fromdate = registration_date
    from default_s.tb_users u
    join default_s.tb_logins l
        on u.uid = l.user_uid
    where 
        l.login = @user_login
    
    set @seconds = datediff(second, @fromdate, getdate())
    select @random = round(((@seconds - 1) * rand()), 0)
    select @rand_date = dateadd(second, @random, @fromdate)  -- случайная дата от даты регистрации клиента до текущей даты

    select @rand_lookup_mini = (abs(checksum(newid()) % 2) + 1)
    
    insert into billing.tb_operations(operation_type, operation_date, login, amount)
    select 
        choose(@rand_lookup_mini, 'deposit', 'withdrawal'),     -- будем считать, что клиентам доступен маржинальный вывод,
                                                                -- поэтому, очередностью операций пренебрегает.
        @rand_date,
        @user_login, 
        round(3000 * rand(), 2) -- Рандомная сумма операции до 3К USD
    
    set @iCount = @iCount + 1
end

-- Индекс по таблице
create nonclustered index ix_tb_operations_login  
    on billing.tb_operations (login)  
    include (operation_date, amount, operation_type);


--------------------------------------------------
-- Заполнение таблицы orderstat.tb_orders
--------------------------------------------------
-- Вставка 10К записей
set @iCount = 0
set @iNumRows = 10000

while @iCount < @iNumRows
begin
    select @rand_lookup = (abs(checksum(newid()) % @max_int) + 1)
    
    select @user_login = l.login from default_s.tb_logins l where l.id_num_row = @rand_lookup
    
    -- Дата закрытия позиции по счету не может быть раньше первого пополнения счета
    select 
        @fromdate = min(o.operation_date) 
    from billing.tb_operations o 
    where o.login = @user_login
        and operation_type = 'deposit'
        
    if @fromdate is not null
    begin
        set @seconds = datediff(second, @fromdate, getdate())
        select @random = round(((@seconds - 1) * rand()), 0)
        select @rand_date = dateadd(second, @random, @fromdate)  -- случайная дата от даты регистрации клиента до текущей даты
        
        insert into orderstat.tb_orders(login, order_close_date)
        values (@user_login, @rand_date)
        
        set @iCount = @iCount + 1
    end
end


-- Индекс по таблице
create nonclustered index ix_tb_orders_login  
    on orderstat.tb_orders (login)  
    include (order_close_date);

-- Удаление временной таблицы
drop table #tmp_countries;

