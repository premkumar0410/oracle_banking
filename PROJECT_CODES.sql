--MASTER TABLE DATA insertion parts
begin
--INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
--VALUES (3000, 2000, 'Silver', 5000, 50000);
--INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
--VALUES (3001, 2000, 'Gold', 10000, 100000);
--INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
--VALUES (3002, 2000, 'Platinum', 15000, 2500000);
--INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
--VALUES (3003, 2001, 'Silver', 5000, 50000);
INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
VALUES (3004, 2001, 'Gold', 10000, 100000);
INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
VALUES (3005, 2001, 'Platinum', 15000, 2500000);
INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
VALUES (3006, 2002, 'Silver', 5000, 50000);
INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
VALUES (3007, 2002, 'Gold', 10000, 100000);
INSERT INTO ttsbank_sub_products (sub_product_id, product_id, feature, balance_limit, withdraw_limit) 
VALUES (3008, 2002, 'Platinum', 15000, 2500000);
COMMIT; -- Save the changes permanently
end;
/

commit;

select * from ttsbank_sub_products;

begin
INSERT INTO ttsbank_banks (bank_id, bank_code, bank_location, is_headoffice) 
VALUES (1000, 'ttsbnk001', 'chennai', 'y');
INSERT INTO ttsbank_banks (bank_id, bank_code, bank_location, is_headoffice) 
VALUES (1001, 'ttsbnk002', 'madurai', 'n');
INSERT INTO ttsbank_banks (bank_id, bank_code, bank_location, is_headoffice) 
VALUES (1002, 'ttsbnk003', 'coimbatore', 'n');
COMMIT; -- Save the changes permanently
end;
/

begin
INSERT INTO ttsbank_products (product_id, product_name, product_code) 
VALUES (2000, 'savings bank', 'sb');
INSERT INTO ttsbank_products (product_id, product_name, product_code) 
VALUES (2001, 'current', 'cb');
INSERT INTO ttsbank_products (product_id, product_name, product_code) 
VALUES (2002, 'business', 'bb');
COMMIT; -- Save the changes permanently
end;
/


--sequence for customer transaction
create sequence sqcustrans start with 7000;
--sequence for account number
create sequence sqaccno start with 10000000;
--sequence for�cus�product�id
CREATE SEQUENCE SQCUSPROD START WITH 4000 INCREMENT BY 1;
--sequence�for�customer�id
CREATE SEQUENCE SQCUSID START WITH 5000 INCREMENT BY 1;
--sequence for trackid
create sequence sqtracid start with 100;



