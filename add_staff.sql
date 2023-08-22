--ADD staff

SET SERVEROUTPUT ON
SET VERIFY OFF;

DECLARE
    staff_id Staff.staff_id%TYPE;
    name Staff.name%TYPE;
    position  Staff.position %TYPE;
    contact_details Staff.contact_details%TYPE;
    
BEGIN
 

   name :='&name';
    position  :='&position';
    contact_details :='&contact_details';
    
    SELECT MAX(staff_id) + 1 INTO staff_id FROM staff@site_link;
    IF staff_id IS NULL THEN
        staff_id := 1;
    END IF;
    INSERT INTO staff@site_link(staff_id, name, position, contact_details)
    VALUES (staff_id, name, position, contact_details);

    DBMS_OUTPUT.PUT_LINE('New staff added successfully.');

END;
/
select * from staff union select * from Staff@site_link;

commit;
