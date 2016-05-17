
--create type TranscriptRecord as (code text, term text, course integer, prog text, name text, mark integer, grade text, uoc integer, rank integer, totalEnrols integer);


-----------------------------
create or replace function Q1_uoc( int, int)
returns int
as
$$
declare r int;
declare fenshu int;
declare chenji char(2);

begin
select mark,grade into fenshu,chenji
from course_enrolments
where student = $1 
and course = $2;
if fenshu is not null and (chenji = 'SY' or chenji = 'PC' or chenji = 'PS'
or chenji = 'CR' or chenji = 'DN' or chenji = 'HD' or chenji ='PT' or chenji = 'A' or chenji = 'B') 
then 
 select uoc into r
 from subjects,courses
 where courses.id = $2
 and subjects.id = courses.subject;
 return r;
 else
 return 0;
 end if;
 end;
$$
language plpgsql
----------------------------

------------------------
create or replace function Q1_course_code(integer)
returns char(8)
as $$
	select code 
	from subjects
	where id=$1
$$ language sql;

create or replace function Q1_term(integer)
returns text
as $$
	select right(year||lower(term),4)
	from semesters
	where id = $1
$$ language sql;

create or replace function Q1_id(integer)
returns integer
as $$
	select id
	from people
	where unswid = $1
$$ language sql;
----------------------

--------------------
create or replace view Q1_all
as
select course_enrolments.student,
course_enrolments.course,
course_enrolments.mark,
course_enrolments.grade,
name
subject,
semester 
from (courses left join course_enrolments on course = courses.id)
-------------
create or replace function Q1_name(int)
returns text
as $$
select name from subjects where id = $1
$$ language sql;
-----------

-----------------------
create or replace function Q1_rank(ke integer)
returns table(student integer,rank bigint)
as $$
select student,rank() over (order by mark DESC)from course_enrolments
where course = ke; 
$$ language sql
----------------
create or replace function Q1_program_code(int)
returns char(4)
as $$
select code from programs
where id = $1;
$$ language sql
----------------
create or replace function Q1_student_rank(stu integer, ke integer)
returns bigint
as $$
select rank from Q1_rank(ke)
where student = stu; 
$$ language sql
-----------------------------
create or replace function Q1_total(integer)
returns bigint
as $$
select count(*) from course_enrolments
where mark is not null 
and course = $1
$$
language sql
---------------------

---------------------------------
create type TranscriptRecord as (code char(8), term char(4), course integer, prog char(4), name text, mark integer, grade char(2), uoc integer, rank integer, totalEnrols integer);

create or replace function Q1(integer)
	returns setof TranscriptRecord
as $$
declare
r TranscriptRecord%rowtype;
begin
for r in
select  Q1_course_code(subject), 
Q1_term(Q1_all.semester),
course,
Q1_program_code(program),
Q1_name(subject),
Q1_all.mark,
grade,
Q1_uoc(Q1_id($1),course),
Q1_student_rank(Q1_id($1),course ) ,
Q1_total(course)

from Q1_all, program_enrolments
where Q1_all.student = Q1_id($1)
and Q1_all.semester = program_enrolments.semester
and Q1_all.student = program_enrolments.student loop 
return next r;
end loop;
return;
end
$$
language plpgsql;


-- Q2: ...

------------

----------------------------

-------------------------

--------------------------

--------------------------------
create type MatchingRecord as ("table" text, "column" text, nexamples integer);

create or replace function Q2("table" text, pattern text) 
	returns setof MatchingRecord
as $$
declare 
	att text;
	r MatchingRecord%rowtype;
	a int;
	s text;
