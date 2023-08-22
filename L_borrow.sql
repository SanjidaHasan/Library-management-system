SET SERVEROUTPUT ON;
SET VERIFY OFF;
CREATE OR REPLACE PACKAGE LibraryPackage AS
    PROCEDURE BorrowBook (
        p_book_id IN INT,
        p_member_id IN INT,
        p_staff_id IN INT
    );

    FUNCTION CalculateMembershipType (no_of_books_taken IN NUMBER) RETURN VARCHAR2;
    
    
END LibraryPackage;
/

CREATE OR REPLACE PACKAGE BODY LibraryPackage AS
    PROCEDURE BorrowBook (
        p_book_id IN INT,
        p_member_id IN INT,
        p_staff_id IN INT
    ) AS
        borrowing_id INT;
        borrowing_date DATE := SYSDATE;
        fee DECIMAL(10, 2) := 0.0;
        return_date DATE := NULL;
        actual_return_date DATE := NULL;
        fine DECIMAL(10, 2) := 0.0;
        membership_type VARCHAR2(10);
        no_of_books_taken NUMBER(4);
        total_fines DECIMAL(10, 2);
        total_fees DECIMAL(10, 2);
        paid_fees DECIMAL(10, 2);
        genre VARCHAR2(15);
        BORROW_COUNT NUMBER;

        max_books_allowed NUMBER(4) := 5;

        -- Cursor to fetch member details
        CURSOR MemberCursor IS
            SELECT membership_type, no_of_books_taken, total_fines, paid_fees
            FROM Members@site_link
            WHERE member_id = p_member_id ;

    BEGIN
        -- Check if the member is eligible to borrow more books
        OPEN MemberCursor;
        FETCH MemberCursor INTO membership_type, no_of_books_taken, total_fines, paid_fees;
        CLOSE MemberCursor;

        IF no_of_books_taken >= max_books_allowed THEN
            DBMS_OUTPUT.PUT_LINE('Member has already borrowed the maximum allowed number of books.');
            RETURN; 
        END IF;

        IF total_fines - paid_fees > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Member has unpaid fines. Please clear the fines first.');
            RETURN;
        END IF;

        -- Check if the book is already borrowed
        SELECT COUNT(*) INTO BORROW_COUNT FROM Borrowings@site_link WHERE book_id = p_book_id AND member_id = p_member_id AND return_date IS NULL;
        IF BORROW_COUNT = 1 THEN
            DBMS_OUTPUT.PUT_LINE('THE USER ALREADY HAS THIS BOOK.');
            RETURN;
        ELSE
            DBMS_OUTPUT.PUT_LINE('ISSUING BOOK TO MEMBER ' || p_member_id  || '.');
        END IF;

        SELECT genre INTO genre FROM Books@site_link WHERE book_id = p_book_id;

        IF genre = 'Fiction' THEN
            fee := 50.0; 
        ELSE
            fee := 100.0;
        END IF;

        IF CalculateMembershipType(no_of_books_taken) = 'Premium' THEN
            -- Apply 10% discount to all premium members
            fee := fee * 0.9;

            -- Additional discounts on specific dates
            IF TO_CHAR(borrowing_date, 'MMDD') = '0211' THEN
                -- Apply extra 21% discount on 21st February
                fee := fee * 0.79;
            ELSIF TO_CHAR(borrowing_date, 'MMDD') = '0808' THEN
                -- Apply 15% discount on 15th August
                fee := fee * 0.85;
            ELSIF TO_CHAR(borrowing_date, 'MMDD') = '1216' THEN
                -- Apply 16% discount on 16th December
                fee := fee * 0.84;
            END IF;
        END IF;

        SELECT NVL(MAX(borrowing_id), 0) + 1 INTO borrowing_id FROM Borrowings@site_link;
        return_date := borrowing_date + 14; 

        -- Insert the borrowing record into the Borrowings table
        BEGIN
            INSERT INTO Borrowings@site_link (borrowing_id, book_id, member_id, borrowing_date, fee, return_date, actual_return_date, fine, staff_id)
            VALUES (borrowing_id, p_book_id, p_member_id, borrowing_date, fee, return_date, actual_return_date, fine, p_staff_id);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error occurred while inserting borrowing record: ' || SQLERRM);
                RETURN;
        END;

        -- Update Members table with borrowing details
        BEGIN
            UPDATE Members@site_link
            SET
                no_of_books_taken = no_of_books_taken + 1,
                total_fines = total_fines + fine,
                PAID_FEES= PAID_FEES + fee
            WHERE member_id = p_member_id;
        EXCEPTION
            WHEN OTHERS THEN
                -- If there is an error updating Members table, undo the previous Borrowings table insertion
                DELETE FROM Borrowings WHERE borrowing_id = borrowing_id;
                DBMS_OUTPUT.PUT_LINE('Error occurred while updating Members table: ' || SQLERRM);
                RETURN;
        END;

        BEGIN
            UPDATE Books@site_link
            SET
                available_book = available_book - 1
            WHERE book_id = p_book_id;
        END;

        DBMS_OUTPUT.PUT_LINE('Book borrowed successfully.');
        DBMS_OUTPUT.PUT_LINE('Borrowing ID: ' || borrowing_id);
        DBMS_OUTPUT.PUT_LINE('Return Date: ' || return_date);
        DBMS_OUTPUT.PUT_LINE('Fee: ' || fee);
        DBMS_OUTPUT.PUT_LINE('Fine: ' || fine);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Member or Book not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Unexpected error occurred: ' || SQLERRM);
    END;
  
    FUNCTION CalculateMembershipType (no_of_books_taken IN NUMBER) RETURN VARCHAR2 AS
    BEGIN
        IF no_of_books_taken > 3 THEN
            RETURN 'Premium';
        ELSE
            RETURN 'Standard';
        END IF;
    END;
END LibraryPackage;
/
DECLARE
    book_id INT;
    member_id INT;
    staff_id INT;
BEGIN
    book_id := &book_id;
    member_id := &member_id;
    staff_id := &staff_id;
    LibraryPackage.BorrowBook(book_id, member_id, staff_id);
END;
/


CREATE OR REPLACE TRIGGER UpdateMembershipTypeTrigger
AFTER INSERT ON Borrowings@site_link
FOR EACH ROW
DECLARE
    no_of_books_taken NUMBER(4);
BEGIN
    SELECT no_of_books_taken INTO no_of_books_taken
    FROM Members@site_link
    WHERE member_id = :NEW.member_id;
    IF no_of_books_taken > 3 THEN
        UPDATE Members@site_link
        SET membership_type = 'Premium'
        WHERE member_id = :NEW.member_id;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Member not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error occurred: ' || SQLERRM);
END;
/
select * from borrowings@site_link;
commit;