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

create or replace view Q5b(id)
as
select unswid
from people
where people.id in (select student
		    from program_enrolments
		    where id in (select partof
	     			 from stream_enrolments
	     			where stream in (select id from streams
						where  code='SENGA1'
						)
	     			)
		    and semester=(select id 
				    from semesters
				    where term='S2'
				    and year=2005

                                )
		   );

create or replace view Q5c(id)
as
select unswid
from people
where people.id in (select student
		    from program_enrolments
		    where program_enrolments.program in (select id
	     			 from programs
	     			where offeredby in (select id from orgunits
					where  name='Computer Science and Engineering, School of'
						)
	     			)
		    and semester=(select id 
				    from semesters
				    where term='S2'
				    and year=2005

                                )
		   );

create or replace function 
Q6(integer)
returns text
as $$
	select right(year||lower(term),4)
	from semesters
	where id = $1
$$ language sql;

Create or replace view Q7(sem,num) /*没完成*/
as
select count(student),Q6(semester) 
from program_enrolments
where student in 
( select id 
from students
where stype='intl'
)
group by Q6(semester)
having Q6(semester) not like '__x1'
order by Q6(semester);




create or replace function Q8_1(integer)
returns text
as $$
	select code||' '||name 
	from subjects
	where id=$1
$$ language sql;


create or replace view Q8_1 /*select all subjects which never have staff */
as
select count(staff), subject from course_staff right JOIN courses on id=course
group by subject
having count(staff)=0;

create or replace view Q8(subject,nOfferings) 
as
select Q8_1(courses.subject),count(*) from courses,Q8_1
where Q8_1.subject=courses.subject
group by courses.subject
having count(*)>25
order by Q8_1(courses.subject);