begin

	for att in  
		select column_name from information_schema.columns where table_name=$1
		loop
			execute 'select count(*) from '||$1||' where ' 
					||'cast('||att||' as text)'||'~ '''||$2||''''
			into a;
			
			if a != 0 then
			select  $1, att, a into r;
			return next r ;
			end if;
			end loop;
			return;
end;
$$ language plpgsql
 
-- Q3: ...
-------------------
create or replace function Q3_staff_role(int)
returns text
as $$
	select name from staff_roles where id = $1
     $$ language sql
---------------------
create or replace function Q3_org_name(int)
returns char(64)
as $$
	select name from orgunits where id = $1
     $$ language sql
-----------------------
create or replace function Q3_person(integer) 
	returns setof EmploymentRecord 
as $$
 declare person int;
	       n int;
	       emp record;
	       emp2 record;
	       t int :=0;
	       result text := '';
	       cur_end text := ' ';
	     

 begin 
	for person in select staff from affiliations where orgunits = $1 group by (staff)
	loop 
	        execute 'select count(*) from affiliations '||' where staff = '||person into n ; 	     
	        if n > 1 then		
			for emp in select * from affiliations where staff = person order by starting 
				loop
				if (cur_end != ' ') then
					if cur_end > emp.end then
						
				
				
				
				end loop;
			if t > 1 then
				for a in select * from affiliations where staff = person order by starting
				loop
					if a.starting is null then
						result = result ||Q3_staff_role(a.staff)||', '||Q3_org_name(a.orgunit)||'('||a.starting||'..)'||E'\n'
					else
						result = result ||Q3_staff_role(a.staff)||', '||Q3_org_name(a.orgunit)||'('||a.starting||'..'||a.ending||')'||E'\n'
				end loop;
			end if;
			select Q1_id(staff), staff, result into EmploymentRecord
			return next EmploymentRecord;
		end if;
	end loop;
end					
$$ language plpgsql;
--------------test--------------------------
create or replace function Q3_show(int)
returns setof EmploymentRecord
as $$
declare 
a record;
result text := '';
employ EmploymentRecord;
begin
	for a in select * from affiliations where  staff = $1  order by starting
	loop
		if a.ending is null then
			result := '1'||result||'Q3_staff_role('||a.staff||')'||a.starting||E'\n';
			
		else
			result := '2'||result||a.starting||E'\n';
		end if;
		raise notice 'Value: %', result;
	end loop;
	result := result||'333';
	select Q3_unswid($1), Q3_name($1), result into employ;
	return next employ;
end
$$ language plpgsql
----------------------------------
create or replace function Q3_show(int)
returns setof EmploymentRecord
as $$
declare 
a record;
result text := '';
employ EmploymentRecord;
begin
	for a in select * from affiliations where  staff = $1  order by starting
	loop
		if a.ending is null then
			result := result||Q3_staff_role(a.role)||', '||Q3_org_name(a.orgunit)||'('||a.starting||'..)'||E'\n';	
		else
			result := result||Q3_staff_role(a.role)||', '||Q3_org_name(a.orgunit)||'('||a.starting||'..'||a.ending||')'||E'\n';
		end if;
	end loop;
	
	select Q3_unswid($1), Q3_name($1), result into employ;
	return next employ;
end
$$ language plpgsql
      
	

select * from q3_show(50409255)      
----------------------------------
create or replace function Q3_name(int)
returns char(128)
as $$
	select name from people where id = $1
$$ language sql;
------------------------------------
create or replace function Q3_unswid(int)
returns int
as $$
select unswid from people where id = $1
$$ language sql;
-------------------------

---------------------
create or replace function Q3_org(int)
returns setof int
as $$
	with recursive included_org(member) as(
		select member from orgunit_groups where owner = $1
	union 
		select p.member from included_org pr, orgunit_groups p where p.owner = pr.member)
	select member from included_org union select $1
$$ language sql;
-----------------------------
create or replace function Q3(integer) 
	returns setof EmploymentRecord 
as $$
 declare person int;
	       n int;
	       emp record ;
	       next_date date := '1000-01-01';
	       t int := 0;
	       

 begin 
	for person in select staff from affiliations where orgunit in (select * from Q3_org($1)) group by (staff)
	loop 
		t:=0;
		for emp in select * from affiliations where staff = person order by starting
		loop
			if next_date != '1000-01-01' then
				if next_date <= emp.starting then
					t := t+1;
				end if;
			end if;
			if next_date < emp.ending then
				next_date := emp.ending;
			end if;
		end loop;
		if t >1 then
		return next Q3_show(person);
		end if;
	end loop;
end;
$$ language plpgsql;
-----------------------------


create type EmploymentRecord as (unswid integer, name text, roles text);
create or replace function Q3(integer) 
	returns setof EmploymentRecord 
as $$
 declare person int;
	       n int;
	       emp record;
	       emp2 record;
	       t int :=0;

 begin 
	for person in select staff from affiliations where orgunit in (select * from Q3_org(661)) group by (staff)
	loop 
	        execute 'select count(*) from affiliations '||' where staff = '||person into n ; 	     
	        if n > 1 then
			for emp in select * from affiliations where staff = person
			loop
				for emp2 in select * from affiliations where staff = person
				loop
					if (emp.starting, emp.ending) OVERLAPS (emp2.starting, empo2.ending) then
						t := t+1;
				end loop
			end loop
			if t > 1 then
				return next 
					
				
	
$$ language plpgsql;

