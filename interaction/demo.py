"""Replay sample input without an engine, camera or hardware permissions."""

from .router import InputRouter


def main():
    router = InputRouter()
    keyboard = router.connect("keyboard-sample")
    gesture = router.connect("gesture-sample")

    def show(label, *events):
        changes = [
            f"{event.action} -> {'active' if event.active else 'inactive'}"
            for event in events if event is not None
        ]
        print(f"{label}: {', '.join(changes) or 'no change'}")

    show("Simulated gesture starts", gesture.set_active("demo_action", True))
    show("Keyboard holds the same action", keyboard.set_active("demo_action", True))
    show("Simulated tracking lost", *gesture.disconnect())
    show("Late gesture ignored", gesture.set_active("demo_action", True))
    show("Keyboard releases", keyboard.set_active("demo_action", False))
    gesture = router.connect("gesture-sample")
    show("New tracking session starts", gesture.set_active("demo_action", True))
    show("Window loses focus", *router.suspend())


if __name__ == "__main__":
    main()
