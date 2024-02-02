# Library Management System
Library management system for DDS project using pl/SQL. In the final project, pdf has all the demonstrations.
This is for the server.

## Global Schema

### Books Table
- **book_id**: (Primary Key) Unique identifier for each book.
- **title**: Title of the book.
- **author_name**: Name of the book's author.
- **publication_date**: Date when the book was published.
- **available_book**: Number of available copies of the book.
- **genre**: Genre or category of the book.
- **age_group**: Target age group for the book.
- **total_book**: Total number of copies of the book in the library.

### Members Table
- **member_id**: (Primary Key) Unique identifier for each member.
- **name**: Name of the member.
- **semester**: Semester in which the member is enrolled.
- **year**: Year of enrollment.
- **contact_details**: Contact information for the member.
- **membership_type**: Type of library membership.
- **no_of_books_taken**: Number of books currently borrowed by the member.
- **total_fines**: Total fines accrued by the member.
- **paid_fees**: Fees paid by the member.

### Borrowings Table
- **borrowing_id**: (Primary Key) Unique identifier for each borrowing transaction.
- **book_id (fk)**: Foreign key referencing the book being borrowed.
- **member_id (fk)**: Foreign key referencing the member making the borrowing.
- **fee**: Fee associated with the borrowing transaction.
- **borrowing_date**: Date when the book was borrowed.
- **fine**: Fine imposed on the borrowing transaction.
- **return_date**: Expected return date for the borrowed book.
- **actual_return_date**: Actual date when the book was returned.
- **staff_id (fk)**: Foreign key referencing the staff member managing the borrowing.

### Staff Table
- **staff_id**: (Primary Key) Unique identifier for each staff member.
- **name**: Name of the staff member.
- **position**: Position or role of the staff member.
- **contact_details**: Contact information for the staff member.
