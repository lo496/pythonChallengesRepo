/*
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