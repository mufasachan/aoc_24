from collections import defaultdict

with open('input.txt', mode='r', encoding='utf-8') as reader:
    lines = [line.strip() for line in reader]
n = len(lines)

antenna_to_positions: dict[str, list[tuple[int, int]]] = defaultdict(list)

for i, line in enumerate(lines):
    for j, symbol in enumerate(line):
        if symbol != '.':
            antenna_to_positions[symbol].append((i, j))

positions_antinode: set[tuple[int]] = set()
for positions in antenna_to_positions.values():
    for i in range(len(positions)-1):
        for j in range(i+1, len(positions)):
            dx = positions[j][0]-positions[i][0]
            dy = positions[j][1]-positions[i][1]
            x1 = positions[j][0]+dx
            y1 = positions[j][1]+dy
            x2 = positions[i][0]-dx
            y2 = positions[i][1]-dy

            if (x1 >= 0 and x1 < n and y1 >= 0 and y1 < n):
                positions_antinode.add((x1, y1))
            if (x2 >= 0 and x2 < n and y2 >= 0 and y2 < n):
                positions_antinode.add((x2, y2))
print(f"P1: {len(positions_antinode):4d}")
del positions_antinode

positions_antinode: set[tuple[tuple[int, int]]] = set()
for positions in antenna_to_positions.values():
    positions_antinode |= set(positions)
    for i in range(len(positions)-1):
        for j in range(i+1, len(positions)):
            dx = positions[j][0]-positions[i][0]
            dy = positions[j][1]-positions[i][1]
            x1 = positions[j][0]+dx
            y1 = positions[j][1]+dy
            x2 = positions[i][0]-dx
            y2 = positions[i][1]-dy

            while (x1 >= 0 and x1 < n and y1 >= 0 and y1 < n):
                positions_antinode.add((x1, y1))
                x1 += dx
                y1 += dy
            while (x2 >= 0 and x2 < n and y2 >= 0 and y2 < n):
                positions_antinode.add((x2, y2))
                x2 -= dx
                y2 -= dy
print(f"P2: {len(positions_antinode):4d}")
