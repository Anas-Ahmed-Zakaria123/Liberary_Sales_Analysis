SELECT * FROM Books

SELECT * FROM Branch

SELECT * FROM Employees

SELECT * FROM Issued_Status

SELECT * FROM Members

SELECT * FROM Return_Status


--1. Data Exploration 

---1.1 What is the total Members?
SELECT COUNT(Member_Id) AS Total_Members
FROM Members  --Output: 12


--What is the total employees?
SELECT COUNT(Emp_Id) AS Total_Employees
FROM Employees  --Output: 11


--1.2 What is the total books?
SELECT COUNT(Book_Id) AS Total_Books
FROM Books   --Output: 35


--1.3 What is the Total Issued Books?
SELECT COUNT(DISTINCT Issued_Book_Id) AS Total_Issued_Books
FROM Issued_Status --Output: 31


--1.4 What is the Total Returned Books?
SELECT COUNT(DISTINCT Return_Book_Id) AS Total_Returned_Books
FROM Return_Status --Output: 35


--1.5 What Total Returned Transactions?
SELECT COUNT(*) AS Total_Returns 
FROM Return_Status  --Output: 38


--1.6 Count Available vs Issued (Status column in Books assumed)
SELECT
  SUM(CASE WHEN Status = 0 THEN 1 ELSE 0 END) AS Available_Count,
  SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS Issued_Count,
  COUNT(*) AS Total_Books
FROM Books;



--2.Revenue Insights

---2.1 What is the total revenue?
SELECT SUM(Rental_Price) AS Total_Revenue
FROM Books  --Output: 230

---2.2 What is the total revenue of issued books?
SELECT SUM(B.Rental_Price) AS Total_Revenue
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id  --Output: 223


---2.3 What is the total revenue of returned books?
SELECT SUM(B.Rental_Price) AS Total_Revenue
FROM Books AS B
INNER JOIN Return_Status AS R
ON B.Book_Id = R.Return_Book_Id  --Output: 251


-- 2.4 What is the total revenue by each Month?
SELECT SUM(B.Rental_Price) AS Total_Monthly_Revenue , FORMAT(I.Issued_Date , 'MMM') AS Month
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id
GROUP BY  FORMAT(I.Issued_Date , 'MMM')  --Output: 
                                          --89	Apr
                                          --134 Mar


-- 2.5 What is the total Revenue by each Category?
SELECT B.Category , SUM(B.Rental_Price) AS Total_Revenue_Category
FROM Books AS B
GROUP BY B.Category
ORDER BY SUM(B.Rental_Price) DESC
--Output: 
--Children	8
--Classic	47
--Dystopian	41
--Fantasy	22
--Fiction	16
--History	51
--Horror	13
--Literary Fiction	7
--Mystery	16
--Science Fiction	9


--2.6 What is the Top 3 Categories of Revenue?
SELECT Book_Category , Total_Revenue_Category , Ranking
FROM(SELECT B.Category AS Book_Category, 
     SUM(B.Rental_Price) AS Total_Revenue_Category,
     ROW_NUMBER() OVER(ORDER BY SUM(B.Rental_Price) DESC) AS Ranking
FROM Books AS B
GROUP BY B.Category) AS Sub_Query
WHERE Ranking <= 3
--Output: 
--- History	  51	1
--- Classic	  47	2
--- Dystopian 41	3


--3. Category insights

--3.1 What is the Top 3 Categories of Issued Books?
SELECT TOP 3 
    B.Category AS Book_Category,
    COUNT(I.Issued_Book_Id) AS Total_Issued_Books
FROM Books AS B
INNER JOIN Issued_Status AS I
    ON B.Book_Id = I.Issued_Book_Id
GROUP BY B.Category
ORDER BY Total_Issued_Books DESC;

--Output: 
--Classic   10
--History	7
--Fantasy	4


--3.2 What is the Top 3 Categories of Returned Books?
SELECT TOP 3 
B.Category AS Book_Category,
COUNT(R.Return_Book_Id) AS Total_Returned_Books
FROM Books AS B
INNER JOIN Return_Status AS R
ON B.Book_Id = R.Return_Book_Id 
GROUP BY B.Category
ORDER BY Total_Returned_Books DESC

--Output: 
--Classic	8
--Dystopian	7
--History	7


--3.3 What is the Most Three Popular Books (by Issued Count)?
SELECT TOP 3 B.Book_Title , COUNT(I.Issued_Book_Id) AS Times_Issued
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id
GROUP BY B.Book_Title
ORDER BY Times_Issued DESC
--Output: 
--Animal Farm	2
--Harry Potter and the Sorcerers Stone	2
--The Great Gatsby	2


