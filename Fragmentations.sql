/*
drop table staff_admin;
drop table members_prem;
drop table books_mys;
drop table books_en;
drop table borrowings_notReturned;
*/
create table staff_admin as 
select * from staff@site_link where position= 'Admin';

create table members_prem as 
select * from members@site_link where membership_type= 'Premium';

create table members_inactive as 
select member_id,membership_type,no_of_books_taken,name,paid_fees from members@site_link where no_of_books_taken<1;

create table borrowings_notReturned as 
select * from borrowings@site_link where actual_return_date is  null;

create table books_mys AS
select * from books@site_link where genre = 'Mystry';

create table books_en AS
select * from books@site_link where genre = 'Engineering';
drop table borrowings_fee_more;
create table borrowings_fee_more as 
select member_id,fee,borrowing_date from borrowings@site_link where fee>60;

drop table borrowings_fine_more;
create table borrowings_fine_more as 
select member_id,fee,borrowing_date,return_date,actual_return_date from borrowings@site_link where fine>50 AND actual_return_date is not null;
























select * from staff_admin;
select * from members@site_link where membership_type= 'Premium';
select * from members_inactive;
select * from borrowings@site_link where actual_return_date is null;

select * from books@site_link where genre = 'Mystry';
select * from books@site_link where genre = 'Engineering';

select * from borrowings_fee_more;
select * from borrowings_fine_more;