from collections import deque

#Node 클래스: ID와 연결 정보(이웃ID, 방향)만 관리
class Node:
    def __init__(self, node_id):
        self.node_id = node_id
        self.connections = []

    def add_connection(self, neighbor_id, direction):
        self.connections.append((neighbor_id, direction))

# 2. Graph 클래스
class Graph:
    def __init__(self):
        self.nodes = {}

    def add_edge(self, from_id, to_id, direction):
        """노드와 연결 정보를 추가합니다"""
        if from_id not in self.nodes:
            self.nodes[from_id] = Node(from_id)
        if to_id not in self.nodes:
            self.nodes[to_id] = Node(to_id)
        
        # 방향 정보와 함께 연결
        self.nodes[from_id].add_connection(to_id, direction)

    def find_shortest_hops(self, start_id, target_id):
        """BFS로 노드 개수가 가장 적은 최단 경로를 찾기"""
        
        if start_id not in self.nodes or target_id not in self.nodes:
            return None # 노드가 존재하지 않음

        # BFS를 위한 큐 생성 및 초기화
        queue = deque([start_id])
        
        # 방문 여부 및 경로 추적용 {현재노드: (이전노드, 왔던방향)}
        # visited 역할도 겸함 (키가 있으면 방문한 것)
        path_info = {start_id: (None, None)}

        while queue:
            current_id = queue.popleft()

            # BFS는 가장 먼저 발견한 경로가 최단 경로(최소 홉)임이 보장됨
            if current_id == target_id:
                return self._reconstruct_path(start_id, target_id, path_info)

            # 현재 노드와 연결된 이웃 탐색
            for neighbor_id, direction in self.nodes[current_id].connections:
                # 아직 방문하지 않은 노드만 큐에 추가
                if neighbor_id not in path_info:
                    path_info[neighbor_id] = (current_id, direction)
                    queue.append(neighbor_id)
        
        return None # 갈 수 있는 길이 없음

    def _reconstruct_path(self, start_id, target_id, path_info):
        """역추적하여 경로 생성"""
        path = []
        curr = target_id
        
        while curr != start_id:
            prev_node, direction = path_info[curr]
            path.append((prev_node, direction, curr))
            curr = prev_node
        
        # 역순이므로 뒤집어서 반환
        return path[::-1]

# --- 실행 예시 ---

# 1. 그래프 생성
subway_map = Graph()

# 2. 데이터 입력 (거리는 입력하지 않습니다)
# 상황: A에서 D로 가려함.
# 경로 1: A -> B -> C -> D (3번 이동)
# 경로 2: A -> E -> D (2번 이동) -> BFS는 이걸 찾아야 함

subway_map.add_edge('A', 'B', '우회전')
subway_map.add_edge('B', 'C', '직진')
subway_map.add_edge('C', 'D', '좌회전')

subway_map.add_edge('A', 'E', '좌회전')
subway_map.add_edge('E', 'D', '우회전')

# 3. 길찾기 실행
start = 'A'
target = 'D'

result_path = subway_map.find_shortest_hops(start, target)

# 4. 결과 출력
print(f"--- [ {start} ] 에서 [ {target} ] 최소 노드 이동 경로 ---")

if result_path:
    print(f"총 거쳐가는 구간 수: {len(result_path)}")
    for u, direction, v in result_path:
        print(f"  📍 [{u}] 에서 '{direction}' -> [{v}]")
else:
    print("경로가 존재하지 않습니다.")