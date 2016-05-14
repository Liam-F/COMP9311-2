
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




create type EmploymentRecord as (unswid integer, name text, roles text);
create or replace function Q3(integer) 
	returns setof EmploymentRecord 
as $$
... one SQL statement, possibly using other functions defined by you ...
$$ language plpgsql;

