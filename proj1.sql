 create or replace view Q1(unswid,name)
 AS
 SELECT DISTINCT people.unswid,
  	         people.name
   FROM people,
    course_enrolments
  WHERE course_enrolments.course > 55 AND course_enrolments.student = people.unswid;

create or replace view Q2_1
as
select *
FROM  affiliations
WHERE affiliations.ending IS NULL 
AND affiliations.role = (SELECT staff_roles.id
			FROM staff_roles 
			WHERE staff_roles.name = 'Head of School');

create or replace view Q2(name,school,starting)
as
select people.name,orgunits.longname,Q2_1.starting
from Q2_1,people,orgunits
where people.id=Q2_1.staff
and	  Q2_1.orgunit=orgunits.id
and   Q2_1.isprimary='t';

create or replace view Q3(ratio,nsubjects)
as
select cast(uoc/eftsload as numeric(4,1)),count(*)
from subjects
where eftsload!=0 and eftsload is not null
group by cast(uoc/eftsload as numeric(4,1));

create or replace view Q4_1(ncourses,id)
as
select count(*),course_staff.staff
from staff_roles,course_staff
where staff_roles.name = 'Course Convenor'
and course_staff.role=staff_roles.id 
group by course_staff.staff;

create or replace view Q4(name,ncourses)
as
select people.name,Q4_1.ncourses
from Q4_1,people
where people.id=Q4_1.id
and Q4_1.ncourses=
	(select max(ncourses)
	from Q4_1);

create or replace view Q5a(id)
as
select unswid
from people
where people.id in (select student
		    from program_enrolments
		    where semester=(select id 
				    from semesters
				    where term='S2'
				    and year=2005
                                   )
		    and program_enrolments.program 
	   	                    in (select id from programs 	
				    where name='Computer Science'
				    and code='3978'
				       ) 
	       	   );





