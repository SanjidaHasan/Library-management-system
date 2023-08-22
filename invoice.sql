-- Create a procedure to generate an invoice
CREATE OR REPLACE PROCEDURE generate_invoice(user_name_in IN VARCHAR2) IS
BEGIN
  FOR borrowing_row IN (SELECT * FROM Borrowings@site_link WHERE member_id IN (SELECT member_id FROM Members@site_link WHERE name = user_name_in)) LOOP
    DBMS_OUTPUT.PUT_LINE('--------------INVOICE---------------');
    DBMS_OUTPUT.PUT_LINE('User Name: ' || user_name_in);

    -- Get book information based on book_id
    DECLARE
      book_title VARCHAR2(30);
      book_author VARCHAR2(30);
    BEGIN
      SELECT title, author_name INTO book_title, book_author FROM Books@site_link WHERE book_id = borrowing_row.book_id;
      DBMS_OUTPUT.PUT_LINE('Book Title: ' || book_title);
      DBMS_OUTPUT.PUT_LINE('Author: ' || book_author);
    END;

    DBMS_OUTPUT.PUT_LINE('Borrowing Date: ' || TO_CHAR(borrowing_row.borrowing_date, 'dd-mon-yyyy'));
    DBMS_OUTPUT.PUT_LINE('Return Date: ' || TO_CHAR(borrowing_row.return_date, 'dd-mon-yyyy'));

    -- Calculate and display fine, if any
    IF borrowing_row.fine > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Fine: ' || borrowing_row.fine);
    END IF;

    -- Get staff information based on staff_id
    DECLARE
      staff_name VARCHAR2(20);
    BEGIN
      SELECT name INTO staff_name FROM Staff@site_link WHERE staff_id = borrowing_row.staff_id;
      DBMS_OUTPUT.PUT_LINE('Staff Name: ' || staff_name);
    END;

    DBMS_OUTPUT.PUT_LINE('===========================');
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No invoice found for user: ' || user_name_in);
END;
/
SHOW ERRORS;

SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE 
  name VARCHAR2(50) := '&ENTER_USER_NAME';


BEGIN
  generate_invoice(name);
END;
/
commit;