--creating procedure for input from the customer
CREATE OR REPLACE PROCEDURE SP_NEW_ACCOUNT(
p_customer_id in number,--new
P_customer_name  IN VARCHAR2,	
P_customer_ph_no IN NUMBER,	
P_customer_mail IN VARCHAR2,	
P_aadhar_no IN NUMBER,	
P_PAN_NO IN NUMBER,
P_password IN VARCHAR2,
P_sub_product_id IN NUMBER,
P_status IN VARCHAR2,
P_bank_id IN NUMBER,
P_trans_amount IN NUMBER,
P_trans_type IN VARCHAR,
P_benef_mode IN VARCHAR,	
P_trans_mode IN VARCHAR,
p_flag in number, --new
p_available_balance in number,
P_MESSAGE OUT VARCHAR
) AS
l_customer_id number;
l_cus_product_id number ;
l_available_balance number := 0;
current_balance number := 0;
L_CUS_PRODUCT_ID_2 NUMBER := 0;
count_ number ;
UPDATED_LIMIT NUMBER;
dk number;
BEGIN 
if (p_flag = 1) then
--1st table
INSERT INTO ttsbank_customer(customer_id, customer_name, customer_ph_no, customer_mail, aadhar_no, pan_no, password) 
VALUES(SQCUSID.NEXTVAL, P_customer_name, P_customer_ph_no, P_customer_mail, P_aadhar_no, P_PAN_NO, P_password)
RETURNING CUSTOMER_ID INTO L_CUSTOMER_ID;
--2nd table
INSERT INTO ttsbank_cus_products(cus_product_id, sub_product_id, customer_id, account_no, account_open_date, status, available_balance, bank_id)
VALUES(SQCUSPROD.NEXTVAL, P_sub_product_id, L_CUSTOMER_ID, sqaccno.NEXTVAL, SYSDATE, P_status, P_trans_amount , P_bank_id)
RETURNING CUS_PRODUCT_ID  INTO L_CUS_PRODUCT_ID;
--3rd table
INSERT INTO ttsbank_cus_transactions(cus_trans_id	, cus_product_id,trans_amount,trans_type,trans_on,benef_MODE,trans_mode,account_balance)
VALUES(sqcustrans.NEXTVAL, L_CUS_PRODUCT_ID, P_trans_amount, P_trans_type, SYSDATE, P_benef_mode, P_trans_mode, P_trans_amount)
returning account_balance into l_available_balance;
elsif p_flag = 2 then
--available balance
    select available_balance into current_balance from  ttsbank_cus_products where customer_id =  p_customer_id and sub_product_id =P_sub_product_id;
    select CUS_PRODUCT_ID into L_CUS_PRODUCT_ID_2  from  ttsbank_cus_products where customer_id =  p_customer_id and sub_product_id =P_sub_product_id;
    SELECT A-B INTO UPDATED_LIMIT FROM
    (SELECT(SELECT WITHDRAW_LIMIT FROM ttsbank_sub_products SUB ,ttsbank_cus_products CUS WHERE CUS.SUB_PRODUCT_ID = SUB.SUB_PRODUCT_ID AND CUS.CUSTOMER_ID = p_customer_id) A ,
    (SELECT CASE WHEN SUM(TRANS_AMOUNT) IS NULL THEN P_trans_amount ELSE SUM(TRANS_AMOUNT) END FROM ttsbank_cus_transactions WHERE TRUNC(TRANS_ON) = TRUNC(SYSDATE) AND TRANS_TYPE ='DEBIT' AND CUS_PRODUCT_ID = L_CUS_PRODUCT_ID_2) B
    FROM DUAL);
 --insert if credit 
    if(P_trans_type ='CREDIT')then
        INSERT INTO ttsbank_cus_transactions(cus_trans_id	, cus_product_id,trans_amount,trans_type,trans_on,benef_MODE,trans_mode,account_balance)
        VALUES(sqcustrans.NEXTVAL, L_CUS_PRODUCT_ID_2, P_trans_amount, P_trans_type, SYSDATE, P_benef_mode, P_trans_mode,P_trans_amount+current_balance);
        DBMS_OUTPUT.PUT_LINE('CREDITED SUCCESFULLY');
    --update the current_balance
        UPDATE ttsbank_cus_products 
        SET available_balance = current_balance + P_trans_amount 
        WHERE customer_id = p_customer_id AND sub_product_id = P_sub_product_id;
    --insert if debited
    elsif(p_trans_type ='DEBIT')THEN
        IF P_TRANS_AMOUNT > UPDATED_LIMIT THEN
        DBMS_OUTPUT.PUT_LINE('LIMIT EXCEDED');
        ELSIF SIGN(current_balance - P_trans_amount ) =-1 THEN
        DBMS_OUTPUT.PUT_LINE('INSUFFICIENT BALANCE');
        ELSif UPDATED_LIMIT >= 0 then
        INSERT INTO ttsbank_cus_transactions(cus_trans_id	, cus_product_id,trans_amount,trans_type,trans_on,benef_MODE,trans_mode,account_balance)
        VALUES(sqcustrans.NEXTVAL, L_CUS_PRODUCT_ID_2, P_trans_amount, P_trans_type, SYSDATE, P_benef_mode, P_trans_mode,current_balance-P_trans_amount);
        DBMS_OUTPUT.PUT_LINE('DEBITED SUCCESFULLY');
    --update the current_balance
        UPDATE ttsbank_cus_products 
        SET available_balance = current_balance - P_trans_amount 
        WHERE customer_id = p_customer_id AND sub_product_id = P_sub_product_id;
        else
        dbms_output.put_line('Exceded Limit');
       END if;
    end if;
