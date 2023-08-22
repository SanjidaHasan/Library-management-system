
CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR2(30) NOT NULL,
    author_name VARCHAR2(30) NOT NULL,
    publication_date DATE NOT NULL,
    available_BOOK NUMBER(4) NOT NULL,
    genre VARCHAR2(15) NOT NULL,
    AGE_GROUP VARCHAR2(10) NOT NULL,
    total_BOOK NUMBER(4) NOT NULL
);


CREATE TABLE Staff (
staff_id INT PRIMARY KEY,
name VARCHAR2(20) NOT NULL, 
position VARCHAR2(10) NOT NULL,
contact_details VARCHAR2(15) NOT NULL);

 
 CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    name VARCHAR2(15) NOT NULL,
    semester VARCHAR2(5) NOT NULL,
    year VARCHAR2(5) NOT NULL,
    contact_details VARCHAR2(15) NOT NULL,
    membership_type VARCHAR2(10) NULL,
    no_of_books_taken NUMBER(4) NULL,
    total_fines DECIMAL(10, 2) NULL,
    PAID_FEES DECIMAL(10, 2) NULL
);

CREATE TABLE Borrowings(
 FOREIGN KEY (book_id) REFERENCES Books (book_id), 
 FOREIGN KEY (member_id) REFERENCES Members (member_id), 
 FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
 borrowing_id INT PRIMARY KEY,
 book_id INT NOT NULL,
 member_id INT NOT NULL,
 borrowing_date DATE NOT NULL,
 fee DECIMAL(10, 2) NOT NULL,  
 return_date DATE NOT NULL, 
 actual_return_date DATE, 
 fine DECIMAL(10, 2) NOT NULL,
 staff_id INT NOT NULL
 );
commit;

