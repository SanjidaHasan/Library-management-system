SET SERVEROUTPUT ON;
set verify off;

DECLARE
    choice NUMBER;
    active_members_cursor SYS_REFCURSOR;
    books_due_soon_cursor SYS_REFCURSOR;
    total_revenue DECIMAL(10, 2);
    staff_performance_cursor SYS_REFCURSOR;
    popular_books_cursor SYS_REFCURSOR;
    
    m_member_id Members.member_id%TYPE;
    m_member_name Members.name%TYPE;
    m_books_taken Members.no_of_books_taken%TYPE;

    b_borrowing_id Borrowings.borrowing_id%TYPE;
    b_book_id Borrowings.book_id%TYPE;
    b_member_id Borrowings.member_id%TYPE;
    b_return_date Borrowings.return_date%TYPE;

    s_staff_id Staff.staff_id%TYPE;
    s_staff_name Staff.name%TYPE;
    s_books_issued NUMBER;

    p_book_id Books.book_id%TYPE;
    p_title Books.title%TYPE;
    p_author_name Books.author_name%TYPE;
    p_genre Books.genre%TYPE;
    p_borrowing_count NUMBER;
	
	c_borrowing_id Borrowings.borrowing_id%TYPE;
    c_book_id Borrowings.book_id%TYPE;
    c_member_id Borrowings.member_id%TYPE;
    c_borrowing_date Borrowings.borrowing_date%TYPE;
    c_return_date Borrowings.return_date%TYPE;

    u_borrowing_id Borrowings.borrowing_id%TYPE;
    u_book_id Borrowings.book_id%TYPE;
    u_member_id Borrowings.member_id%TYPE;
    u_borrowing_date Borrowings.borrowing_date%TYPE;
    u_return_date Borrowings.return_date%TYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Select the function you want to run:');
    DBMS_OUTPUT.PUT_LINE('1. Most Active Members');
    DBMS_OUTPUT.PUT_LINE('2. Books Due Soon');
    DBMS_OUTPUT.PUT_LINE('3. Total Revenue');
    DBMS_OUTPUT.PUT_LINE('4. Staff Performance Report');
    DBMS_OUTPUT.PUT_LINE('5. Popular Books');
	DBMS_OUTPUT.PUT_LINE('6. Renew Books');
   

    
    choice := &choice;
    
    IF choice = 1 THEN
        
        active_members_cursor := MostActiveMembers;
        LOOP
            FETCH active_members_cursor INTO m_member_id, m_member_name, m_books_taken;
            EXIT WHEN active_members_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('The Active members are: ');
            DBMS_OUTPUT.PUT_LINE('Member ID: ' || m_member_id || ', Name: ' || m_member_name || ', Books Taken: ' || m_books_taken);
        END LOOP;
        CLOSE active_members_cursor;
    ELSIF choice = 2 THEN
       
        books_due_soon_cursor := BooksDueSoon;
        LOOP
            FETCH books_due_soon_cursor INTO b_borrowing_id, b_book_id, b_member_id, b_return_date;
            EXIT WHEN books_due_soon_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------- ');
            DBMS_OUTPUT.PUT_LINE('The Books that are closed to due date: ');
            DBMS_OUTPUT.PUT_LINE('Borrowing ID: ' || b_borrowing_id || ', Book ID: ' || b_book_id || ', Member ID: ' || b_member_id || ', Return Date: ' || b_return_date);
			
        END LOOP;
        CLOSE books_due_soon_cursor;
    ELSIF choice = 3 THEN

        total_revenue := TotalRevenue;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------- ');
        DBMS_OUTPUT.PUT_LINE('Total Revenue: ' || total_revenue);
    ELSIF choice = 4 THEN
     
        staff_performance_cursor := StaffPerformanceReport;
        LOOP
            FETCH staff_performance_cursor INTO s_staff_id, s_staff_name, s_books_issued;
            EXIT WHEN staff_performance_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------- ');
            DBMS_OUTPUT.PUT_LINE('The Staff that has accepted the maximum number of orders:  ');
            DBMS_OUTPUT.PUT_LINE('Staff ID: ' || s_staff_id || ', Name: ' || s_staff_name || ', Books Issued: ' || s_books_issued);
        END LOOP;
        CLOSE staff_performance_cursor;
    ELSIF choice = 5 THEN
   
        popular_books_cursor := PopularBooks;
        LOOP
            FETCH popular_books_cursor INTO p_book_id, p_title, p_author_name, p_genre, p_borrowing_count;
            EXIT WHEN popular_books_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------- ');
            DBMS_OUTPUT.PUT_LINE('Most popular book is ');
            DBMS_OUTPUT.PUT_LINE('Book ID: ' || p_book_id || ', Title: ' || p_title || ', Author: ' || p_author_name || ', Genre: ' || p_genre || ', Borrowing Count: ' || p_borrowing_count);
        END LOOP;
        CLOSE popular_books_cursor;
    ELSIF choice = 6 THEN
        -- Renew Book
        DECLARE
            borrowing_id INT;
        BEGIN
         
            borrowing_id := &borrowing_id;
            RenewBook(borrowing_id);
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid choice.');
	
    END IF;
