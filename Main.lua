function love.load()
	math.randomseed(os.time())
	bg = love.graphics.newImage("Grid.png")
	h = 750
	w = 750
	love.window.setMode(w, h)

	pts = {}
	--State the number of desired points here
	numPts = 300

	--starting the runtime clock
	StartTime = love.timer.getTime()

	--Generating points randomly between set numbers
	--chose these numbers because they don't overlap the printed info or scales
	for i = 1, numPts, 1 do
		tmp = math.floor(math.random(30, w))
		tmp2 = math.floor(math.random(50, h - 25))
		table.insert(pts, {tmp, tmp2})
	end

	--Sorting the array of points
	SortCoordArr(pts)

	--building a hull array based on the sorted points array
	hull = buildHull(pts)

	--calculating final runtime
	time = love.timer.getTime() - StartTime

	--displaying number of points and runtime in ms
	statement = "# Points: " .. numPts
	statement2 = "Runtime was: " .. (time* 1000) .. " ms"

	love.graphics.setPointSize(5)
end

function love.draw()
	--Resetting the graphics colour is necessary because love.draw loops
	love.graphics.setColor(255,255,255)
	love.graphics.draw(bg)
	love.graphics.setColor(0,0,0)


	for i = 1, 15, 1 do
		--y axis scale
		love.graphics.print(i*50, 3, h - i*50 + 2)
		--x axis scale
		love.graphics.print(i*50, i*50 + 3, h - 15)
	end

	love.graphics.setColor( 215, 117, 130)

	--Printing hull lines
	for i = 1, table.getn(hull), 1 do
		if i == table.getn(hull) then
			love.graphics.line(hull[i][1], hull[i][2], hull[1][1], hull[1][2])
		else
			love.graphics.line(hull[i][1], hull[i][2], hull[i + 1][1], hull[i + 1][2])
		end
	end

	love.graphics.setColor( 0, 0, 255)

	--Printing points
	for i = 1, table.getn(pts), 1 do
		love.graphics.points(pts[i][1], pts[i][2])
	end

	--Printing other info
	love.graphics.setColor( 142, 59, 145)

	love.graphics.printf(statement, 50, 0, 175, "left", 0, 2)

	love.graphics.printf(statement2, 400, 0, 175, "left", 0, 2)
end

function SortCoordArr(arr)
	--sorts an array of {x,y} points, primarily by x value, secondly by y
	--fyi lua is 1 indexed 
	for i = 2, table.getn(arr), 1 do
		t = i

		--while t isn't the first element and x1 > x2
		while (t > 1) and (arr[t][1] <= arr[t-1][1]) do

			--if x1 == x2 and y1 > y2 then already sorted, so break loop
			if (arr[t][1]==arr[t-1][1]) and (arr[t][2]>=arr[t-1][2]) then
				break
			--else swap elements
			else
				tmpCrd1 = arr[t-1]
				arr[t-1] = arr[t]
				arr[t] = tmpCrd1
				t = t-1
			end
		end
	end
end

function cross(o, a, b)
	--Generic cross product
	return (a[1] - o[1]) * (b[2] - o[2]) - (a[2] - o[2]) * (b[1] - o[1])
end

function  buildHull(Points)

	--This uses the Monotone Chain convex hull method
	--It builds an upper and lower portion of the hull then adds them together

	size = table.getn(Points)

	--case there is one or fewer points
	if size <=1 then
		return Points
	end

	--building lower half
	lower = {}
	for i = 1, size, 1 do
		while (table.getn(lower) >= 2) and (cross(lower[table.getn(lower) - 1], 
												  lower[table.getn(lower)], 
												  Points[i]) <= 0) do

			--removes elements until the last two elements in the list satisfy a cross product check
			table.remove(lower,table.getn(lower))
		end
		--checks every point
		table.insert(lower, Points[i])
	end

	--building upper half
	upper = {}
	for i = size, 1, -1 do
		while (table.getn(upper) >= 2) and (cross(upper[table.getn(upper) - 1],  
										    upper[table.getn(upper)], 
										    Points[i]) <= 0) do

		--removes elements until the last two elements in the list satisfy a cross product check
			table.remove(upper,table.getn(upper))
		end
		--checks every point 
		table.insert(upper, Points[i])
	end

	--the last point on either hull will be the first point of the other. It is necessary to remove one
	table.remove(lower, table.getn(lower))
	table.remove(upper, table.getn(upper))

	--combining the tables
	for i = 1, table.getn(upper), 1 do
		table.insert(lower, upper[i])
	end

	return lower
end