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
/*-------------------Q7---------------*/
Create or replace view Q7_intl_number(sem,intl_num) 
as
select semester,count(student) 
	from program_enrolments,students,semesters
	where student = students.id 
		and stype='intl'
		and semester = semesters.id 
		and semesters.year>=2005 
		and term not like 'X%'			
group by semester;

Create or replace view Q7_all_number(sem,all_num) 
as
select semester,count(student) 
	from program_enrolments,students,semesters
	where student = students.id 
		and semester = semesters.id 
		and semesters.year>=2005 
		and term not like 'X%'			
group by semester;

Create or replace view Q7(semester,percent)
as
select Q6(sem),cast (cast (intl_num as float)/cast(all_num as float) as numeric(4,2))
from Q7_all_number left join Q7_intl_number using (sem)
order by Q6(sem);
/*-------------------Q8---------------*/
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

create or replace view Q9_1(course,subject)
as
select id,subject from courses where subject in 
(select id from subjects
where code like 'COMP34%');

create or replace view Q9_2(student,subject)
as
select student,subject from course_enrolments left join Q9_1 using (course)
where subject is not null;

create or replace view Q9_3
as
select id
from subjects
where code like 'COMP34%';

create or replace view Q9(unswid,name)
as
select unswid,name
from people
where id in(select  distinct student
from Q9_2 a
where not exists
	(select * from Q9_3
	where not exists
	(select * from Q9_2 b
	where b.student=a.student
	and b.subject = Q9_3.id)));

/*------------------------------------------------*/

create or replace view Q10_semesters
as
select distinct (year) , term from semesters
where year between 2002 and 2013
and term like 'S%'
order by year,term;

create or replace view Q10_subjects
as
select id from subjects
where code like 'COMP9%';

create or replace view Q10_course_enrolments
as
select student,course,grade,subject,semester 
from course_enrolments left join courses on  (course=courses.id),Q10_subjects
where subject = Q10_subjects.id;

create or replace view Q10_popilar_subjects
as
select * from Q10_subjects
where not exists
	(select * from Q10_semesters
	 where not exists 
			(select * from courses,semesters
				where subject=Q10_subjects.id 
				and semester=semesters.id 
				and semesters.year = Q10_semesters.year 
				and semesters.term=Q10_semesters.term 
			)
	);

create or replace view Q10(unswid,name)
as
select unswid,given||' '||family from people
where not exists
	(select * from Q10_popilar_subjects
		where not exists 
			(select * from Q10_course_enrolments
			where Q10_course_enrolments.student=people.id
			and Q10_course_enrolments.subject= Q10_popilar_subjects.id
			and (Q10_course_enrolments.grade = 'HD' 
						or Q10_course_enrolments.grade ='DN')
			)
	); 
