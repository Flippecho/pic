# import zone
import queue
import random
import heapq
import numpy as np
from matplotlib import pyplot as plt


# functions definition


def getX(index):
    return (index - 1) // scale + 1


def getY(index):
    return (index - 1) % scale + 1


def getPos(index):
    return getX(index), getY(index)


def heuristic(pos1, pos2):
    return abs(getX(pos1) - getX(pos2)) + abs(getY(pos1) - getY(pos2))


def getPriority(value, hq):
    for tuple_item in hq:
        if tuple_item[1] == value:
            return tuple_item[0]
    return False


def isValid(p, q):
    return q in range(1, scale * scale + 1) and q not in is_blocked.keys() and heuristic(p, q) == 1


# Maze Initialization
scale = int(input("请输入迷宫规模（整数）: "))
picture1 = np.ones((scale + 1, scale + 1, 3), dtype=np.uint8) * 255
picture2 = np.ones((scale + 1, scale + 1, 3), dtype=np.uint8) * 255
picture3 = np.ones((scale + 1, scale + 1, 3), dtype=np.uint8) * 255
is_blocked = dict()

for i in range(1, int(scale * scale * 0.3 + 1)):
    temp_random = random.randint(1, scale * scale)
    picture1[getX(temp_random) - 1][getY(temp_random) - 1] = [0, 0, 0]
    picture2[getX(temp_random) - 1][getY(temp_random) - 1] = [0, 0, 0]
    picture3[getX(temp_random) - 1][getY(temp_random) - 1] = [0, 0, 0]
    is_blocked[temp_random] = True

start = random.randint(1, scale * scale)
while start in is_blocked.keys():
    start = random.randint(1, scale * scale)

print('\nStart:', getPos(start))

goal = random.randint(1, scale * scale)
while goal in is_blocked.keys():
    goal = random.randint(1, scale * scale)

print('Goal:', getPos(goal))

# Algorithm 1: Greedy Algorithm -- best not promised

frontier = []
came_from = dict()
heapq.heappush(frontier, (heuristic(start, goal), start))
came_from[start] = None

steps = 0
costs = 0
while frontier:
    steps += 1
    current = heapq.heappop(frontier)[1]

    if current == goal:
        heapq.heappush(frontier, (0, goal))
        break

    for item in (current - scale, current + 1, current + scale, current - 1):
        if isValid(current, item) and item not in came_from.keys():
            priority = heuristic(goal, item)
            heapq.heappush(frontier, (priority, item))
            came_from[item] = current

print('\nGreedy Algorithm:')
if not frontier:
    print("No path found!")
else:
    path_list = list()
    pos = goal
    while pos is not None:
        path_list.append(pos)
        pos = came_from[pos]

    print('Path:', getPos(path_list.pop()), end='')
    while path_list:
        curPos = path_list.pop()
        picture1[getX(curPos) - 1][getY(curPos) - 1] = [255, 0, 0]
        print(' -->', getPos(curPos), end='')
        costs += 1

    print('\nsteps:', steps)
    print('costs:', costs)

# Algorithm 2: Brand-and-Bound Algorithm -- best promised

frontier = queue.Queue()
came_from = dict()
frontier.put(start)
came_from[start] = None

steps = 0
costs = 0
while not frontier.empty():
    steps += 1
    current = frontier.get()

    if current == goal:
        frontier.put(goal)
        break

    for item in (current - scale, current + 1, current + scale, current - 1):
        if isValid(current, item) and item not in came_from.keys():
            frontier.put(item)
            came_from[item] = current

print('\nBFS Algorithm:')
if frontier.empty():
    print("No path found!")
else:
    path_list = list()
    pos = goal
    while pos is not None:
        path_list.append(pos)
        pos = came_from[pos]

    print('Path:', getPos(path_list.pop()), end='')
    while path_list:
        curPos = path_list.pop()
        print(' -->', getPos(curPos), end='')
        picture2[getX(curPos) - 1][getY(curPos) - 1] = [0, 255, 0]
        costs += 1

    print('\nsteps:', steps)
    print('costs:', costs)

a2 = costs

# Algorithm 3: A* Algorithm —— best promised

frontier = []
came_from = dict()
cost_so_far = dict()
heapq.heappush(frontier, (heuristic(start, goal), start))
came_from[start] = None
cost_so_far[start] = 0

steps = 0
while frontier:
    steps += 1
    (priority, current) = heapq.heappop(frontier)

    if current == goal:
        heapq.heappush(frontier, (cost_so_far[goal], goal))
        break

    for item in (current - scale, current + 1, current + scale, current - 1):
        if isValid(current, item):
            new_cost = cost_so_far[current] + 1
            if item not in cost_so_far or new_cost < cost_so_far[item]:
                cost_so_far[item] = new_cost
                priority = new_cost + heuristic(goal, item)
                temp = getPriority(item, frontier)
                if item in cost_so_far and temp is not False:
                    frontier.remove((temp, item))
                    heapq.heapify(frontier)
                heapq.heappush(frontier, (priority, item))
                came_from[item] = current

print('\nA* Algorithm:')
if not frontier:
    print("No path found!")
else:
    path_list = list()
    pos = goal
    while pos is not None:
        path_list.append(pos)
        pos = came_from[pos]

    costs = 0
    print('Path:', getPos(path_list.pop()), end='')
    while path_list:
        curPos = path_list.pop()
        print(' -->', getPos(curPos), end='')
        picture3[getX(curPos) - 1][getY(curPos) - 1] = [0, 0, 255]
        costs += 1

    print('\nsteps:', steps)
    print('costs:', costs)

if a2 != costs:
    print("\nDifferent.")
else:
    print("\nSame.", a2, costs)

picture1[getX(start) - 1][getY(start) - 1] = [255, 255, 0]
picture2[getX(start) - 1][getY(start) - 1] = [255, 255, 0]
picture3[getX(start) - 1][getY(start) - 1] = [255, 255, 0]

picture1[getX(goal) - 1][getY(goal) - 1] = [255, 255, 0]
picture2[getX(goal) - 1][getY(goal) - 1] = [255, 255, 0]
picture3[getX(goal) - 1][getY(goal) - 1] = [255, 255, 0]

plt.figure(1)
plt.imshow(picture1)
plt.figure(2)
plt.show()
plt.imshow(picture2)
plt.show()
plt.figure(3)
plt.imshow(picture3)
plt.show()
