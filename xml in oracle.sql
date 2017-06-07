drop table Children;
drop table Employees;
CREATE TABLE Employees (
 id number(20) not null primary key,
 firstname varchar(255) not null,
 lastname varchar(255) not null,
 hiredate varchar(255) not null
 
);

create table Children(
id number(20) not null primary key ,
firstname varchar(255) not null,
lastname varchar(255)not null,
birthdate varchar(255) not null,
employee_id number(20) references Employees(id)
);
/


create or replace directory ROOT as '/sqlfile';
/
set serveroutput on;

CREATE OR REPLACE PROCEDURE insert_children_from_xml
IS
    x XMLType;
    children XMLType;
    hFile utl_file.file_type;
    xmlString varchar2(32000);
    tmpString varchar2(10000);
BEGIN
    hFile := utl_file.fopen('ROOT','3u60y','R');
    
    loop
        begin
            utl_file.get_line(hFile, tmpString);
            xmlString:= xmlString || tmpString;
            dbms_output.put_line(xmlString);
            
        exception
            when NO_DATA_FOUND then
                exit;
        end;
    end loop;
    utl_file.fclose(hFile);

    x := XMLType(xmlString);
    FOR emp_ IN (
    SELECT ExtractValue(Value(p),'/employee/id/text()') as id,
            ExtractValue(Value(p),'/employee/firstname/text()') as firstname,
            ExtractValue(Value(p),'/employee/lastname/text()') as lastname,
            ExtractValue(Value(p),'/employee/department/text()') as department,
            ExtractValue(Value(p),'/employee/hiredate/text()') as hiredate,
            ExtractValue(Value(p), '/employee/children') as children
    FROM   TABLE(XMLSequence(Extract(x,'employees/employee'))) p
-- VORSCHLAG    CROSS JOIN TABLE(extract(Value(p), '/employee/children')) c
    ) LOOP
        
        
        children := XMLType(emp_.children);
        dbms_output.put_line(emp_.firstname);
        dbms_output.put_line('test');
            insert into employees(id,firstname,lastname,hiredate)
                values (emp_.id,emp_.firstname,emp_.lastname,emp_.hiredate);
 
        --    dbms_output.put_line(emp_.name);

        FOR child_ IN (
        SELECT ExtractValue(Value(a), '/child/id/text()') as id,
               ExtractValue(Value(a), '/child/firstname/text()') as firstname,
               ExtractValue(Value(a), '/child/lastname/text()') as lastname,
               ExtractValue(Value(a), '/child/birthdate/text()') as birthdate
        FROM TABLE(XMLSequence(Extract(children, '/children/child'))) a
        ) LOOP
            insert into children(id, firstname, lastname, birthdate,employee_id) 
                values (child_.id, child_.firstname, child_.lastname,child_.birthdate, emp_.id);
        --    dbms_output.put_line(child_.name);
        END LOOP;
    END LOOP;
END;
/

--select * from children;
/
select * from Children;
exec insert_children_from_xml;

