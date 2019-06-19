-- ## Activity 1 - Constraints
--
-- Write CREATE TABLE declarations with the necessary constraints for the following 4 tables and their specifications:
--
-- * `Student(sID, name, parentEmail, gpa)`
--   * `sID (should be unique)`
--   * `name (should exist)`
--   * `parentEmail(should exist)`
--   * `gpa (real value between 0 and 4 inclusive)`
-- * `Class(cID, name, units)`
--   * `cID (should be unique)`
--   * `name (should exist)`
--   * `units (must be between 1 and 5 inclusive)`
-- * `ClassGrade(sID, cID, grade)`
--   * `sID (should reference a student)`
--   * `cID (should reference a class)`
--   * `grade (integer between 0 and 4 inclusive, for F,D,C,B,A)`
--   * `student can only get 1 grade for each class`
-- * `ParentNotification(parentEmail, text)`
--   * `parentEmail (should exist)`
--   * `text (the message body, should exist)`
drop table if exists Student;
create table Student
(
    sID         integer primary key,
    name        text not null,
    parentEmail text not null,
    gpa         double check ( gpa >= 0 and gpa <= 4 )
);

drop table if exists Class;
create table Class
(
    cID   integer primary key,
    name  text not null,
    units int check ( units >= 1 and units <= 5 )
);

drop table if exists ClassGrade;
create table ClassGrade
(
    sID   integer,
    cID   integer,
    grade integer check ( 0 <= grade and grade <= 4),
    primary key (sID, cID),
    foreign key (sID) references Student (sID),
    foreign key (cID) references Class (cID)
);

drop table if exists ParentNotification;
create table ParentNotification
(
    parentEmail text not null,
    body        text not null
);



-- Now, it's your turn!  Write a SQLite trigger on the ClassGrade table you defined earlier.  On each insertion into the ClassGrade table, the trigger should update the GPA of the corresponding student.
-- * `gpa = sum(units*grade)/sum(units)`
-- First, let's load data into the tables:
insert into Student
values (1, 'Timmy', 'timmysmom@gmail.com', 0.0);
insert into Student
values (2, 'Billy', 'billysmom@gmail.com', 0.0);
insert into Class
values (1, 'CS145', 4);
insert into Class
values (2, 'CS229', 3);


select * from student;
-- Now, write your trigger here:
drop trigger if exists update_student_gpa;
create trigger update_student_gpa
    after insert
    on ClassGrade
    for each row
begin
    update Student
    set gpa =
            (
                select sum(units * ClassGrade.grade) / sum(units) GPA
                    from Class
                           inner join ClassGrade on Class.cID = ClassGrade.cID
                    where ClassGrade.sID = new.sID
            )
    where sID = new.sID;
end;

insert into ClassGrade
values (1, 1, 4),
       (1, 2, 2);

select sum(units * ClassGrade.grade) / sum(units) GPA
    from Class
           inner join ClassGrade on Class.cID = ClassGrade.cID
    where ClassGrade.sID = 1;


select grade
    from ClassGrade
    where sID = 1;
