import unittest

from interaction.router import InputRouter, Transition


class InputRouterTests(unittest.TestCase):
    def setUp(self):
        self.router = InputRouter()
        self.keyboard = self.router.connect("keyboard")
        self.gesture = self.router.connect("gesture")

    def test_repeat_press_and_release_emit_only_edges(self):
        self.assertIsNone(self.keyboard.set_active("action", False))
        self.assertEqual(self.keyboard.set_active("action", True), Transition("action", True))
        self.assertIsNone(self.keyboard.set_active("action", True))
        self.assertEqual(self.keyboard.set_active("action", False), Transition("action", False))
        self.assertIsNone(self.keyboard.set_active("action", False))

    def test_shared_action_stays_active_until_last_source_releases(self):
        self.keyboard.set_active("action", True)
        self.assertIsNone(self.gesture.set_active("action", True))
        self.assertEqual(self.gesture.disconnect(), ())
        self.assertEqual(self.keyboard.set_active("action", False), Transition("action", False))

    def test_tracking_loss_releases_only_gesture_actions(self):
        self.gesture.set_active("action_a", True)
        self.keyboard.set_active("action_b", True)
        self.assertEqual(self.gesture.disconnect(), (Transition("action_a", False),))
        self.assertEqual(self.keyboard.set_active("action_b", False), Transition("action_b", False))

    def test_disconnected_handle_cannot_affect_reconnected_source(self):
        self.gesture.disconnect()
        replacement = self.router.connect("gesture")
        self.assertEqual(replacement.set_active("action", True), Transition("action", True))
        self.assertIsNone(self.gesture.set_active("action", False))
        self.assertEqual(self.gesture.disconnect(), ())
        self.assertEqual(replacement.set_active("action", False), Transition("action", False))

    def test_suspend_releases_shared_action_once_and_ignores_queued_events(self):
        self.keyboard.set_active("shared", True)
        self.gesture.set_active("shared", True)
        self.gesture.set_active("another", True)
        self.assertEqual(
            self.router.suspend(),
            (Transition("another", False), Transition("shared", False)),
        )
        self.assertIsNone(self.keyboard.set_active("shared", True))
        self.assertEqual(self.router.suspend(), ())
        new_keyboard = self.router.connect("keyboard")
        self.assertEqual(new_keyboard.set_active("shared", True), Transition("shared", True))

    def test_duplicate_live_source_rejected(self):
        with self.assertRaises(ValueError):
            self.router.connect("gesture")


if __name__ == "__main__":
    unittest.main()
