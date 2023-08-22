--ADD BOOKS

SET SERVEROUTPUT ON
SET VERIFY OFF;

DECLARE
    book_id Books.book_id%TYPE;
    title Books.title%TYPE;
    author_name Books.author_name%TYPE;
    publication_date Books.publication_date%TYPE;
    available_book Books.available_book%TYPE;
    genre Books.genre%TYPE;
    age_group Books.age_group%TYPE;
    total_book Books.total_book%TYPE;
BEGIN
 

    title := '&Title';
    author_name := '&Author';
    publication_date := TO_DATE('&Date', 'YYYY-MM-DD');
    available_book := &Available;
    genre := '&Genre';
    Age_Group:= '&Age_Group';
    total_book := &Total;
    SELECT MAX(BOOK_id) + 1 INTO book_id FROM books@site_link;
    IF BOOK_id IS NULL THEN
        BOOK_id := 1;
    END IF;
    INSERT INTO Books@site_link (book_id, title, author_name, publication_date, available_book, genre, age_group, total_book)
    VALUES (book_id, title, author_name, publication_date, available_book, genre, age_group, total_book);

    DBMS_OUTPUT.PUT_LINE('New book added successfully.');
	

END;
/

select * from books union select * from books@site_link;
commit;
