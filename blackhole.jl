#=
Title: Discrete Simulation of 2-Dimensional Light Paths in Continuous Media
Author:
=#

#finds the magnitude of a vector in 2-space
function magnitude(vector) #vector type list
    return sqrt(vector[1]^2+vector[2]^2)
end

#finds the angle between two vectors
function get_angle(a,b)#a,b are type list
    if magnitude(a)>magnitude(b)
        hypotenuse = magnitude(a)
        adjacent = magnitude(b)
    else
        hypotenuse = magnitude(b)
        adjacent = magnitude(a)
    end
    if hypotenuse == 0
        hypotenuse = 0.00001
        break
    end
    return acos(adjacent / hypotenuse)
end

#finds the lowest angle between the norm and the velocity
function choose_angle(normal,velocity)
    positive = get_angle(normal,velocity)
    negative = get_angle(-normal,velocity)
    if abs(positive)<=abs(negative)
        return positive
    else
        return negative
    end
end

#rotates a matrix by some angle in radians
function instantaneous_rotation(current_velocity,current_angle)
    x = velocity[1]*cos(angle)-velocity[2]*sin(angle)
    y = velocity[1]*sin(angle)+velocity[2]*cos(angle)
    return [x,y]
end

#the continuous refractive index at any point
function refractive_index(point) #point type list (x,y)
    return (point[1]^2)*(point[2]^2)+1
end

#Gradient of level plane W(x,y,n) is normal to surface n
#the particular normal at some point
function projected_normal(point) #point type list (x,y)
    x = 2*point[1]*point[2]^2
    y = 2*point[2]*point[1]^2
    return [x,y] #we only need the projection onto 2-space
end

#generates a random initial velocity
function generate_velocity()
    candidate = [rand(-c:c)-rand(),0]
    candidate[2] = sqrt(c^2 - candidate[1]^2)
    return candidate
end

#generates a random initial position
function generate_position()
    return [rand(-10:10)+rand(),rand(-10:10)+rand()]
end

#=
Given n1 = c/v1 and n2 = c/v2, n1/n2 = (c/v1)(v2/c) = (v2/v1)(c/c)= (v2/v1)
so (v1 n1)/n2 = v2. Or in this case, n1 is the last n(x,z), v1 is the current
velocity, and n2 is the current n(x,z), and v2 is the velocity we are trying
to calculate.
=#

#Main Body of Code

#initial conditions of the photon:
c = 2.99e8
current_position,current_velocity = generate_position(),generate_velocity()
current_n = c / magnitude(current_velocity)

running = true
while running
    #have to figure out how to update current_n
    incident_normal = projected_normal(current_position)
    incident_angle = choose_angle(incident_normal,current_velocity)
    #the refractive angle between the refractive velocity and the refractive normal
    refractive_angle = asin((current_n*sin(incident_angle))/refractive_index(current_position))
    #=
    given you want to start with some current velocity, this function gives
    you the factor by which to multiply the current velocity, in order to get the
    desired refractive velocity
    =#
    scaling_factor = c/(magnitude(current_velocity)*refractive_index(current_position))
    next_velocity = scaling_factor*current_velocity#temporary... not the real next_velocity. still needs to be rotated

    current_velocity,current_position = next_velocity,next_position
    current_n = refractive_index(current_position)
end

#=
If p in R^2 is a function of x and y, then we can parametrize
x and y so that x = x(t) and y = y(t). Then, if v is current_velocity
in R^2, and v is parametrized with t as well, so that v[1] = x'{t}
and v[2] = y'(t). Then x'(t) is defined as the limit as h->0 of
(x(t+h)-x(t))/h. If instead of 0, we allow h->epsilon, then
x'(t) = (x(t+epsilon)-x(t))/epsilon. We can similarly say for y'(t)
that y'(t) = (y(t+epsilon)-y(t))/epsilon.
Then epsilon*x'(t) = x(t+epsilon) - x(t) and
epsilon*y'(t) = y(t+epsilon) - y(t).
Then epsilon*x'(t) + x(t) = x(t+epsilon)
and epsilon*y'(t) + y(t) = y(t+epsilon).
=#

#=
General sketch:
*photon = [current_velocity,current_position]
*use current_velocity and current_position to find next_velocity.
*use next_velocity to find next_position
*assign: current_velocity,current_position = next_velocity,next_position

currents = [current_position,current_velocity,current_n,current_angle]
nexts = [next_position,next_velocity,refractive_index(current_position),
next_angle]

refractive_index(current_position) = c / magnitude(next_velocity)
magnitude(next_velocity) = c / refractive_index(current_position)

next_velocity is proportional to current_velocity. Therefore
magnitude(next_velocity) = k*magnitude(current_velocity)
=#