--create new account for current account
elsif p_flag = 3 then
select count(*) into count_ from 
(select prd.PRODUCT_ID as d from ttsbank_sub_products sub,ttsbank_cus_products cus ,ttsbank_products prd
where sub.product_id = prd.product_id and sub.sub_product_id = P_sub_product_id ) where count_ not in 
(select product_id from ttsbank_cus_products cus ,ttsbank_sub_products sub 
where cus.sub_product_id = sub.sub_product_id
and cus.CUSTOMER_ID = p_customer_id) ;
dbms_output.put_line(count_);
        if count_ > 1 then
        --2nd table
        INSERT INTO ttsbank_cus_products(cus_product_id, sub_product_id, customer_id, account_no, account_open_date, status, available_balance, bank_id)
        VALUES(SQCUSPROD.NEXTVAL, P_sub_product_id, p_customer_id, sqaccno.NEXTVAL, SYSDATE, P_status, P_trans_amount , P_bank_id)
        RETURNING CUS_PRODUCT_ID  INTO L_CUS_PRODUCT_ID;
        --3rd table
        INSERT INTO ttsbank_cus_transactions(cus_trans_id	, cus_product_id,trans_amount,trans_type,trans_on,benef_MODE,trans_mode,account_balance)
        VALUES(sqcustrans.NEXTVAL, L_CUS_PRODUCT_ID, P_trans_amount, P_trans_type, SYSDATE, P_benef_mode, P_trans_mode, P_trans_amount)
        returning account_balance into l_available_balance;
        else 
        dbms_output.put_line('This customer is alredy exist in the bank');
        end if;
elsif p_flag=4 then
select nvl2(
(select P_password from dual where P_password  not in 
(select b from 
(select row_number() over (order by password_changed_on desc) a ,CUSTOMER_PASSWORD b from 
ttssbank_password_track where customer_id = p_customer_id) where a < 3)),0,1) into dk from dual;
if dk=0 then
update ttsbank_customer set password = P_password where customer_id = p_customer_id;
end if;
end if;
P_MESSAGE := 'SUCCESS';
EXCEPTION 
WHEN OTHERS THEN
dbms_output.put_line(sqlerrm);
END;
/

--error handeling
SELECT * FROM USER_ERRORS WHERE NAME = 'SP_NEW_ACCOUNT';

--insertion part to the procedure sn_new_account
DECLARE
MESSAGE VARCHAR(30);
BEGIN
SP_NEW_ACCOUNT(
P_customer_name  => ' PREM KUMAR R',
P_customer_ph_no => 80072681560,
P_customer_mail => 'RPREM1042004@GMAIL.COM',
P_aadhar_no => 123456789012345,
P_PAN_NO =>12345678901223,
P_password =>'Prem@2004',
P_sub_product_id => 3000,
P_status => 'Active',
p_available_balance => 0 ,
P_bank_id => 1000,
P_trans_amount => 100 ,
P_trans_type => 'CREDIT',
P_benef_mode => 'PRASANA@ICICI',
P_trans_mode => 'BANK',
p_flag => 1,
p_customer_id => null,
P_MESSAGE => MESSAGE
);
DBMS_OUTPUT.PUT_LINE(MESSAGE);
END;
/

