CREATE SCHEMA library_system;
SET search_path TO library_system;

-- 1. Authors Table
CREATE TABLE Authors (
    AuthorID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    CreatedDate DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 2. Books Table (Updated with CoverImagePath)
CREATE TABLE Books (
    BookID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL UNIQUE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (Status IN ('Available', 'Checked Out')),
    TotalChapters INTEGER CHECK (TotalChapters > 0 OR TotalChapters IS NULL),
    CoverImagePath VARCHAR(255)  -- Stores file path or URL, e.g., '/images/book1.jpg'
);

-- 3. BookAuthors Junction Table
CREATE TABLE BookAuthors (
    BookAuthorID SERIAL PRIMARY KEY,
    BookID INTEGER NOT NULL,
    AuthorID INTEGER NOT NULL,
    CONSTRAINT unique_book_author UNIQUE (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE RESTRICT
);

-- 4. Categories Table
CREATE TABLE Categories (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- 5. BookCategories Junction Table
CREATE TABLE BookCategories (
    BookCategoryID SERIAL PRIMARY KEY,
    BookID INTEGER NOT NULL,
    CategoryID INTEGER NOT NULL,
    CONSTRAINT unique_book_category UNIQUE (BookID, CategoryID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE RESTRICT
);

-- 6. Users Table
CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(20) NOT NULL DEFAULT 'Member' CHECK (Role IN ('Father', 'Mother', 'Child', 'Member', 'Admin')),
    CreatedDate DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 7. BorrowingLog Table
CREATE TABLE BorrowingLog (
    LogID SERIAL PRIMARY KEY,
    BookID INTEGER NOT NULL,
    UserID INTEGER NOT NULL,
    CheckoutDate DATE NOT NULL,
    ReturnDate DATE,
    LastUpdated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE RESTRICT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE RESTRICT
);

-- 8. ChapterSummaries Table
CREATE TABLE ChapterSummaries (
    SummaryID SERIAL PRIMARY KEY,
    LogID INTEGER NOT NULL,
    ChapterNumber INTEGER NOT NULL CHECK (ChapterNumber >= 1),
    SummaryText VARCHAR(2000) NOT NULL,
    DateWritten DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (LogID) REFERENCES BorrowingLog(LogID) ON DELETE CASCADE
);

-- 9. BookReviews Table
CREATE TABLE BookReviews (
    ReviewID SERIAL PRIMARY KEY,
    LogID INTEGER NOT NULL,
    ReviewText VARCHAR(2000) NOT NULL,
    Rating INTEGER CHECK (Rating BETWEEN 1 AND 5),
    DateWritten DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (LogID) REFERENCES BorrowingLog(LogID) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_borrowing_checkout ON BorrowingLog(CheckoutDate);
CREATE INDEX idx_bookauthors_bookid ON BookAuthors(BookID);
CREATE INDEX idx_bookcategories_bookid ON BookCategories(BookID);
CREATE INDEX idx_chaptersummaries_logid ON ChapterSummaries(LogID);
CREATE INDEX idx_bookreviews_logid ON BookReviews(LogID);