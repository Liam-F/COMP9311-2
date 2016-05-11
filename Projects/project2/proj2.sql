
--create type TranscriptRecord as (code text, term text, course integer, prog text, name text, mark integer, grade text, uoc integer, rank integer, totalEnrols integer);

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
create or replace function Q1_uoc(int)
returns int
as $$
select uoc from subjects
where subjects.id = $1
$$ language sql;

--------------------
create or replace view Q1_all
as
select course_enrolments.student,
course_enrolments.course,
course_enrolments.mark,
course_enrolments.grade,
subject,
semester 
from (courses left join course_enrolments on course = courses.id)
-------------
select Q1_course_code(subject),course,Q1_all.mark,grade,Q1_term(Q1_all.semester), program
 from Q1_all, program_enrolments
where Q1_all.student = Q1_id(2237675)
and Q1_all.semester = program_enrolments.semester
and Q1_all.student = program_enrolments.student
-----------------------
create or replace function Q1_rank(ke integer)
returns table(student integer,rank bigint)
as $$
select student,rank() over (order by mark DESC)from course_enrolments
where course = ke; 
$$ language sql
----------------
create type TranscriptRecord as (code char(8), term char(4), course integer, prog char(4), name text, mark integer, grade char(2), uoc integer, rank integer, totalEnrols integer);

create or replace function Q1(integer)
	returns setof TranscriptRecord
as $$
	select * from Q1_unnamed
	where  id = $1
$$ language plpgsql;


-- Q2: ...
create type MatchingRecord as ("table" text, "column" text, nexamples integer);

create or replace function Q2("table" text, pattern text) 
	returns setof MatchingRecord
as $$
... one SQL statement, possibly using other functions defined by you ...
$$ language plpgsql;
 
-- Q3: ...




create type EmploymentRecord as (unswid integer, name text, roles text);
create or replace function Q3(integer) 
	returns setof EmploymentRecord 
as $$
... one SQL statement, possibly using other functions defined by you ...
$$ language plpgsql;