END;
/

CREATE OR REPLACE FUNCTION MostActiveMembers RETURN SYS_REFCURSOR AS
    active_members_cursor SYS_REFCURSOR;
BEGIN
    OPEN active_members_cursor FOR
    SELECT M.member_id, M.name, M.no_of_books_taken
    FROM Members M
    ORDER BY M.no_of_books_taken DESC;

    RETURN active_members_cursor;
END;
/
CREATE OR REPLACE FUNCTION BooksDueSoon RETURN SYS_REFCURSOR AS
    books_due_soon_cursor SYS_REFCURSOR;
BEGIN
    OPEN books_due_soon_cursor FOR
    SELECT B.borrowing_id, B.book_id, B.member_id, B.return_date
    FROM Borrowings B
    WHERE B.actual_return_date IS NULL AND B.return_date <= SYSDATE + 3;

    RETURN books_due_soon_cursor;
END;
/

CREATE OR REPLACE FUNCTION TotalRevenue RETURN DECIMAL AS
    total_revenue DECIMAL(10, 2) := 0.0;
BEGIN
    SELECT SUM(fine) + SUM(fee) INTO total_revenue
    FROM Borrowings;

    RETURN total_revenue;
END;
/
CREATE OR REPLACE FUNCTION StaffPerformanceReport RETURN SYS_REFCURSOR AS
    staff_performance_cursor SYS_REFCURSOR;
BEGIN
    OPEN staff_performance_cursor FOR
    SELECT S.staff_id, S.name, COUNT(*) AS books_issued
    FROM Borrowings B
    JOIN Staff S ON B.staff_id = S.staff_id
    WHERE B.actual_return_date IS NOT NULL
    GROUP BY S.staff_id, S.name
    ORDER BY books_issued DESC;

    RETURN staff_performance_cursor;
END;
/
CREATE OR REPLACE FUNCTION PopularBooks RETURN SYS_REFCURSOR AS
    popular_books_cursor SYS_REFCURSOR;
BEGIN
    OPEN popular_books_cursor FOR
    SELECT B.book_id, BO.title, BO.author_name, BO.genre, COUNT(*) AS borrowing_count
    FROM Borrowings B
    JOIN Books BO ON B.book_id = BO.book_id
    WHERE B.actual_return_date IS NOT NULL
    GROUP BY B.book_id, BO.title, BO.author_name, BO.genre
    ORDER BY borrowing_count DESC;

    RETURN popular_books_cursor;
END;
/

CREATE OR REPLACE PROCEDURE RenewBook(p_borrowing_id IN INT) AS
    return_date DATE;
BEGIN
    SELECT borrowing_date + 14 INTO return_date
    FROM Borrowings
    WHERE borrowing_id = p_borrowing_id;

    UPDATE Borrowings
    SET return_date = return_date + 7 -- Renew for 7 days
    WHERE borrowing_id = p_borrowing_id;

    DBMS_OUTPUT.PUT_LINE('Book with Borrowing ID ' || p_borrowing_id || ' has been renewed.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Borrowing ID not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error occurred: ' || SQLERRM);
END;
/
commit;
