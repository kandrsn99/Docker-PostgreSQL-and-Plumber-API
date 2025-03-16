/*
    Create a table if it doesn't exist on start
*/
CREATE TABLE IF NOT EXISTS TEST
(
    id SERIAL PRIMARY KEY,
    names VARCHAR (255)
);
/*
    Insert some values into that database table
*/
INSERT INTO TEST (names)
 VALUES
        ('James'),
        ('Killian'),
        ('Gautier'),
        ('Luman'),
        ('Maya');
