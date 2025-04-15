DROP DATABASE IF EXISTS LMS;
DROP USER IF EXISTS "lms"@"%";

-- Create the database
CREATE DATABASE LMS 
DEFAULT CHARACTER SET utf8 
COLLATE utf8_hungarian_ci;

-- Create lms user
CREATE USER IF NOT EXISTS "lms"@"%" IDENTIFIED BY "!LibraryMS25";
GRANT SELECT, INSERT, UPDATE, DELETE ON LMS.* TO "lms"@"%";

USE LMS;

-- Create Roles table
CREATE TABLE Roles(
    id INT AUTO_INCREMENT PRIMARY KEY,
    Role VARCHAR(100) NOT NULL
);

-- Create Authors table
CREATE TABLE Authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Author VARCHAR(255) NOT NULL
);

-- Create Categories table
CREATE TABLE Categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Category VARCHAR(100) NOT NULL
);

-- Create Publisher table
CREATE TABLE Publishers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Publisher VARCHAR(255) NOT NULL
);

-- Create Users table (previously called Members)
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email Varchar(50) UNIQUE NULL,
    Username Varchar(25) not null UNIQUE,
    Password varchar(100) not null,
    Address varchar(255) not null,
    DateOfBirth DATE NOT NULL,
    Verified TINYINT(1) DEFAULT 0,
    EmailVerified TINYINT(1) DEFAULT 0,
    EmailVerificationCode VARCHAR(6) DEFAULT 0,
    RoleID INT NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Roles(id) ON DELETE CASCADE
);

-- Create Books table
CREATE TABLE Books (
    ISBN BIGINT(13) PRIMARY KEY,
    PublisherID INT,
    Title VARCHAR(255) NOT NULL,
    PublicationYear int(4),
    FOREIGN KEY (PublisherID) REFERENCES Publishers(id) ON DELETE CASCADE
);

-- Create Books_Authors table to handle multiple authors per book
CREATE TABLE Books_Authors(
    ISBN BIGINT(13) NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (ISBN, AuthorID),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (AuthorID) REFERENCES Authors(id) ON DELETE CASCADE
);

-- Create Books_Categories table to handle multiple categories per book
CREATE TABLE Books_Categories (
    ISBN BIGINT(13) NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (ISBN, CategoryID),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(id) ON DELETE CASCADE
);

-- Create Borrowings table
CREATE TABLE Borrowings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    ISBN BIGINT(13) NOT NULL,
    BorrowDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE
);

-- Create Borrowings_backup table
CREATE TABLE Borrowings_storage (
    id INT,
    UserID INT,
    Username VARCHAR(25),
    Title VARCHAR(255),
    ISBN BIGINT(13),
    BorrowDate DATE,
    DueDate DATE,
    ReturnDate DATE
);

-- Create Reservations table
CREATE TABLE Reservations(
    id INT AUTO_INCREMENT PRIMARY KEY,
    ISBN BIGINT(13) NOT NULL unique,
    UserID INT NOT NULL,
    ReservationStartDate DATE DEFAULT (CURRENT_DATE),
    ReservationEndDate DATE DEFAULT (CURRENT_DATE + INTERVAL 5 DAY),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE
);

DELIMITER $$

CREATE TRIGGER after_borrowing_insert
AFTER INSERT ON Borrowings
FOR EACH ROW
BEGIN
    INSERT INTO Borrowings_storage (id, UserID, Username, Title, ISBN, BorrowDate, DueDate, ReturnDate)
    VALUES (NEW.id, NEW.UserID, (SELECT Username FROM Users WHERE id = NEW.UserID), (SELECT Title FROM Books WHERE ISBN = NEW.ISBN), NEW.ISBN, NEW.BorrowDate, NEW.DueDate, NEW.ReturnDate);
END $$

CREATE TRIGGER after_borrowing_update
AFTER UPDATE ON Borrowings
FOR EACH ROW
BEGIN
    UPDATE Borrowings_storage
    SET 
        UserID = NEW.UserID,
        Username = (SELECT Username FROM Users WHERE id = NEW.UserID),
        Title = (SELECT Title FROM Books WHERE ISBN = NEW.ISBN),
        ISBN = NEW.ISBN,
        BorrowDate = NEW.BorrowDate,
        DueDate = NEW.DueDate,
        ReturnDate = NEW.ReturnDate
    WHERE id = OLD.id;
END $$