--insertion part to the procedure sn_new_account flag -2
DECLARE
MESSAGE VARCHAR(30);
BEGIN
SP_NEW_ACCOUNT(
--p_customer_id in number,
P_customer_name  => null,
P_customer_ph_no => null,
P_customer_mail => null,
P_aadhar_no => null,
P_PAN_NO =>null,
P_password =>null,
P_sub_product_id => 3000,
p_customer_id => 5038,
P_status => null,
p_available_balance => 0,
P_bank_id => null,
P_trans_amount => 10,
P_trans_type => 'DEBIT',
P_benef_mode => 'PRASANA@ICICI',
P_trans_mode => 'BANK',
p_flag => 2,
P_MESSAGE => MESSAGE
);
DBMS_OUTPUT.PUT_LINE(MESSAGE);
END;
/

--flag 3 for current account
DECLARE
MESSAGE VARCHAR(30);
BEGIN
SP_NEW_ACCOUNT(
P_customer_name  => 'prem KUMAR R',
P_customer_ph_no => 80072681560,
P_customer_mail => 'RPREM1042004@GMAIL.COM',
P_aadhar_no => 123456789012345,
P_PAN_NO =>12345678901223,
P_password =>'Prem@2004',
P_sub_product_id => 3000,
p_customer_id => 5023,
P_status => 'Active',
p_available_balance => 0 ,
P_bank_id => 1000,
P_trans_amount => 100 ,
P_trans_type => 'CREDIT',
P_benef_mode => 'PRASANA@ICICI',
P_trans_mode => 'BANK',
p_flag => 3,
P_MESSAGE => MESSAGE
);
DBMS_OUTPUT.PUT_LINE(MESSAGE);
END;
/

--flag - 4 for password
DECLARE
MESSAGE VARCHAR(30);
BEGIN
SP_NEW_ACCOUNT(
--p_customer_id in number,
P_customer_name  => null,
P_customer_ph_no => null,
P_customer_mail => null,
P_aadhar_no => null,
P_PAN_NO =>null,
P_password =>'Prem@397',
P_sub_product_id => 3000,
p_customer_id => 5035,
P_status => null,
p_available_balance => 0,
P_bank_id => null,
P_trans_amount => null,
P_trans_type => null,
P_benef_mode => null,
P_trans_mode => null,
p_flag => 4,
P_MESSAGE => MESSAGE
);
DBMS_OUTPUT.PUT_LINE(MESSAGE);
END;
/



--SELECT STATEMENT FOR TABLE
SELECT * FROM ttsbank_customer;

SELECT * FROM ttsbank_cus_products;

SELECT * FROM ttsbank_cus_transactions;

select * from ttsbank_sub_products;

select * from ttssbank_password_track;

select * from ttsbank_products;



--DELETION PART OF ALL THE TABLE DATA
create or replace procedure sp_clean_table as
a number;
begin
delete from ttsbank_cus_transactions;
delete from ttsbank_cus_products;
delete from ttsbank_customer;
commit;
select count(*) into a from ttsbank_customer;
dbms_output.put_line(a);
select count(*) into a from ttsbank_cus_products;
dbms_output.put_line(a);
select count(*) into a from ttsbank_cus_transactions;
dbms_output.put_line(a);
end;
/

exec sp_clean_table;




select * from
(select prd.* from ttsbank_sub_products sub,ttsbank_cus_products cus ,ttsbank_products prd
where sub.product_id = prd.product_id and sub.sub_product_id = 3004);

select product_id from ttsbank_cus_products cus ,ttsbank_sub_products sub 
where cus.sub_product_id = sub.sub_product_id
and cus.CUSTOMER_ID = 5014;


--user_input
select * from 
(select prd.PRODUCT_ID as d from ttsbank_sub_products sub ,ttsbank_products prd
where sub.product_id = prd.product_id and sub.sub_product_id = 3000) where d not in 
(select product_id from ttsbank_cus_products cus ,ttsbank_sub_products sub 
where cus.sub_product_id = sub.sub_product_id
and cus.CUSTOMER_ID = 5015);

--1  insert 
--0 not insert
 
 
 select * from