--4. Member Insights
--4.1 What are the Members Who Issued More Than One Book?
SELECT M.Member_Id , M.Member_Name , COUNT(I.Issued_Book_Id) AS Count_Isseud_Books
FROM Members AS M
INNER JOIN Issued_Status AS I
ON M.Member_Id = I.Issued_Member_Id
GROUP BY M.Member_Id , M.Member_Name
HAVING(COUNT(I.Issued_Book_Id)) > 1
ORDER BY Count_Isseud_Books DESC

--Output: 
--C109      Ivy Martinez   7
--C110      Jack Wilson    6
--C107      Grace Taylor   6
--C105      Eve Brown      5
--C106      Frank Thomas   4
--C108      Henry Anderson 2



--4.2 What is the Most Active Members? (Top 3)
SELECT TOP 3 M.Member_Id , M.Member_Name , COUNT(I.Issued_Book_Id) AS Count_Isseud_Books
FROM Members AS M
INNER JOIN Issued_Status AS I
ON M.Member_Id = I.Issued_Member_Id
GROUP BY M.Member_Id , M.Member_Name
ORDER BY Count_Isseud_Books DESC

--Output: 
--C109      Ivy Martinez   7
--C110      Jack Wilson    6
--C107      Grace Taylor   6


-- 4.3 Members Who Returned All Their Books
SELECT DISTINCT 
    M.Member_Name
FROM Members AS M
WHERE M.Member_Id NOT IN (
    SELECT DISTINCT I.Issued_Member_Id 
    FROM Issued_Status AS I
    LEFT JOIN Return_Status AS R
        ON I.Issued_Id = R.Issued_Id
    WHERE R.Return_Id IS NULL
);


--5.Employee & Branch Insights
-- 5.1 What is the Employees Who Issued the Most Books(Top 2)
SELECT TOP 2 E.Emp_name , COUNT(I.Issued_Book_Id) AS Total_Books
FROM Employees AS E
INNER JOIN Issued_Status AS I
ON E.Emp_Id = I.Issued_Emp_Id
INNER JOIN Books AS B
ON B.Book_Id = I.Issued_Book_Id
GROUP BY E.Emp_name
ORDER BY Total_Books DESC

--Output:
--Laura Martinez	6
--Michelle Ramirez	6


--5.2 What is Branch Performance by Number of Issued Books
SELECT B.Branch_Id , B.Branch_Address , COUNT(I.Issued_Emp_Id) AS Issued_Books
FROM Branch AS B
INNER JOIN Employees AS E
ON B.Branch_Id = E.Branch_id
INNER JOIN Issued_Status AS I
ON E.Emp_Id = I.Issued_Emp_Id
GROUP BY B.Branch_Id , B.Branch_Address
ORDER BY Issued_Books DESC

--Output: 
---B001	123 Main St	17
---B005	890 Maple St 9
---B004	567 Pine St	 4
---B002	456 Elm St	 2
---B003	789 Oak St	 2


--5.3 What is the Average Salary per each Branch?
SELECT B.Branch_Id , AVG(E.Salary) AS Avg_Branch_Salary
FROM Branch AS B
INNER JOIN Employees AS E
ON B.Branch_Id = E.Branch_id
GROUP BY B.Branch_Id
ORDER BY Avg_Branch_Salary DESC

--Output:
--B003	57000
--B005	56000
--B001	48000
--B004	46000
--B002	45000


--5.4 Whar is the total Employees in each Brach?
SELECT B.Branch_Id , COUNT(E.Emp_Id) AS Total_Employees
FROM Branch AS B
INNER JOIN Employees AS E
ON B.Branch_Id = E.Branch_id
GROUP BY B.Branch_Id
ORDER BY Total_Employees DESC

--Output:
--B001	5
--B005	3
--B002	1
--B003	1
--B004	1


--6.Return Insights 
--6.1 Average Return Delay (Assuming Date columns exist)
SELECT AVG(DATEDIFF(DAY , I.Issued_Date , R.Return_Date)) AS Average_Day
FROM Issued_Status AS I
INNER JOIN Return_Status AS R
ON I.Issued_Id = R.Issued_Id;  --Output: 62


--6.2 Books Returned Late
SELECT B.Book_Title , DATEDIFF(DAY , I.Issued_Date , R.Return_Date) AS Num_Days
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id
INNER JOIN Return_Status AS R
ON I.Issued_Id = R.Issued_Id
ORDER BY Num_Days DESC


