-- Insert sample data
INSERT INTO departments VALUES
(1, 'Engineering', 'New York', 5000000.00),
(2, 'Sales', 'London', 3000000.00),
(3, 'Marketing', 'Paris', 2000000.00),
(4, 'HR', 'Tokyo', 1000000.00),
(5, 'Finance', 'Sydney', 1500000.00);

INSERT INTO employees VALUES
(1, 'John', 'Smith', 'john.smith@company.com', '2020-01-15', 1, 'Senior Engineer', 120000, 0.00, NULL, 4),
(2, 'Sarah', 'Johnson', 'sarah.johnson@company.com', '2019-03-20', 2, 'Sales Manager', 95000, 0.10, NULL, 5),
(3, 'Mike', 'Brown', 'mike.brown@company.com', '2021-11-10', 1, 'Software Engineer', 90000, 0.00, 1, 3),
(4, 'Emily', 'Davis', 'emily.davis@company.com', '2022-02-01', 4, 'HR Specialist', 65000, 0.00, NULL, 4),
(5, 'David', 'Wilson', 'david.wilson@company.com', '2018-07-15', 2, 'Sales Executive', 80000, 0.15, 2, 5),
(6, 'Lisa', 'Taylor', 'lisa.taylor@company.com', '2021-05-10', 3, 'Marketing Manager', 110000, 0.00, NULL, 4),
(7, 'Robert', 'Chen', 'robert.chen@company.com', '2020-06-15', 5, 'Financial Analyst', 85000, 0.00, NULL, 3),
(8, 'Maria', 'Garcia', 'maria.garcia@company.com', '2019-07-20', 2, 'Sales Executive', 82000, 0.12, 2, 4),
(9, 'James', 'Miller', 'james.miller@company.com', '2022-08-01', 1, 'Junior Engineer', 75000, 0.00, 1, 3),
(10, 'Jennifer', 'Lee', 'jennifer.lee@company.com', '2021-09-15', 3, 'Marketing Specialist', 70000, 0.00, 6, 4);