/*
drop table Staff_Clerk;
drop table Members_Stand;
drop table Borrowings_Returned;
drop table Borrowings_NotReturned;
drop table Books_Fic;
drop table Books_Nov;
drop table Books_En;
drop table Books_Mys;
drop table Borrowings_fee;
drop table Borrowings_fine;
*/ 
CREATE TABLE Staff_Clerk AS
SELECT * FROM Staff WHERE position = 'clerk';

CREATE TABLE Members_Stand AS
SELECT * FROM Members WHERE membership_type = 'Standard';

CREATE TABLE Members_active AS
SELECT member_id,membership_type,no_of_books_taken,name,PAID_FEES
FROM Members WHERE no_of_books_taken >0;

CREATE TABLE Borrowings_Returned AS
SELECT * FROM Borrowings WHERE actual_return_date IS NOT NULL;

CREATE TABLE Borrowings_fee AS
SELECT member_id,fee,borrowing_date FROM Borrowings WHERE fee<=60;

CREATE TABLE borrowings_fine AS
SELECT member_id,fine,borrowing_date,return_date,actual_return_date FROM Borrowings WHERE fine<=50 AND actual_return_date is not null;


CREATE TABLE Books_Fic AS
SELECT * FROM Books WHERE genre = 'Fiction';

CREATE TABLE Books_Nov AS
SELECT * FROM Books WHERE genre = 'Novel';

























SELECT * FROM Staff_clerk;
SELECT * FROM Members_Stand;
SELECT * FROM Members_active;
SELECT * FROM Borrowings WHERE actual_return_date IS NOT NULL;
SELECT * FROM Books_fic;
SELECT * FROM Books WHERE genre = 'Novel';
select * from borrowings_fee;
SELECT * FROM Borrowings_fine;

commit;