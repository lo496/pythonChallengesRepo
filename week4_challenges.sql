/*
1. Get all invoice ids with the customers first name, last name, and the invoice total
2. Print the invoice id, customer's first name, and invoice total. But only if the invoice is over $30.
3. Get all the invoices for USA customers in the last 6 months. Use a CTE.
4. Create a new table called Record Logs; Fields: log_id, record_id,field_changed, last_update, old_value, new_value
5. Create a trigger that tracks changes to customer records and logs the changes in our new table
*/

-- 1
SELECT i.invoice_id, c.first_name, c.last_name, i.total
FROM invoice i
INNER JOIN customer c
ON i.customer_id = c.customer_id;

-- 2
SELECT i.invoice_id, c.first_name, i.total
FROM invoice i
INNER JOIN customer c
ON i.customer_id = c.customer_id
WHERE i.total > 30;

-- 3
WITH usa_customers AS (
    SELECT customer_id
    FROM customer
    WHERE country = 'USA'
)
SELECT *
FROM invoice
WHERE customer_id IN (SELECT customer_id FROM usa_customers)
AND invoice_date > NOW() - INTERVAL '6 months';

-- 4
CREATE TABLE IF NOT EXISTS record_logs (
    log_id UUID PRIMARY KEY,
    record_id INTEGER,
    field_changed TEXT,
    last_update TIMESTAMP,
    old_value TEXT,
    new_value TEXT
);

-- 5
CREATE OR REPLACE FUNCTION log_customer_record_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.customer_id IS DISTINCT FROM NEW.customer_id
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'customer_id', NOW(), OLD.customer_id, NEW.customer_id);
    END IF;
    IF OLD.first_name IS DISTINCT FROM NEW.first_name
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'first_name', NOW(), OLD.first_name, NEW.first_name);
    END IF;
    IF OLD.last_name IS DISTINCT FROM NEW.last_name
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'last_name', NOW(), OLD.last_name, NEW.last_name);
    END IF;
    IF OLD.company IS DISTINCT FROM NEW.company
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'company', NOW(), OLD.company, NEW.company);
    END IF;
    IF OLD.address IS DISTINCT FROM NEW.address
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'address', NOW(), OLD.address, NEW.address);
    END IF;
    IF OLD.city IS DISTINCT FROM NEW.city
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'city', NOW(), OLD.city, NEW.city);
    END IF;
    IF OLD.state IS DISTINCT FROM NEW.state
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'state', NOW(), OLD.state, NEW.state);
    END IF;
    IF OLD.country IS DISTINCT FROM NEW.country
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'country', NOW(), OLD.country, NEW.country);
    END IF;    
    IF OLD.postal_code IS DISTINCT FROM NEW.postal_code
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'postal_code', NOW(), OLD.postal_code, NEW.postal_code);
    END IF;
    IF OLD.phone IS DISTINCT FROM NEW.phone
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'phone', NOW(), OLD.phone, NEW.phone);
    END IF;
    IF OLD.fax IS DISTINCT FROM NEW.fax
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'fax', NOW(), OLD.fax, NEW.fax);
    END IF;
    IF OLD.email IS DISTINCT FROM NEW.email
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'email', NOW(), OLD.email, NEW.email);
    END IF;
    IF OLD.support_rep_id IS DISTINCT FROM NEW.support_rep_id
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'support_rep_id', NOW(), OLD.support_rep_id, NEW.support_rep_id);
    END IF;
    IF OLD.attributes IS DISTINCT FROM NEW.attributes
    THEN
        INSERT INTO record_logs (log_id, record_id, field_changed, last_update, old_value, new_value) VALUES
        (gen_random_uuid(), NEW.customer_id, 'attributes', NOW(), OLD.attributes, NEW.attributes);
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER log_customer_record_change
BEFORE UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION log_customer_record_change();
