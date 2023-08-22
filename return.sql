SET SERVEROUTPUT ON;
SET VERIFY OFF;
CREATE OR REPLACE PROCEDURE Return_Book (
    p_borrowing_id IN INT,
    p_actual_return_date IN DATE
) AS
    p_book_id INT;
    p_member_id INT;
    p_fine DECIMAL(10, 2);
    p_fee DECIMAL(10, 2);
    p_staff_id INT;
BEGIN
    -- Check if the borrowing ID exists and is not returned already
    SELECT book_id, member_id, fine, fee, staff_id
    INTO p_book_id, p_member_id, p_fine, p_fee, p_staff_id
    FROM Borrowings@site_link
    WHERE borrowing_id = p_borrowing_id AND actual_return_date IS NULL;

    IF p_book_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Borrowing ID not found or the book has already been returned.');
        RETURN;
    END IF;

    -- Update the Borrowings table with actual return date
    UPDATE Borrowings@site_link
    SET actual_return_date = p_actual_return_date
    WHERE borrowing_id = p_borrowing_id;

    -- Update the Members table with the book return details
    BEGIN
        UPDATE Members@site_link
        SET
            no_of_books_taken = no_of_books_taken - 1,
            total_fines = total_fines + p_fine,
            paid_fees = paid_fees - p_fee
        WHERE member_id = p_member_id;
    EXCEPTION
        WHEN OTHERS THEN
            -- If there is an error updating Members table, undo the previous Borrowings table update
            UPDATE Borrowings@site_link
            SET actual_return_date = NULL
            WHERE borrowing_id = p_borrowing_id;
            DBMS_OUTPUT.PUT_LINE('Error occurred while updating Members table: ' || SQLERRM);
            RETURN;
    END;

    -- Update the Books table to increase available_book count
    BEGIN
        UPDATE Books@site_link
        SET available_book = available_book + 1
        WHERE book_id = p_book_id;
    EXCEPTION
        WHEN OTHERS THEN
            -- If there is an error updating Books table, undo the previous Borrowings and Members table updates
            UPDATE Borrowings@site_link
            SET actual_return_date = NULL
            WHERE borrowing_id = p_borrowing_id;
            UPDATE Members@site_link
            SET
                no_of_books_taken = no_of_books_taken + 1,
                total_fines = total_fines - p_fine,
                paid_fees = paid_fees + p_fee
            WHERE member_id = p_member_id;
            DBMS_OUTPUT.PUT_LINE('Error occurred while updating Books table: ' || SQLERRM);
            RETURN;
    END;

    DBMS_OUTPUT.PUT_LINE('Book returned successfully.');
    DBMS_OUTPUT.PUT_LINE('Borrowing ID: ' || p_borrowing_id);
    DBMS_OUTPUT.PUT_LINE('Actual Return Date: ' || p_actual_return_date);
    DBMS_OUTPUT.PUT_LINE('Fine: ' || p_fine);
    DBMS_OUTPUT.PUT_LINE('Fee: ' || p_fee);
    DBMS_OUTPUT.PUT_LINE('Staff ID: ' || p_staff_id);
	DBMS_OUTPUT.PUT_LINE('The book is returned successfully');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Borrowing ID not found or the book has already been returned.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error occurred: ' || SQLERRM);
END;
/
DECLARE
    borrowing_id INT := &borrowing_id; 
    actual_return_date DATE := SYSDATE;
BEGIN
    Return_Book(borrowing_id, actual_return_date);
END;
/

 select * from borrowings@site_link;
commit;