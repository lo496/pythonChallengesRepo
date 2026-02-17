/* (Monday)
Employees - id(int), first_name(varchar), last_name(varchar), salary(int), department_id(int)
 
Departments - id(int), name(varchar)
 
projects - id(int), title(varchar), start_date(date), end_date(date), budget(int)
 
employees_projects - project_id(int), employee_id(int)
 
1. Sort employees at the company by who has the highest salary. 
2. Show all of the employees that worked on the project 'Python App'
3. For the project 'Python App', if the employee was paid on the 1st and 15th of every month, show how much each employee made for the duration of the project.
4. Get all employees names from the 'Sales' department.
5. Get the names of all employees not working on any project.
6. Get all project names where the project has at least 1 employee assigned. 
7. Find the average salary of employees in each department, sorted by department name in ascending order. 
*/

-- creating tables
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS project CASCADE;
DROP TABLE IF EXISTS employees_projects CASCADE;

CREATE TABLE employee
(
    id INT NOT NULL PRIMARY KEY,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    salary INT,
    department_id INT
);

CREATE TABLE department
(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

CREATE TABLE project
(
    id INT NOT NULL PRIMARY KEY,
    title VARCHAR(20) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget INT
);

CREATE TABLE employees_projects
(
    employee_id INT NOT NULL,
    project_id INT NOT NULL
);

ALTER TABLE employee ADD CONSTRAINT employee_department_id_fkey
    FOREIGN KEY (department_id) REFERENCES department (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE employees_projects ADD CONSTRAINT employee_id_fkey
    FOREIGN KEY (employee_id) REFERENCES employee (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE employees_projects ADD CONSTRAINT project_id_fkey
    FOREIGN KEY (project_id) REFERENCES project (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- dummy data
INSERT INTO department (id, name) VALUES
    (1, 'Sales'),
    (2, 'Not Sales');

INSERT INTO employee (id, last_name, first_name, salary, department_id) VALUES
    (1, 'One', 'Alice', 100000, 1),
    (2, 'Two', 'Bob', 80000, 2),
    (3, 'Three', 'Charlie', 60000, 1),
    (4, 'Four', 'Diane', 40000, 2);

INSERT INTO project (id, title, start_date, end_date, budget) VALUES
    (1, 'Python App', (NOW() - INTERVAL '5 months'), NOW(), 1000000),
    (2, 'Something Else', (NOW() - INTERVAL '3 months'), NOW(), 500000),
    (3, 'Abandoned Project', (NOW() - INTERVAL '12 months'), (NOW() - INTERVAL '9 months'), 200000);

INSERT INTO employees_projects (employee_id, project_id) VALUES
    (1, 2),
    (2, 1),
    (3, 2);

-- 1
SELECT first_name, last_name
FROM employee
ORDER BY salary DESC;

-- 2
SELECT e.first_name, e.last_name
FROM employee e
INNER JOIN employees_projects ep
ON e.id = ep.employee_id
INNER JOIN project p
ON ep.project_id = p.id
WHERE p.title = 'Python App';

-- 3
SELECT e.first_name, e.last_name, ((EXTRACT(YEAR from p.end_date) - EXTRACT(YEAR from p.start_date))*e.salary + (EXTRACT(MONTH from p.end_date) - EXTRACT(MONTH from p.start_date))*e.salary/12 + FLOOR((EXTRACT(DAY from p.end_date) - EXTRACT(DAY from p.start_date))/14)*e.salary/12)
FROM employee e
INNER JOIN employees_projects ep
ON e.id = ep.employee_id
INNER JOIN project p
ON ep.project_id = p.id
WHERE p.title = 'Python App';

-- 4
SELECT e.first_name, e.last_name
FROM employee e
INNER JOIN department d
ON e.department_id = d.id
WHERE d.name = 'Sales';

-- 5
SELECT e.first_name, e.last_name
FROM employee e
LEFT JOIN employees_projects ep
ON e.id = ep.employee_id
WHERE ep.project_id IS NULL;

-- 6
SELECT p.title
FROM project p
LEFT JOIN employees_projects ep
ON p.id = ep.project_id
WHERE ep.employee_id IS NULL
GROUP BY p.title;

-- 7
SELECT d.name, AVG(salary)
FROM employee e
INNER JOIN department d
ON e.department_id = d.id
GROUP BY d.id
ORDER BY d.name ASC; 

/* (Tuesday)
SQL Interview practice:
 
1. What SQL constraints do you know about?
2. What types of joins do we have?
3. Create a student table with: student id, email, first_name, last_name
4. Alter the table to include their phone number (US 10-digit numbers only. With OR without parenthesis and dashes)
5. Create a function that creates student records. 
6. Clean student email data: remove all whitespace
7. Consider the following table:
    students (
        id SERIAL PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        enrollment_date DATE NOT NULL,
        gpa NUMERIC(3,2),
        credits_completed INTEGER NOT NULL DEFAULT 0,
        disciplinary_flag BOOLEAN NOT NULL DEFAULT FALSE
    );
    a. Use a CASE statement to return academic_status:
        If disciplinary_flag = TRUE -> 'Under Review'
        if gpa is NULL -> 'No GPA'
        if gpa >= 3.5 AND credits_completed >= 60 -> 'Senior in Good standing'
        if gpa >= 2.0 -> 'Good Standing'
        otherwise -> 'Probation'
    b. Another separate CASE:
        Return honors_eligibility to 'Yes' when:
            gpa >= 3.7
            credits_completed >= 30
            disciplinary_flag = FALSE
        Otherwise 'No' 
*/

-- 1 
/*
SQL constraints include:
UNIQUE = no duplicates in table
NOT NULL = has a value
PRIMARY KEY = both of the previous two
FOREIGN KEY = references another table's primary key
CHECK = used for other constraints, such as a numeric value must be > 0
*/

-- 2
/*
There are 5 types of join:
INNER JOIN = returns only rows that match in both tables
LEFT JOIN = returns all rows from the left table, but only matching rows from the right, where empty values in unmatched rows from the left table are assigned NULL
RIGHT JOIN = same as left join but with table order reversed
OUTER JOIN = includes all rows from both tables, where empty values in unmatched rows from both sides are assigned NULL
CROSS JOIN = returns every possible combination of rows from each table, as in a Cartesian product
*/

-- 3
DROP TABLE IF EXISTS student CASCADE;

CREATE TABLE student
(
    student_id INT NOT NULL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL
);

-- 4
ALTER TABLE student
ADD COLUMN phone_number VARCHAR(14);

-- 5
DROP FUNCTION IF EXISTS create_student_record(
    email VARCHAR(100), first_name VARCHAR(20), last_name VARCHAR(20), phone_number VARCHAR(14));

CREATE OR REPLACE FUNCTION create_student_record(
    email VARCHAR(100), first_name VARCHAR(20), last_name VARCHAR(20), phone_number VARCHAR(14))
RETURNS INT AS $$
BEGIN
    INSERT INTO student(student_id, email, first_name, last_name, phone_number) VALUES 
    (
        (CASE 
            WHEN (SELECT MAX(student_id) FROM student) IS NULL THEN 1
            ELSE (SELECT MAX(student_id) FROM student) + 1 
        END), 
        email,
        first_name,
        last_name,
        phone_number
    );
    RETURN (SELECT MAX(student_id) FROM student);
END;
$$ LANGUAGE plpgsql;

-- dummy data
SELECT create_student_record('      someone@example.com   ', 'Alice', 'One', '(555)-123-4567');
SELECT create_student_record('   somebody@example.com     ', 'Bob', 'Two', '(555)-890-4567');

-- 6
UPDATE student SET email = TRIM(email);

-- 7
DROP TABLE IF EXISTS students CASCADE;

CREATE TABLE students 
(
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    enrollment_date DATE NOT NULL,
    gpa NUMERIC(3,2),
    credits_completed INTEGER NOT NULL DEFAULT 0,
    disciplinary_flag BOOLEAN NOT NULL DEFAULT FALSE
);

-- dummy data
INSERT INTO students (last_name, first_name, email, enrollment_date, gpa, credits_completed, disciplinary_flag) VALUES
    ('One', 'Alice', 'ao@e.com', NOW(), 4.0, 90, FALSE),
    ('Two', 'Bob', 'bt@e.com', NOW(), 3.8, 60, FALSE),
    ('Three', 'Charlie', 'ct@e.com', NOW(), 3.5, 30, FALSE),
    ('Four', 'Diane', 'df@e.com', NOW(), 2.5, 15, FALSE),
    ('Five', 'Elise', 'ef@e.com', NOW(), 1.5, 3, TRUE),
    ('Six', 'Frank', 'fs@e.com', NOW(), NULL, 0, FALSE);

-- academic status
SELECT id, first_name, last_name, 
    CASE
        WHEN disciplinary_flag THEN 'Under Review'
        WHEN gpa IS NULL THEN 'No GPA'
        WHEN gpa >= 3.5 AND credits_completed >= 60 THEN 'Senior in Good standing'
        WHEN gpa >= 2.0 THEN 'Good Standing'
    ELSE 'Probation'
    END AS academic_status
FROM students;

-- honors eligibility
SELECT id, first_name, last_name,
    CASE
        WHEN gpa >= 3.7 AND credits_completed >= 30 AND NOT disciplinary_flag THEN 'Yes' 
    ELSE 'No'
    END AS honors_eligibility
FROM students;