--master table ttsbank_banks
create table ttsbank_banks(
bank_id number,
bank_code varchar2(30) not null,
bank_location varchar2(30) not null,
is_headoffice char(1),
constraint bank_id_pk primary key(bank_id),
constraint bank_code_uk unique(bank_code),
constraint is_headoffice_ck check(is_headoffice = 'y' or is_headoffice = 'Y' or is_headoffice = 'n' or is_headoffice ='N')
);

alter table ttsbank_banks modify bank_code varchar2(30);

--master table ttsbank_products
create table ttsbank_products(
product_id number,
product_name varchar2(30) not null,
product_code varchar2(30) not null,
constraint product_id_pk primary key(product_id),
constraint product_codeuk unique(product_code)
);

--master table ttsbank_sub_products
create table ttsbank_sub_products(
sub_product_id number,
product_id number,
feature varchar2(30) not null,
balance_limit number not null,
withdraw_limit number not null,
constraint sub_product_id_pk primary key(sub_product_id),
constraint product_id_fk foreign key(product_id) references ttsbank_products(product_id)
);

--master table ttsbank_employees
create table ttsbank_employees(
employee_id number,
employee_name varchar2(30) not null,
bank_id number,
constraint employee_id_pk primary key(employee_id),
constraint bank_id_fk foreign key(bank_id) references ttsbank_banks(bank_id)
);



create table ttsbank_customer(
customer_id number,
customer_name varchar2(30) not null,
customer_ph_no number not null,
customer_mail varchar2(40) not null,
aadhar_no number not null,
pan_no varchar2(30)not null,
password varchar2(50) not null,
constraint customer_id_pk primary key(customer_id)
);


create table ttsbank_cus_products(
cus_product_id number,
sub_product_id number,
customer_id number,
account_no number,
account_open_date date ,
status varchar2(30),
available_balance number ,
bank_id number,
constraint cus_product_id_pk primary key(cus_product_id),
constraint sub_product_id_fk foreign key(sub_product_id) references ttsbank_sub_products(sub_product_id),
constraint customer_id_fk foreign key(customer_id) references ttsbank_customer(customer_id),
constraint bank_id_cus_pro_fk  foreign key(bank_id) references ttsbank_banks(bank_id)
);


create table ttsbank_cus_transactions(
cus_trans_id number,
cus_product_id number,
trans_amount number ,
trans_type VARCHAR(50),
trans_on date ,
benef_mode varchar2(30) ,
trans_mode varchar2(30) ,
account_balance number ,
constraint cus_trand_id_pk primary key(cus_trans_id),
constraint cus_productt_id_pk foreign key(cus_product_id) references ttsbank_cus_products(cus_product_id)
);

ALTER TABLE ttsbank_cus_transactions MODIFY TRANS_TYPE VARCHAR(50);

create table ttssbank_password_track(
track_id number,
customer_id number,
customer_password varchar2(30),
password_changed_on date ,
constraint track_id_pk primary key(track_id),
constraint customer_id_pass_fk foreign key(customer_id) references ttsbank_customer(customer_id)
);

