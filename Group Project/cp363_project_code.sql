
/* -------------------------------------------- */
/* --- Remove all foreign key relationships --- */
/* --- Fix prior errors when dropping tables -- */
/* -------------------------------------------- */

/* https://www.sqlservercentral.com/blogs/remove-all-foreign-keys */

WHILE(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE='FOREIGN KEY'))
BEGIN
DECLARE @sql_query nvarchar(2000)
SELECT TOP 1 @sql_query=('ALTER TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME
+ '] DROP CONSTRAINT [' + CONSTRAINT_NAME + ']')
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
EXEC (@sql_query)
END

/* ------------------------------------------ */
/* --- Drop existing tables if applicable --- */
/* ------------------------------------------ */

DROP TABLE IF EXISTS StaffMember;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Menu;
DROP TABLE IF EXISTS MenuType;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderInfo;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Delivery;

/* ------------------------- */
/* --- Create all tables --- */
/* ------------------------- */

CREATE TABLE StaffMember (
    StaffMemberID int IDENTITY(1,1),
    Password varchar(20) NOT NULL,
    FullName varchar(40) NOT NULL,
    Email varchar(60) NOT NULL,
    Phone varchar(24) NOT NULL,
	CONSTRAINT PK_StaffMember PRIMARY KEY (StaffMemberID)
);

CREATE TABLE Customer (
    CustomerID int IDENTITY(1,1),
    FullName varchar(40) NOT NULL,
    Address varchar(60) NOT NULL,
    City varchar(15) NOT NULL,
    Region varchar(15) NOT NULL,
    PostalCode varchar(10) NOT NULL,
    Country varchar(15) NOT NULL,
    Email varchar(60) NOT NULL,
    Phone varchar(24) NOT NULL,
	CONSTRAINT PK_Customer PRIMARY KEY (CustomerID)
);

CREATE TABLE Menu (
    MenuID int IDENTITY(1,1),
    MenuTypeID int NOT NULL,
    ItemName varchar(40) NOT NULL,
    Price decimal(5, 2) NOT NULL,
    Picture varchar(40) NOT NULL,
    Ingredients varchar(160) NOT NULL,
    Status varchar(40) NOT NULL,
	CONSTRAINT PK_Menu PRIMARY KEY (MenuID)
);

CREATE TABLE MenuType (
    MenuTypeID int IDENTITY(1,1),
    TypeName varchar(40) NOT NULL,
    Description varchar(40) NOT NULL,
	CONSTRAINT PK_MenuType PRIMARY KEY (MenuTypeID)
);

CREATE TABLE Orders (
    OrderID int IDENTITY(1,1),
    OrderDate DATETIME NOT NULL,
    CustomerID int NOT NULL,
    StaffMemberID int NOT NULL,
    OrderAmount decimal(5, 2) NOT NULL,
    Status varchar(40) NOT NULL,
    InstructionsComment varchar(160) NOT NULL,
	CONSTRAINT PK_Orders PRIMARY KEY (OrderID)
);

CREATE TABLE OrderInfo (
    OrderInfoID int IDENTITY(1,1),
    OrderID int NOT NULL,
    MenuID INT NOT NULL,
    ItemName varchar(160) NOT NULL,
    Quantity int NOT NULL,
    AmountPerItem decimal(5, 2) NOT NULL,
    TotalAmount decimal(5, 2) NOT NULL,
	CONSTRAINT PK_OrderInfo PRIMARY KEY (OrderInfoID)
);

CREATE TABLE Payment (
    PaymentID int IDENTITY(1,1),
    OrderID int NOT NULL,
    StaffMemberID int NOT NULL,
    PaymentDate DATETIME NOT NULL,
    PaymentType varchar(40) NOT NULL,
    PaymentAmount decimal(5, 2) NOT NULL,
	CONSTRAINT PK_Payment PRIMARY KEY (PaymentID)
);

CREATE TABLE Delivery (
    DeliveryID int IDENTITY(1,1),
    OrderID int NOT NULL,
    CustomerID int NOT NULL,
    DeliveryDriver varchar(40) NOT NULL,
    DriverRating tinyint NOT NULL,
    CHECK (DriverRating >= 0 AND DriverRating <= 5), 
    DeliveryStatus varchar(40) NOT NULL,
    DeliveryTime DATETIME NOT NULL,
	CONSTRAINT PK_Delivery PRIMARY KEY (DeliveryID)
);

/* ------------------------------------------- */
/* --- Establish Foreign Key Relationships --- */
/* ------------------------------------------- */

ALTER TABLE Delivery
	ADD CONSTRAINT FK_Delivery_Customer FOREIGN KEY (CustomerID)
		REFERENCES Customer (CustomerID);