CREATE TRIGGER delete_authors_and_books
BEFORE DELETE ON Authors
FOR EACH ROW
BEGIN
    DELETE FROM Books
    WHERE ISBN IN (
        SELECT ISBN FROM Books_Authors WHERE AuthorID = OLD.id
    ) AND NOT EXISTS (
        SELECT ISBN FROM Books_Authors WHERE Books_Authors.ISBN = Books.ISBN AND Books_Authors.AuthorID != OLD.id
    );
END $$

CREATE TRIGGER delete_categories_and_books
BEFORE DELETE ON Categories
FOR EACH ROW
BEGIN
    DELETE FROM Books
    WHERE ISBN IN (
        SELECT ISBN FROM Books_Categories WHERE CategoryID = OLD.id
    ) AND NOT EXISTS (
        SELECT ISBN FROM Books_Categories WHERE Books_Categories.ISBN = Books.ISBN AND Books_Categories.CategoryID != OLD.id
    );
END $$

DELIMITER ;



-- delete reservation if its expired
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS delete_expired_reservation; 

CREATE EVENT delete_expired_reservation
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY) + INTERVAL 3 HOUR 
DO
DELETE FROM Reservations 
WHERE ReservationEndDate < now();



-- Insert values into Roles table
INSERT INTO Roles (Role) VALUES
('Admin'),
('Librarian'),
('Member');

-- Insert values into Authors table
INSERT INTO Authors (Author) VALUES
('George Orwell'),
('J.K. Rowling'),
('Ernest Hemingway'),
('Gabriel Garcia Marquez'),
('Fyodor Dostoevsky'),
('Haruki Murakami'),
('Jane Austen'),
('Leo Tolstoy'),
('Mark Twain'),
('Isabel Allende'), 
('J.R.R. Tolkien'),
('Agatha Christie'),
('William Shakespeare'),
('Charles Dickens'),
('Franz Kafka'),
('F. Scott Fitzgerald'),
('Emily Brontë'),
('J.D. Salinger'),
('Harper Lee'),
('Aldous Huxley'), 
('Herman Melville'),
('Homer'),
('Mary Shelley'),
('Victor Hugo'),
('Dante Alighieri'),
('Antoine de Saint-Exupéry'),
('Paulo Coelho'),
("Cao Xueqin"),
('Lewis Carroll'),
('C.S. Lewis'), 
('H. Rider Haggard');

-- Insert values into Categories table
INSERT INTO Categories (Category) VALUES
('Fiction'),
('Non-fiction'),
('Science Fiction'),
('Fantasy'),
('Historical Fiction'),
('Mystery'),
('Biography'),
('Romance'),
('Thriller'),
('Self-help'), 
('Classics'),
('Young Adult'),
('Adventure'),
('Horror'),
('Poetry'),
('Dystopian'),
('Gothic Fiction'), 
('Philosophical Fiction'),
('Coming-of-Age'),
('Southern Gothic'),
('Epic Poetry'),
('Classic Literature'),
('Adventure Fiction'),
("Children's fiction"),
('Family saga'),
('Classic Fiction'),
("Children's Literature"),
("Christian Allegory")
;

-- Insert values into Publishers table
INSERT INTO Publishers (Publisher) VALUES
('Penguin Random House'),
('HarperCollins'),
('Simon & Schuster'),
('Hachette Livre'),
('Macmillan Publishers'),
('Oxford University Press'),
('Scholastic'),
('Cengage'),
('Wiley'),
('Pearson'), 
('Springer'),
('McGraw-Hill'),
('Routledge'),
('Cambridge University Press'),
('Bloomsbury Publishing'),
('Chapman & Hall'),
('Gallimard'),
('HarperTorch'),
('Collins Crime Club'),
('Penguin Classics'), 
('Puffin Books'),
('Gosselin')
;

