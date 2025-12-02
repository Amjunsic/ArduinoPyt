from collections import deque
import time

class Node:
    def __init__(self, node_id):
        self.node_id = node_id
        self.connections = []

    def add_connection(self, neighbor_id, direction):
        self.connections.append((neighbor_id, direction))

class Graph:
    def __init__(self):
        self.nodes = {}

    def add_edge(self, from_id, to_id, direction):
        if from_id not in self.nodes: self.nodes[from_id] = Node(from_id)
        if to_id not in self.nodes: self.nodes[to_id] = Node(to_id)
        self.nodes[from_id].add_connection(to_id, direction)

    def find_shortest_hops(self, start_id, target_id):
        # ... (이전 BFS 코드와 동일) ...
        if start_id not in self.nodes or target_id not in self.nodes: return None
        queue = deque([start_id])
        path_info = {start_id: (None, None)}
        
        while queue:
            curr = queue.popleft()
            if curr == target_id:
                return self._reconstruct_path(start_id, target_id, path_info)
            
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


# --- [로봇 제어를 위한 추가 로직] ---

def create_navigation_map(path_list):
    """
    BFS 결과를 로봇이 즉시 조회할 수 있는 딕셔너리로 변환
    Output 예시: {101: 'Left', 105: 'Straight', ...}
    """
    nav_map = {}
    if not path_list:
        return nav_map
        
    for current_node, direction, next_node in path_list:
        nav_map[current_node] = direction
        
    # 마지막 도착 노드에서의 행동 정의 (예: 정지)
    last_node = path_list[-1][2]
    nav_map[last_node] = 'STOP'
    
    return nav_map



# 1. 지도 데이터 입력 (아루코 마커 ID를 Node ID로 사용)
robot_map = Graph()

# 예: 1번 마커에서 직진하면 2번, 우회전하면 3번
robot_map.add_edge(1, 2, 'STRAIGHT')
robot_map.add_edge(1, 3, 'RIGHT')
robot_map.add_edge(2, 4, 'LEFT')
robot_map.add_edge(3, 4, 'STRAIGHT')
robot_map.add_edge(4, 5, 'STOP_POINT')

# 2. 출발 전 경로 계산
current_aruco_id = 1
target_aruco_id = 5

print(" 경로 계산 중...")
raw_path = robot_map.find_shortest_hops(current_aruco_id, target_aruco_id)

if raw_path:
    # **핵심**: 경로 리스트를 검색하기 쉬운 딕셔너리로 변환
    navigation_instructions = create_navigation_map(raw_path)
    print(f" 생성된 네비게이션 명령: {navigation_instructions}")
else:
    print(" 경로 없음!")
    navigation_instructions = {}


# 3. 로봇 메인 제어 루프 (Simulated)
# 실제로는 while True: 안에 카메라 읽는 코드가 들어갑니다.

def robot_main_loop():
    print("\n--- 로봇 주행 시작 ---")
    
    # 시뮬레이션을 위해 로봇이 만나는 마커 순서를 가정
    simulated_detected_markers = [1, 3, 4, 5] 
    
    last_processed_marker = -1  # 중복 인식 방지용 변수
    
    for detected_id in simulated_detected_markers:
        print(f"\n[카메라] 아루코 마커 ID {detected_id} 감지됨!")
        
        # (중요) 방금 처리한 마커를 계속 보고 있다면 무시 (Debouncing)
        if detected_id == last_processed_marker:
            continue
            
        # 1. 갈림길 판단: 내 경로상에 있는 마커인가?
        if detected_id in navigation_instructions:
            action = navigation_instructions[detected_id]
            
            print(f"  >> [판단] 현재 위치 {detected_id}번 노드. 수행할 행동: '{action}'")
            
            # 2. 모터 제어 함수 호출
            if action == 'LEFT':
                # motor_turn_left()
                print("  >> 🚗 좌회전 수행")
            elif action == 'RIGHT':
                # motor_turn_right()
                print("  >> 🚗 우회전 수행")
            elif action == 'STRAIGHT':
                # motor_go_straight_through_intersection()
                print("  >> 🚗 교차로 직진 통과")
            elif action == 'STOP':
                # motor_stop()
                print("  >> 🛑 목적지 도착! 정지.")
                break
            
            last_processed_marker = detected_id
            
        else:
            print("  >> [경고] 경로에 없는 마커입니다. (재탐색 필요 혹은 무시)")
            # 여기서 필요하다면 다시 BFS를 돌려서 경로를 재설정(Rerouting) 할 수 있습니다.

# 실행
robot_main_loop()