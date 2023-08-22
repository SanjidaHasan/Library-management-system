-- For adding a member
SET SERVEROUTPUT ON;
SET VERIFY OFF;
DECLARE
    member_id Members.member_id%TYPE;
    name Members.name%TYPE;
    semester Members.semester%TYPE;
    year Members.year%TYPE;
    contact_details Members.contact_details%TYPE;
    membership_type Members.membership_type%TYPE;
	no_of_books_taken Members.no_of_books_taken%type;
	total_fines Members.total_fines%type;
	paid_fees Members.paid_fees%type;
BEGIN
    name := '&member_name';
    semester := '&semester';
    year := '&year';

    contact_details := '&contact_details';
    membership_type := '&membership_type';

    SELECT MAX(member_id) + 1 INTO member_id FROM Members@site_link;
    IF member_id IS NULL THEN
        member_id := 1;
    END IF;

    INSERT INTO Members@site_link (member_id, name, semester, year, contact_details, membership_type, no_of_books_taken, total_fines,paid_fees)
    VALUES (member_id, name,semester, year, contact_details, membership_type, 0, 0,0);

    DBMS_OUTPUT.PUT_LINE('Member ' || name || ' added successfully. Member ID: ' || member_id);
	
	EXCEPTION
	WHEN OTHERS THEN
           
            DBMS_OUTPUT.PUT_LINE('Error occurred while inserting borrowing record: ' || SQLERRM);
            RETURN;

END;
/
select * from members union select * from members@site_link;
commit;