-- Insert values into Users table
INSERT INTO Users (FirstName, LastName, Email, Username, Password, Address, Verified, EmailVerified, EmailVerificationCode, RoleID, DateOfBirth) VALUES
('John', 'Doe', 'john.doe@example.com', 'johndoe', '$2y$10$s6wDg2g6WyuxoOrDg4wv4O2hfGcgGaLMhaMWSlNLu048HpF5snqIq', '123 Main St, Springfield', 1, 1, '123123', 3, '1985-06-15'),
('Jane', 'Smith', 'jane.smith@example.com', 'janesmith', '$2y$10$0rK/0Ny/pPudrVWaCKCDfuViT9DiyBvXQjbkIODHGdjkRGgvDt/NO', '456 Oak St, Springfield', 1, 1, '456789', 3, '1990-03-22'),
('Admin', 'User', 'admin@example.com', 'admin', '$2y$10$M6a/92XfuWaAymQ3uTScju2in8rSdkRbdGPIeP.HFC2h.mODuqT4O', '1 Admin Plaza, Springfield', 1, 1, '123456', 1, '1975-11-08'),
('Librarian', 'One', 'librarian1@example.com', 'librarian1', '$2y$10$85fqudNMJZc2lm.CBnznQ.2C9Z265MIIx6kJaMmlwNX8Q3u6wtG4G', '789 Library Rd, Springfield', 1, 1,'783123', 2, '1980-09-17'),
('Alice', 'Johnson', 'alice.j@example.com', 'alicej', '$2y$10$GTQ29D1QP3PWG2ldSc.rnOdLnzN7NP1P4VvtIpuzU0NHtX4PLqIu.', '567 Pine St, Springfield', 1, 1, '287456', 3, '1992-07-05'),
('Bob', 'Brown', 'bob.brown@example.com', 'bobbrown', '$2y$10$0zrLGHesWh.0VJ9l57Kc8.6p7DI5LWTAU7kg27P5KK1M1aaOvdwhu', '678 Maple Ave, Springfield', 1, 1, '561789', 3, '1988-12-11'),
('Clara', 'Olsen', 'clara.olsen@example.com', 'clarao', '$2y$10$iJFpcy.LqYyqt00QQTpNAu4W7Tl5C44Hq9L3h7GTXmcsmHQP03OBO', '234 Cedar St, Springfield', 1, 1, '789111', 3, '1995-04-28'),
('David', 'White', 'david.white@example.com', 'davidwhite', '$2y$10$4fXmOd1EXoX5ZKnWfS1L2eDRrS8WKqqGEFCkwlEhxzfycoT26u/ga', '890 Birch Rd, Springfield', 1, 1, '987222', 3, '1983-10-30'),
('Eve', 'Green', 'eve.green@example.com', 'evegreen', '$2y$10$mRlPDwVGnY5Nm.Zwhv/v.eBJqnmGaqfLEMLienuMGJ2FoMAev6iw6', '102 Walnut St, Springfield', 1, 1, '111333', 3, '1997-02-14'),
('Frank', 'Moore', 'frank.moore@example.com', 'frankmoore', '$2y$10$ssUsidw4bUT1.9rcHzkUH.l.Hxeq5PzLXhE4W.V2kPwrcqAGp.3B6', '901 Chestnut Blvd, Springfield', 1, 1, '222444', 3, '1981-06-09'),
('Grace', 'Lee', 'grace.lee@example.com', 'gracelee', '$2y$10$UqvjfjlxgpVC4yzcfMvhNutNJpSP5gnjKaizOV36Ad4hr/XLxhf2q', '345 Redwood Ln, Springfield', 1, 1, '333555', 3, '1994-08-03'),
('Hannah', 'Scott', 'hannah.scott@example.com', 'hannahscott', '$2y$10$y/MlLUAOqRhK3h/STvJHl.xavuT57tQk6gze37FlYQ4RYmjPO0ox6', '678 Fir St, Springfield', 1, 1, '444666', 3, '1989-05-19'),
('Ian', 'Walker', 'ian.walker@example.com', 'ianwalker', '$2y$10$CQDXhfODyjHT34GHjaqSCeu3FKF.hFotCrzLAXsgRxF1JvK77nW6W', '345 Aspen Dr, Springfield', 1, 1, '555777', 3, '1986-11-23'),
('Jack', 'Young', 'jack.young@example.com', 'jackyoung', '$2y$10$i7JYPvFT/sa6od7vlhp3oOJm2oV9XcGPjRxUR8RR11LhqmEfvQegu', '456 Willow Way, Springfield', 1, 1, '666888', 3, '1993-09-06'),
('Laura', 'Harris', 'laura.harris@example.com', 'lauraharris', '$2y$10$7ohuabBRz5sXx2/0sFP4nOKcJl3XunwqNigHdTtQCsRosjmDFx0VW', '567 Cypress Ct, Springfield', 1, 1, '777999', 3, '1991-01-27'),
('Test', 'User', 'tester.user@example.com', 'TestUser', '$2y$10$QkWX8ewQySm3M95IZTdg0eY.sUYFO5irkdSoylUkfOOmBCP9Dqh8q', '1 Test St, Testfield', 1, 1, '111119', 3, '1991-01-27');