ALTER TABLE Delivery
	ADD CONSTRAINT FK_Delivery_Orders FOREIGN KEY (OrderID)
		REFERENCES Orders (OrderID);

ALTER TABLE Menu
	ADD CONSTRAINT FK_Menu_MenuType FOREIGN KEY (MenuTypeID)
		REFERENCES MenuType (MenuTypeID);

ALTER TABLE OrderInfo
	ADD CONSTRAINT FK_OrderInfo_Menu FOREIGN KEY (MenuID)
		REFERENCES Menu (MenuID);

ALTER TABLE OrderInfo
	ADD CONSTRAINT FK_OrderInfo_Orders FOREIGN KEY (OrderID)
		REFERENCES Orders (OrderID);

ALTER TABLE Orders
	ADD CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID)
		REFERENCES Customer (CustomerID);

ALTER TABLE Orders
	ADD CONSTRAINT FK_Orders_StaffMember FOREIGN KEY (StaffMemberID)
		REFERENCES StaffMember (StaffMemberID);

ALTER TABLE Payment
	ADD CONSTRAINT FK_Payment_Orders FOREIGN KEY (OrderID)
		REFERENCES Orders (OrderID);

ALTER TABLE Payment
	ADD CONSTRAINT FK_Payment_StaffMember FOREIGN KEY (StaffMemberID)
		REFERENCES StaffMember (StaffMemberID);

/* ------------------------------------ */
/* --- Insert Test Data into Tables --- */
/* ------------------------------------ */

INSERT INTO StaffMember (Password, FullName, Email, Phone) VALUES ('password', 'John Smith', 'jsmith12@gmail.com', '123-456-7890');
INSERT INTO StaffMember (Password, FullName, Email, Phone) VALUES ('password', 'Jane Doe', 'jjdoep@hotmail.com', '123-987-6543');

INSERT INTO Customer (FullName, Address, City, Region, PostalCode, Country, Email, Phone) VALUES ('Mary Kathy', '123 Main St', 'Toronto', 'ON', 'M5J 2K2', 'Canada', 'mkath@gmail.com', '905-456-7890');
INSERT INTO Customer (FullName, Address, City, Region, PostalCode, Country, Email, Phone) VALUES ('Matthew Marco', '456 Main St', 'Toronto', 'ON', 'M5J 2K2', 'Canada', 'mmoxxy@gmail.com', '905-212-7762');
INSERT INTO Customer (FullName, Address, City, Region, PostalCode, Country, Email, Phone) VALUES ('Susie Beth', '68 University Ave', 'Waterloo', 'ON', 'N2J 3KL', 'Canada', 'susieloohoo@hotmail.com', '519-577-5559');
INSERT INTO Customer (FullName, Address, City, Region, PostalCode, Country, Email, Phone) VALUES ('Sydney Winn', '26 Regina Street', 'Waterloo', 'ON', 'N3K 5M2', 'Canada', 'swinner@gmail.com', '226-852-2323');

INSERT INTO MenuType (TypeName, Description) VALUES ('Lunch/Dinner Menu', 'Standard menu for regular hours.');  
INSERT INTO MenuType (TypeName, Description) VALUES ('Breakfast Menu', 'Breakfast menu used before noon.');
INSERT INTO MenuType (TypeName, Description) VALUES ('Drinks Menu', 'Menu for all non-alcoholic beverages.');
INSERT INTO MenuType (TypeName, Description) VALUES ('Dessert Menu', 'Menu for tasty treats.');

INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (1, 'Pizza', '10.00', 'pizza.jpg', 'Tomato, Cheese, Pepperoni', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (1, 'Burger', '8.00', 'burger.jpg', 'Beef, Cheese, Tomato', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (1, 'Pasta', '12.00', 'pasta.jpg', 'Tomato, Cheese, Meatballs', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (1, 'Salad', '7.00', 'salad.jpg', 'Lettuce, Bacon, Croutons, Caesar Dressing', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (1, 'Grilled-Cheese Sandwich', '5.00', 'sandwich.jpg', 'Ham, Cheese, Tomato', 'Available.');

INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (2, 'Grilled-Cheese Sandwich', '5.00', 'sandwich.jpg', 'Ham, Cheese, Tomato', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (2, 'Eggs and Toast', '6.00', 'eggs.jpg', 'Eggs, Toast', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (2, 'Omelette', '6.00', 'omelette.jpg', 'Eggs, Bacon, Cheese', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (2, 'Pancakes', '6.00', 'pancakes.jpg', 'Flour, Eggs, Milk', 'Available.');

INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (3, 'Coffee', '3.00', 'coffee.jpg', 'Coffee', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (3, 'Tea', '3.00', 'tea.jpg', 'Tea', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (3, 'Iced-Tea', '4.00', 'icedtea.jpg', 'Iced-Tea', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (3, 'Juice', '3.00', 'juice.jpg', 'Juice', 'Out of orange juice.');

INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (4, 'Chocolate Cake', '5.00', 'cake.jpg', 'Chocolate', 'Available.');
INSERT INTO Menu (MenuTypeID, ItemName, Price, Picture, Ingredients, Status) VALUES (4, 'Creme Brulee', '5.00', 'creame.jpg', 'Cream', 'Out-of-stock.');

INSERT INTO Orders (OrderDate, CustomerID, StaffMemberID, OrderAmount, Status, InstructionsComment)
    VALUES ('2022-04-01', 1, 2, '10.00', 'Complete', 'No special instructions.');
INSERT INTO Orders (OrderDate, CustomerID, StaffMemberID, OrderAmount, Status, InstructionsComment)
    VALUES ('2022-04-01', 2, 2, '18.00', 'Complete', 'Leave food by side door.');
INSERT INTO Orders (OrderDate, CustomerID, StaffMemberID, OrderAmount, Status, InstructionsComment)
    VALUES ('2022-04-03', 1, 1, '20.00', 'Complete', 'No special instructions.');
INSERT INTO Orders (OrderDate, CustomerID, StaffMemberID, OrderAmount, Status, InstructionsComment)
    VALUES ('2022-04-03', 3, 1, '10.00', 'Complete', 'Do not ring bell, just send text (dogs will bark), thanks!');
INSERT INTO Orders (OrderDate, CustomerID, StaffMemberID, OrderAmount, Status, InstructionsComment)
    VALUES ('2022-04-04', 4, 2, '22.00', 'Delivered', 'No special instructions.');

INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (1, 1, 'Pizza', 1, 10.00, 10.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (2, 1, 'Burger', 1, 8.00, 8.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (2, 1, 'Pizza', 1, 10.00, 10.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (3, 1, 'Pizza', 1, 10.00, 10.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (3, 4, 'Chocolate Cake', 2, 5.00, 10.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (4, 1, 'Grilled-Cheese Sandwich', 2, 5.00, 10.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (5, 2, 'Grilled-Cheese Sandwich', 2, 5.00, 10.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (5, 2, 'Eggs and Toast', 1, 6.00, 6.00);
INSERT INTO OrderInfo (OrderID, MenuID, ItemName, Quantity, AmountPerItem, TotalAmount) VALUES (5, 3, 'Coffee', 2, 3.00, 6.00);

INSERT INTO Payment (OrderID, StaffMemberID, PaymentDate, PaymentType, PaymentAmount) VALUES (1, 2, '2022-04-01', 'Cash', '10.00');
INSERT INTO Payment (OrderID, StaffMemberID, PaymentDate, PaymentType, PaymentAmount) VALUES (2, 2, '2022-04-01', 'Visa', '18.00');
INSERT INTO Payment (OrderID, StaffMemberID, PaymentDate, PaymentType, PaymentAmount) VALUES (3, 1, '2022-04-03', 'Mastercard', '20.00');
INSERT INTO Payment (OrderID, StaffMemberID, PaymentDate, PaymentType, PaymentAmount) VALUES (4, 1, '2022-04-03', 'Cash', '10.00');
INSERT INTO Payment (OrderID, StaffMemberID, PaymentDate, PaymentType, PaymentAmount) VALUES (5, 2, '2022-04-04', 'Visa', '22.00');

INSERT INTO Delivery (OrderID, CustomerID, DeliveryDriver, DriverRating, DeliveryStatus, DeliveryTime) VALUES (1, 1, 'Rafael', 4, 'Delivered', '2022-04-01 13:25:00');
INSERT INTO Delivery (OrderID, CustomerID, DeliveryDriver, DriverRating, DeliveryStatus, DeliveryTime) VALUES (2, 2, 'Rafael', 4, 'Delivered', '2022-04-01 14:12:00');
INSERT INTO Delivery (OrderID, CustomerID, DeliveryDriver, DriverRating, DeliveryStatus, DeliveryTime) VALUES (3, 1, 'Paul', 5, 'Delivered', '2022-04-03 12:40:00');
INSERT INTO Delivery (OrderID, CustomerID, DeliveryDriver, DriverRating, DeliveryStatus, DeliveryTime) VALUES (4, 3, 'Paul', 5, 'Delivered', '2022-04-03 13:50:00');
INSERT INTO Delivery (OrderID, CustomerID, DeliveryDriver, DriverRating, DeliveryStatus, DeliveryTime) VALUES (5, 4, 'Paul', 5, 'Transporting', '2022-04-04 09:50:00');
