-- Q1: How many containers of antibiotics are currently available?
SELECT quantityOnHand FROM item
WHERE itemDescription = 'bottle of antibiotics';

-- Q2: Which volunteer(s), if any, have phone numbers that do not start with the number 2 and whose last name is not Jones.  Query should retrieve names rather than ids. 
SELECT volunteerName
FROM volunteer
WHERE volunteerTelephone IS NOT NULL
AND volunteerTelephone NOT LIKE '2%'
AND volunteerName NOT LIKE '% Jones';

-- Q3: Which volunteer(s) are working on transporting tasks? Query should retrieve names rather than ids. 
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment
    ON volunteer.volunteerId = assignment.volunteerId
JOIN task
    ON assignment.taskCode = task.taskCode
JOIN task_type 
    ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName = 'transporting';

-- Q4: Which task(s) have yet to be assigned to any volunteers (provide task descriptions, not the codes?
SELECT task.taskDescription
FROM task
LEFT JOIN assignment
    ON task.taskCode = assignment.taskCode
WHERE assignment.volunteerId IS NULL;

-- Q5: Which type(s) of package contain some kind of bottle?
SELECT DISTINCT package_type.packageTypeName
FROM package_type
JOIN package
    ON package_type.packageTypeId = package.packageTypeId
JOIN package_contents
    ON package.packageId = package_contents.packageId
JOIN item
    ON package_contents.itemId = item.itemId
WHERE item.itemDescription LIKE '%bottle%';

-- Q6: Which items, if any, are not in any packages?  Answer should be item descriptions.
SELECT item.itemDescription
FROM item
LEFT JOIN package_contents
    ON item.itemId = package_contents.itemId
WHERE package_contents.packageId IS NULL;

-- Q7: Which task(s) are assigned to volunteer(s) that live in New Jersey (NJ)? Answer should have the task description and not the task ids.
SELECT DISTINCT task.taskDescription
FROM task
JOIN assignment
    ON task.taskCode = assignment.taskCode
JOIN volunteer
    ON assignment.volunteerId = volunteer.volunteerId
WHERE volunteer.volunteerAddress LIKE '%NJ%';

-- Q8: Which volunteers began their assignments in the first half of 2021? Answer should have the volunteer names and not their ids. 
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment
    ON volunteer.volunteerId = assignment.volunteerId
WHERE assignment.startDateTime >= '2021-01-01'
AND assignment.startDateTime < '2021-07-01';

-- Q9: Which volunteers have been assigned to tasks that include packing spam? Answer should have the volunteer names and not their ids. 
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment
    ON volunteer.volunteerId = assignment.volunteerId
JOIN task
    ON assignment.taskCode = task.taskCode
JOIN package
    ON task.taskCode = package.taskCode
JOIN package_contents
    ON package.packageId = package_contents.packageId
JOIN item
    ON package_contents.itemId = item.itemId
WHERE item.itemDescription = 'can of spam';

-- Q10: Which item(s) (if any) have a total value of exactly $100 in one package? Answer should be item descriptions.
SELECT DISTINCT item.itemDescription
FROM item
JOIN package_contents
    ON item.itemId = package_contents.itemId
WHERE item.itemValue * package_contents.itemQuantity = 100;

-- Q11: How many volunteers are assigned to tasks with each different status? The answer should show each different status and the number of volunteers sorted from highest to lowest)
SELECT task_status.taskStatusName,
    COUNT(assignment.volunteerId) AS volunteerCount
FROM assignment
JOIN task
    ON assignment.taskCode = task.taskCode
JOIN task_status
    ON task.taskStatusId = task_status.taskStatusId
GROUP BY task_status.taskStatusName
ORDER BY volunteerCount DESC;

-- Q12: Which task creates the heaviest set of packages and what is the weight? Show both the taskCode and the weight (You should be able to do this without using any sub-queries). 
SELECT package.taskCode,
    SUM(package.packageWeight) AS totalWeight
FROM package
GROUP BY package.taskCode
ORDER BY totalWeight DESC
LIMIT 1;

-- Q13: How many tasks are there that do not have a type of “packing”?
SELECT COUNT(task.taskCode) 
FROM task
JOIN task_type 
    ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName != 'packing';

-- Q14: Of those items that have been packed, which item (or items) were touched by fewer than 3 volunteers?  Answer should be item descriptions. 
SELECT item.itemDescription
FROM item
JOIN assignment
    ON package.taskCode = assignment.taskCode
JOIN package
    ON package_contents.packageId = package.packageId
JOIN package_contents
    ON item.itemId = package_contents.itemId
GROUP BY item.itemId, item.itemDescription
HAVING COUNT(DISTINCT assignment.volunteerId) < 3;

-- Q15: Which packages have a total value of more than 100?  Show the packageIds and their value sorted from lowest to highest.
SELECT package.packageId,
    SUM(item.itemValue * package_contents.itemQuantity) AS sumValue
FROM package
JOIN item
    ON package_contents.itemId = item.itemId
JOIN package_contents
    ON package.packageId = package_contents.packageId
GROUP BY package.packageId
HAVING sumValue > 100
ORDER BY sumValue ASC;

