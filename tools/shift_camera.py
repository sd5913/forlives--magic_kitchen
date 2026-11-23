"""Send raw finger counts to the shared shift; the game owns timing and action mapping.

Reuses the cooking contributor's landmark interpretation, not their station-specific
2/4 ingredient mapping. Only counts leave this process over loopback UDP.
"""
import json
import socket
import sys


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send(payload):
        sock.sendto(json.dumps(payload).encode("utf-8"), ("127.0.0.1", 4243))

    camera = None
    try:
        import cv2
        import mediapipe as mp
        from gesture_camera import finger_count
        if not hasattr(mp, "solutions"):
            raise RuntimeError("Use the pinned MediaPipe version in gesture-requirements.txt")
        camera = cv2.VideoCapture(0, cv2.CAP_DSHOW) if sys.platform == "win32" else cv2.VideoCapture(0)
        if not camera.isOpened():
            raise RuntimeError("Camera unavailable or access denied; use mouse/keyboard")
        send({"type": "status", "message": "Camera connected · show a stable gesture; lower hand between actions"})
        with mp.solutions.hands.Hands(max_num_hands=1, model_complexity=0,
                                      min_detection_confidence=0.65,
                                      min_tracking_confidence=0.65) as hands:
            while True:
                ok, frame = camera.read()
                if not ok:
                    raise RuntimeError("Camera frame unavailable; use mouse/keyboard")
                frame = cv2.flip(frame, 1)
                result = hands.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                number = -1
                if result.multi_hand_landmarks:
                    hand = result.multi_hand_landmarks[0]
                    side = result.multi_handedness[0].classification[0].label
                    number = finger_count(hand.landmark, side)
                    mp.solutions.drawing_utils.draw_landmarks(frame, hand, mp.solutions.hands.HAND_CONNECTIONS)
                send({"type": "sample", "number": number})
                cv2.putText(frame, "No hand" if number < 0 else f"Fingers: {number}",
                            (20, 42), cv2.FONT_HERSHEY_SIMPLEX, 1, (40, 220, 80), 2)
                cv2.putText(frame, "Lower hand between actions; Q quits", (20, 78),
                            cv2.FONT_HERSHEY_SIMPLEX, .65, (240, 240, 240), 2)
                cv2.imshow("Magic Kitchen Camera", frame)
                if cv2.waitKey(1) & 0xFF in (ord("q"), 27):
                    break
        return 0
    except (ImportError, RuntimeError) as error:
        send({"type": "status", "message": str(error)})
        print(error, file=sys.stderr)
        return 1
    finally:
        send({"type": "sample", "number": -1})
        if camera is not None:
            camera.release()
        if "cv2" in locals():
            cv2.destroyAllWindows()
        sock.close()


if __name__ == "__main__":
    raise SystemExit(main())