(select prd.product_id as d from ttsbank_products prd , ttsbank_sub_products sub 
where prd.PRODUCT_ID = sub.PRODUCT_ID and sub.SUB_PRODUCT_ID = 3008)
where d not in
(select product_id from ttsbank_sub_products sub,ttsbank_cus_products cus
where cus.SUB_PRODUCT_ID = sub.SUB_PRODUCT_ID and
cus.CUSTOMER_ID = 5015);


select sum(account_balance) from ttsbank_cus_transactions  where trunc(trans_on)= trunc(sysdate) AND TRANS_TYPE ='DEBIT';

SELECT AVAILABLE_BALANCE FROM ttsbank_cus_products WHERE CUSTOMER_ID = 5016;
 
select CASE WHEN sum(TRANS_AMOUNT) IS NULL THEN 0 ELSE sum(TRANS_AMOUNT) END from ttsbank_cus_transactions TRAN , ttsbank_cus_products CUS
where CUS.CUS_PRODUCT_ID = TRAN.CUS_PRODUCT_ID AND trunc(trans_on)= trunc(sysdate) AND TRANS_TYPE ='DEBIT' AND TRAN.CUS_PRODUCT_ID= 4024;


 SELECT CASE WHEN  A - B IS NULL THEN 0 ELSE A-B END FROM(SELECT (SELECT withdraw_limit FROM  TTSBANK_SUB_PRODUCTS WHERE SUB_PRODUCT_ID =3000 ) A,    
 (SELECT CASE WHEN SUM(TRANS_AMOUNT) IS NULL THEN 0 ELSE SUM(TRANS_AMOUNT) END FROM ttsbank_cus_transactions WHERE TRANS_TYPE ='DEBIT' AND  CUS_PRODUCT_ID= 4034 GROUP BY TRUNC(trans_on) ) B FROM DUAL);

 
SELECT A-B FROM
(SELECT(SELECT WITHDRAW_LIMIT FROM ttsbank_sub_products SUB ,ttsbank_cus_products CUS WHERE CUS.SUB_PRODUCT_ID = SUB.SUB_PRODUCT_ID AND CUS.CUSTOMER_ID = 5035) A ,
(SELECT CASE WHEN SUM(TRANS_AMOUNT) IS NULL THEN 0 ELSE SUM(TRANS_AMOUNT) END FROM ttsbank_cus_transactions WHERE TRUNC(TRANS_ON) = TRUNC(SYSDATE) AND TRANS_TYPE ='DEBIT' AND CUS_PRODUCT_ID = 4037) B
FROM DUAL);

select nvl2(
(select 'prem' from dual where 'prem'  not in 
(select b from 
(select row_number() over (order by password_changed_on desc) a ,CUSTOMER_PASSWORD b from 
ttssbank_password_track where customer_id = 5035) where a < 3)),0,1) as dk from dual;

create or replace procedure delete_pass as
begin
for i in (select unique customer_id from ttssbank_password_track) loop
 delete ttssbank_password_track where customer_id =i.customer_id  and track_id not in
(select track_id from 
(select row_number() over (order by password_changed_on desc) a , track_id   from ttssbank_password_track tts where customer_id = i.customer_id )
 where a < 3) ;
 end loop;
end;
/

 delete ttssbank_password_track where customer_id =5035  and track_id not in
(select track_id from 
(select row_number() over (order by password_changed_on desc) a , track_id   from ttssbank_password_track tts where customer_id = 5035 )
 where a < 3) ;


begin
dbms_scheduler.create_job
(
job_name => 'delete_password',
job_type => 'stored_procedure',
job_action => 'delete_pass',
start_date => '17/feb/2025 3:7:00 PM',
repeat_interval => 'freq = secondly ; interval = 5',
end_date => '25/feb/2025 10:10:00 PM',
auto_drop => true,
comments => 'this deletion has completed'
);
end;
/

exec dbms_scheduler.enable('delete_password');

exec dbms_scheduler.disable('delete_password');

exec dbms_scheduler.drop_job('delete_password');