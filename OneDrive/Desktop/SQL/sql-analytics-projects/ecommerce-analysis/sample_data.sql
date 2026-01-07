INSERT INTO customers VALUES
(1, 'John', 'Doe', 'john.doe@email.com', 'New York', 'USA', '2023-01-15', 'Premium'),
(2, 'Sarah', 'Smith', 'sarah.smith@email.com', 'London', 'UK', '2023-02-20', 'Standard'),
(3, 'Mike', 'Johnson', 'mike.johnson@email.com', 'Paris', 'France', '2023-03-10', 'Premium'),
(4, 'Emily', 'Brown', 'emily.brown@email.com', 'Tokyo', 'Japan', '2023-01-05', 'Standard'),
(5, 'David', 'Wilson', 'david.wilson@email.com', 'Sydney', 'Australia', '2023-04-12', 'Premium'),
(6, 'Lisa', 'Taylor', 'lisa.taylor@email.com', 'New York', 'USA', '2023-05-10', 'Standard'),
(7, 'Robert', 'Chen', 'robert.chen@email.com', 'Tokyo', 'Japan', '2023-06-15', 'Premium'),
(8, 'Maria', 'Garcia', 'maria.garcia@email.com', 'London', 'UK', '2023-07-20', 'Standard');

INSERT INTO products VALUES
(1, 'MacBook Pro 16"', 'Electronics', 'Laptops', 2399.99, 1800.00, 'Apple Inc'),
(2, 'iPhone 15 Pro', 'Electronics', 'Smartphones', 1199.99, 900.00, 'Apple Inc'),
(3, 'Coffee Maker', 'Home Appliances', 'Kitchen', 149.99, 100.00, 'KitchenCo'),
(4, 'Running Shoes', 'Sports', 'Footwear', 129.99, 80.00, 'SportGear'),
(5, 'Desk Lamp', 'Home Decor', 'Lighting', 45.00, 25.00, 'HomeStyle'),
(6, 'Yoga Mat', 'Sports', 'Fitness', 29.99, 15.00, 'SportGear'),
(7, 'Wireless Headphones', 'Electronics', 'Audio', 199.99, 120.00, 'AudioTech'),
(8, 'Office Chair', 'Furniture', 'Chairs', 299.99, 180.00, 'FurnitureCo');

INSERT INTO orders VALUES
(1, 1, '2024-01-15', 'Delivered', 2399.99, 'New York', 'Credit Card'),
(2, 2, '2024-01-16', 'Delivered', 129.99, 'London', 'PayPal'),
(3, 3, '2024-01-17', 'Processing', 149.99, 'Paris', 'Credit Card'),
(4, 1, '2024-01-18', 'Delivered', 1199.99, 'New York', 'Credit Card'),
(5, 4, '2024-01-19', 'Delivered', 199.99, 'Tokyo', 'PayPal'),
(6, 5, '2024-01-20', 'Shipped', 299.99, 'Sydney', 'Credit Card'),
(7, 2, '2024-01-21', 'Delivered', 45.00, 'London', 'PayPal'),
(8, 6, '2024-01-22', 'Processing', 29.99, 'New York', 'Credit Card'),
(9, 7, '2024-01-23', 'Delivered', 2399.99, 'Tokyo', 'Credit Card'),
(10, 8, '2024-01-24', 'Shipped', 129.99, 'London', 'PayPal');

INSERT INTO order_items VALUES
(1, 1, 1, 1, 2399.99, 0),
(2, 2, 4, 1, 129.99, 0),
(3, 3, 3, 1, 149.99, 0),
(4, 4, 2, 1, 1199.99, 0),
(5, 5, 7, 1, 199.99, 0),
(6, 6, 8, 1, 299.99, 0),
(7, 7, 5, 1, 45.00, 0),
(8, 8, 6, 1, 29.99, 0),
(9, 9, 1, 1, 2399.99, 0),
(10, 10, 4, 1, 129.99, 0);