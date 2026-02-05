/*
1. Find all customers that live in your home state.
 
2. Find all invoices from the last 6 months.
 
3. Delete all customer phone numbers that do not match USA format: (000)-000-0000. Preserve US based phone numbers + transform them to follow the above format without the country code.
 
4. Add a constraint to the customer table so that 
phone numbers match USA format: (000)-000-0000
 
5. Find all music tracks that are over 3 minutes long.
 
6. Update all customers so that they are from the USA. If they are not from 
the usa, clear the other location fields such as: address, city, state, etc.
*/

-- 1

SELECT * FROM customer
WHERE state='NJ';

-- 2

SELECT * FROM invoice
WHERE invoice_date > NOW() - INTERVAL '6 months';

-- 3

UPDATE customer
SET phone = NULL
WHERE NOT phone ~ '\+1 \([0-9]{3}\) [0-9]{3}-[0-9]{4}';

UPDATE customer
SET phone = SUBSTRING(phone, 4, 14)
WHERE phone IS NOT NULL;

-- 4

ALTER TABLE customer
ADD CONSTRAINT phone_usa_format CHECK (phone ~ '\([0-9]{3}\) [0-9]{3}-[0-9]{4}');

-- 5

SELECT * FROM track
WHERE milliseconds > 180000;

-- 6

UPDATE customer
SET 
    country = 'USA',
    address = NULL,
    city = NULL,
    state = NULL,
    postal_code = NULL
WHERE NOT country='USA';