-- Insert values into Books table
INSERT INTO Books (ISBN, PublisherID, Title, PublicationYear) VALUES
(9780451524935, 1, '1984', 1949),
(9780439708180, 2, 'Harry Potter and the Sorcerer''s Stone', 1997),
(9780684801223, 3, 'The Old Man and the Sea', 1952),
(9780060883287, 4, 'One Hundred Years of Solitude', 1967),
(9780486415871, 5, 'Crime and Punishment', 1866),
(9780375704024, 6, 'Norwegian Wood', 1987),
(9780141040349, 7, 'Pride and Prejudice', 1813),
(9780199232765, 8, 'War and Peace', 1869),
(9780486400778, 9, 'The Adventures of Tom Sawyer', 1876),
(9781501117015, 10, 'The House of the Spirits', 1982),
(9780345339683, 11, 'The Hobbit', 1937),
(9780062693661, 12, 'Murder on the Orient Express', 1934),
(9780743477123, 13, 'Hamlet', 1603),
(9780486415864, 14, 'Great Expectations', 1861),
(9780805209990, 15, 'The Trial', 1925),
(9780141187761, 1, 'Animal Farm', 1945),
(9780743273565, 2, 'The Great Gatsby', 1925),
(9780141439518, 3, 'Wuthering Heights', 1847),
(9780140449266, 4, 'The Brothers Karamazov', 1880),
(9780141187396, 5, 'The Catcher in the Rye', 1951),
(9780061120084, 6, 'To Kill a Mockingbird', 1960),
(9780547928227, 7, 'The Hobbit', 1937), 
(9780060850524, 8, 'Brave New World', 1932),
(9780143105428, 9, 'Moby Dick', 1851),
(9780141439563, 12, 'Frankenstein', 1818),
(9780140449143, 13, 'Les Misérables', 1862),
(9780140449334, 15, 'The Divine Comedy', 1320),

(9789225162106, 5, 'A Tale of Two Cities', 1859),
(9783999835785, 17, 'The Little Prince', 1943),
(9784641737389, 18, 'The Alchemist', 1988),
(9786850437272, 19, 'And Then There Were None', 1939),
(9781779218834, 20, 'Dream of the Red Chamber', 1973),
(9780141321073, 21, "Alice's Adventures in Wonderland", 2008),
(9780064471046, 2, "The Lion, the Witch and the Wardrobe", 1994),
(9780140437638, 20, "She: A History of Adventure", 2001),
(9780679734529, 6, 'The Unbearable Lightness of Being', 1984),
(9780142437230, 21, 'The Odyssey', -800),
(9780140449180, 22, 'The Hunchback of Notre-Dame', 1831),
(9780141441145, 14, 'A Christmas Carol', 1843),
(9780064400558, 2, 'The Giver', 1993),
(9780375831003, 7, 'The Book Thief', 2005),
(9780553213119, 13, 'Romeo and Juliet', 1597),
(9780140439440, 17, 'Persuasion', 1818),
(9780142437338, 15, 'Metamorphosis', 1915),
(9780142437178, 6, 'South of the Border, West of the Sun', 1992)
;

-- Insert values into Books_Authors table
INSERT INTO Books_Authors (ISBN, AuthorID) VALUES
(9780451524935, 1),
(9780439708180, 2),
(9780684801223, 3),
(9780060883287, 4),
(9780486415871, 5),(9780486415871, 6),
(9780375704024, 6),
(9780141040349, 7),
(9780199232765, 8),
(9780486400778, 9),(9780486400778, 10),
(9781501117015, 10),
(9780345339683, 11),
(9780062693661, 12),(9780062693661, 1),
(9780743477123, 13),(9780743477123, 10),
(9780486415864, 14),
(9780805209990, 15),
(9780141187761, 1),
(9780743273565, 16),
(9780141439518, 17),
(9780140449266, 5),
(9780141187396, 18),
(9780061120084, 19),
(9780547928227, 11),
(9780060850524, 20),
(9780143105428, 21),
(9780141439563, 23),
(9780140449143, 24),
(9780140449334, 25),
(9789225162106, 14),
(9783999835785, 26),
(9784641737389, 27),
(9786850437272, 12),
(9781779218834, 28),
(9780141321073, 29),
(9780064471046, 30),
(9780140437638, 31),
(9780679734529, 6),
(9780142437230, 22),
(9780140449180, 24),
(9780141441145, 14),
(9780064400558, 27),
(9780375831003, 10),
(9780553213119, 13),
(9780140439440, 7),
(9780142437338, 15),
(9780142437178, 6);

