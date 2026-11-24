"""Recognize 0–5 raised fingers and send cooking actions to Godot.

Run from the repository root after installing tools/gesture-requirements.txt.
Press Q in the camera window to stop.
"""

from __future__ import annotations

import json
import socket
import time

import cv2
import mediapipe as mp


HOST = "127.0.0.1"
PORT = 4242
STABLE_FRAMES = 8
NO_HAND_RELEASE_FRAMES = 5
ACTIONS = {
    0: ("roll_wrap", "fist · roll wrap"),
    1: ("add_duck", "1 finger · sliced duck"),
    2: ("add_hawthorn", "2 fingers · hawthorn"),
    3: ("add_scallion", "3 fingers · scallion"),
    4: ("add_cucumber", "4 fingers · cucumber"),
    5: ("add_sauce", "5 fingers · sweet bean sauce"),
}


def send(sock: socket.socket, payload: dict) -> None:
    sock.sendto(json.dumps(payload).encode("utf-8"), (HOST, PORT))


def finger_count(landmarks, handedness: str) -> int:
    # Index, middle, ring and little fingers are raised when their tips are
    # above their PIP joints in the upright camera view.
    count = sum(
        landmarks[tip].y < landmarks[pip].y
        for tip, pip in ((8, 6), (12, 10), (16, 14), (20, 18))
    )
    thumb_open = (
        landmarks[4].x < landmarks[3].x
        if handedness == "Right"
        else landmarks[4].x > landmarks[3].x
    )
    return count + int(thumb_open)


def main() -> int:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    camera = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    if not camera.isOpened():
        send(sock, {"type": "status", "message": "camera could not be opened"})
        return 1

    hands_api = mp.solutions.hands
    drawer = mp.solutions.drawing_utils
    candidate = None
    candidate_frames = 0
    missing_frames = 0
    active_action = None
    send(sock, {"type": "status", "message": "camera connected · show a stable gesture"})

    with hands_api.Hands(
        static_image_mode=False,
        max_num_hands=1,
        model_complexity=0,
        min_detection_confidence=0.65,
        min_tracking_confidence=0.65,
    ) as hands:
        while True:
            ok, frame = camera.read()
            if not ok:
                break
            frame = cv2.flip(frame, 1)
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            result = hands.process(rgb)

            count = None
            if result.multi_hand_landmarks:
                missing_frames = 0
                hand = result.multi_hand_landmarks[0]
                handedness = result.multi_handedness[0].classification[0].label
                count = finger_count(hand.landmark, handedness)
                drawer.draw_landmarks(frame, hand, hands_api.HAND_CONNECTIONS)
                if count == candidate:
                    candidate_frames += 1
                else:
                    candidate = count
                    candidate_frames = 1

                if candidate_frames >= STABLE_FRAMES:
                    action, label = ACTIONS[count]
                    if action != active_action:
                        if active_action:
                            send(sock, {"type": "gesture", "action": active_action, "active": False, "label": "released"})
                        active_action = action
                        send(sock, {"type": "gesture", "action": action, "active": True, "label": label})
            else:
                missing_frames += 1
                candidate = None
                candidate_frames = 0
                if missing_frames >= NO_HAND_RELEASE_FRAMES and active_action:
                    send(sock, {"type": "gesture", "action": active_action, "active": False, "label": "waiting for hand"})
                    active_action = None

            shown = "No hand" if count is None else f"Fingers: {count}"
            cv2.putText(frame, shown, (20, 42), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (40, 220, 80), 2)
            cv2.putText(frame, "Hold gesture steady; Q quits", (20, 78), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (240, 240, 240), 2)
            cv2.imshow("Magic Kitchen Gesture Camera", frame)
            if cv2.waitKey(1) & 0xFF in (ord("q"), 27):
                break

    if active_action:
        send(sock, {"type": "gesture", "action": active_action, "active": False, "label": "camera stopped"})
    send(sock, {"type": "status", "message": "camera bridge stopped"})
    camera.release()
    cv2.destroyAllWindows()
    sock.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
