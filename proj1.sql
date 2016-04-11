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