;

-- Insert values into Books_Categories table
INSERT INTO Books_Categories (ISBN, CategoryID) VALUES
(9780451524935, 1),(9780451524935, 3),
(9780439708180, 4),(9780439708180, 12),
(9780684801223, 5),
(9780060883287, 1),(9780060883287, 4),
(9780486415871, 1),
(9780375704024, 1),
(9780141040349, 8),
(9780199232765, 10),
(9780486400778, 1),(9780486400778, 10),
(9781501117015, 1),
(9780345339683, 4),
(9780062693661, 6),
(9780743477123, 1),
(9780486415864, 1),
(9780805209990, 1),
(9780141187761, 16),(9780141187761, 11),
(9780743273565, 17),
(9780141439518, 18),
(9780140449266, 19),
(9780141187396, 20),
(9780061120084, 21),
(9780547928227, 4),
(9780060850524, 16),
(9780143105428, 22),
(9780141439563, 14),
(9780140449143, 5),
(9780140449334, 22),
(9789225162106, 5),
(9783999835785, 24),(9783999835785, 4),
(9784641737389, 4),
(9786850437272, 6),
(9781779218834, 5),
(9780141321073, 4),(9780141321073, 26),(9780141321073, 27),
(9780064471046, 27),(9780064471046, 28),
(9780140437638, 4),(9780140437638, 25),(9780140437638, 26),
(9780679734529, 1),
(9780142437230, 21),
(9780140449180, 5),
(9780141441145, 25),
(9780064400558, 12),
(9780375831003, 1),
(9780553213119, 1),
(9780140439440, 8),
(9780142437338, 14),
(9780142437178, 1)
;

-- Insert values into Borrowings table
INSERT INTO Borrowings (UserID, ISBN, BorrowDate, DueDate, ReturnDate) VALUES
(1, 9780451524935, '2024-09-01', '2024-09-15', NULL),
(2, 9780439708180, '2024-09-05', '2024-09-19', NULL),
(3, 9780684801223, '2024-09-10', '2024-09-24', NULL),
(4, 9780060883287, '2024-09-12', '2024-09-26', NULL),
(5, 9780486415871, '2024-09-15', '2024-09-29', NULL),
(6, 9780375704024, '2024-09-20', '2024-10-04', NULL),
(7, 9780141040349, '2024-09-25', '2024-10-09', NULL),
(8, 9780199232765, '2024-09-27', '2024-10-11', NULL),
(9, 9780486400778, '2024-09-30', '2024-10-14', NULL),
(10, 9781501117015, '2024-10-01', '2024-10-15', NULL),
(11, 9780345339683, '2024-10-02', '2024-10-16', NULL),
(12, 9780062693661, '2024-10-03', '2024-10-17', NULL),
(13, 9780743477123, '2024-10-04', '2024-10-18', NULL),
(14, 9780486415864, '2024-10-05', '2024-10-19', NULL),
(15, 9780805209990, '2024-10-06', '2024-10-20', NULL),
(1, 9780141187761, '2024-10-07', '2024-10-21', '2024-10-20'),
(1, 9780141187761, '2024-10-22', '2024-11-05', NULL),
(1, 9780743273565, '2024-10-08', '2024-10-22', NULL),
(2, 9780141439518, '2024-10-09', '2024-10-23', '2024-10-22'),
(2, 9780141439518, '2024-10-24', '2024-11-07', NULL),
(2, 9780140449266, '2024-10-10', '2024-10-24', NULL),
(3, 9780141187396, '2024-10-11', '2024-10-25', '2024-10-24'),
(3, 9780141187396, '2024-10-26', '2024-11-09', NULL),
(3, 9780061120084, '2024-10-12', '2024-10-26', NULL),
(4, 9780547928227, '2024-10-13', '2024-10-27', '2024-10-26'),
(4, 9780547928227, '2024-10-28', '2024-11-11', NULL),
(4, 9780060850524, '2024-10-14', '2024-10-28', NULL),
(5, 9780143105428, '2024-10-15', '2024-10-29', '2024-10-28'),
(5, 9780143105428, '2024-10-30', '2024-11-13', NULL);