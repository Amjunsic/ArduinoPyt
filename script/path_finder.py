from collections import deque

class Node:
    def __init__(self, node_id):
        self.node_id = node_id
        self.connections = []

    def add_connection(self, neighbor_id, direction):
        self.connections.append((neighbor_id, direction))


class Graph:
    def __init__(self):
        self.nodes = {}
        self.path = []

    def add_edge(self, from_id, to_id, direction):
        if from_id not in self.nodes: self.nodes[from_id] = Node(from_id)
        if to_id not in self.nodes: self.nodes[to_id] = Node(to_id)
        self.nodes[from_id].add_connection(to_id, direction)

    def find_shortest_hops(self, start_id, target_id):
        self.path = []
        
        if start_id not in self.nodes or target_id not in self.nodes: return None
        queue = deque([start_id])
        path_info = {start_id: (None, None)}
        
        while queue:
            curr = queue.popleft()
            if curr == target_id:
                self.path = self._reconstruct_path(start_id, target_id, path_info)
                return self.path
            
            for neighbor, direction in self.nodes[curr].connections:
                if neighbor not in path_info:
                    path_info[neighbor] = (curr, direction)
                    queue.append(neighbor)
        return None

    def _reconstruct_path(self, start_id, target_id, path_info):
        path = []
        curr = target_id
        while curr != start_id:
            prev_node, direction = path_info[curr]
            path.append((prev_node, direction, curr)) # (현재노드, 할행동, 다음노드)
            curr = prev_node
        return path[::-1]
    
    def create_navigation_map(self):
        nav_map = {}
        if not self.path:
            return nav_map
            
        for current_node, direction, next_node in self.path:
            nav_map[current_node] = direction
            
        # 마지막 도착 노드에서의 행동 정의 (예: 정지)
        last_node = self.path[-1][2]
        nav_map[last_node] = 'STOP'
        
        return nav_map