--7. Advanced Analysis
--7.1 What are the most profitable book categories based on total rentals (Based on Total Revenue)?
SELECT B.Category , 
       SUM(B.Rental_Price) AS Total_Profit,
       COUNT(I.Issued_Book_Id) AS Total_Issued_Books
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id
GROUP BY B.Category
ORDER BY Total_Profit DESC , Total_Issued_Books DESC
--Output: 
--- Classic	61	10


--7.2 Which authors have the highest number of issued books?
SELECT B.Author , COUNT(I.Issued_Book_Id) AS Total_Issued
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id
GROUP BY B.Author
ORDER BY Total_Issued DESC

--Output:
--George Orwell	3
--F. Scott Fitzgerald	2


--7.3 Which members have the longest borrowing durations?
SELECT DISTINCT M.Member_Name , DATEDIFF(DAY , I.Issued_Date , R.Return_Date) AS Duration 
FROM Members AS M
INNER JOIN Issued_Status AS I
ON M.Member_Id = I.Issued_Member_Id
INNER JOIN Books AS B
ON B.Book_Id = I.Issued_Book_Id
INNER JOIN Return_Status AS R
ON B.Book_Id = R.Return_Book_Id
ORDER BY Duration DESC

--Output:
--Eve Brown	79
--Frank Thomas	73


--7.4 What is the Average Borrowing Duration per Category?
SELECT 
    B.Category,
    AVG(DATEDIFF(DAY, I.Issued_Date, R.Return_Date)) AS Avg_Borrow_Days
FROM Books AS B
INNER JOIN Issued_Status AS I
    ON B.Book_Id = I.Issued_Book_Id
INNER JOIN Return_Status AS R
    ON I.Issued_Id = R.Issued_Id
GROUP BY B.Category
ORDER BY Avg_Borrow_Days DESC;

--Output: 
--Children	66
--Horror	66
--Mystery	66


--7.5 Which branch has the highest revenue?
SELECT B.Branch_Id , 
SUM(Bo.Rental_Price) AS Total_Revenue ,
COUNT(I.Issued_Book_Id) AS Total_Issued_Books
FROM Branch AS B
INNER JOIN Employees AS E
ON B.Branch_Id = E.Branch_id
INNER JOIN Issued_Status AS I
ON E.Emp_Id = I.Issued_Emp_Id
INNER JOIN Books AS Bo
ON Bo.Book_Id = I.Issued_Book_Id
GROUP BY B.Branch_Id 
ORDER BY Total_Revenue DESC

--Outpt: 
---B001	115 17


--7.6 Which employee handled the most transactions (Top Employees by Issued Transactions)?
SELECT E.Emp_name,
       COUNT(E.Emp_Id) AS Total_Issued
FROM Employees AS E
INNER JOIN Issued_Status AS I
ON E.Emp_Id = I.Issued_Emp_Id
GROUP BY E.Emp_name
ORDER BY Total_Issued DESC

--Output: 
--Laura Martinez	6
--Michelle Ramirez	6


--7.7 What is the Monthly Trend of Book Issues?
SELECT FORMAT(Issued_Date , 'MMMMM') Mon,
       COUNT(Issued_Book_Name) AS Count_Books
FROM Issued_Status
GROUP BY FORMAT(Issued_Date , 'MMMMM')
ORDER BY Count_Books DESC

--Output: 
--March	21
--April	13


--7.8 Return Rate Analysis?
SELECT COUNT(DISTINCT R.Return_Id) * 100 / COUNT(DISTINCT I.Issued_Id) AS Returned_Percentage
FROM Return_Status AS R
INNER JOIN Books AS B
ON B.Book_Id = R.Return_Book_Id
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id

--Output: 97%


--7.9 Which publishers produce the most borrowed books (Publisher Performance (Based on Rentals))?
SELECT B.Publisher ,
       SUM(B.Rental_Price) AS Total_Revenue , 
       COUNT(I.Issued_Book_Id) AS Total_Issued_Books
FROM Books AS B
INNER JOIN Issued_Status AS I
ON B.Book_Id = I.Issued_Book_Id
GROUP BY B.Publisher
ORDER BY Total_Revenue DESC , Total_Issued_Books DESC

--Output:
--Penguin Books	38	6
--Harper Perennial	24	3


--7.10 What percentage of the total books are currently available?
SELECT (SUM(CASE WHEN B.Status = 0 THEN 1 ELSE 0 END) * 100 / COUNT(*)) AS Available_Percentage
FROM Books AS B 
--Output: 8%


--7.11 What percentage of the total books are currently unavailable?
SELECT (SUM(CASE WHEN B.Status = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*)) AS Unavailable_Percentage
FROM Books AS B
--Output: 91%