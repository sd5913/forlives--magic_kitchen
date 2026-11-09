"""Translate logical input from multiple adapters into action transitions."""

from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class Transition:
    action: str
    active: bool


class InputRouter:
    """One router per session, used on the game thread or event loop."""

    def __init__(self):
        self._sources: dict[str, InputSource] = {}
        self._holders: dict[str, set[str]] = {}

    def connect(self, name: str) -> "InputSource":
        if not name.strip():
            raise ValueError("Input source name cannot be empty")
        if name in self._sources:
            raise ValueError(f"Input source is already connected: {name}")
        source = InputSource(self, name)
        self._sources[name] = source
        return source

    def _set_active(
        self, source: "InputSource", action: str, active: bool
    ) -> Optional[Transition]:
        if self._sources.get(source.name) is not source:
            return None  # A disconnected adapter may still have queued events.
        if not action.strip():
            raise ValueError("Action name cannot be empty")
        holders = self._holders.get(action)
        if active:
            if holders is None:
                self._holders[action] = {source.name}
                return Transition(action, True)
            holders.add(source.name)
        elif holders is not None and source.name in holders:
            holders.remove(source.name)
            if not holders:
                del self._holders[action]
                return Transition(action, False)
        return None

    def _disconnect(self, source: "InputSource") -> tuple[Transition, ...]:
        if self._sources.get(source.name) is not source:
            return ()
        releases = []
        for action in sorted(self._holders):
            transition = self._set_active(source, action, False)
            if transition is not None:
                releases.append(transition)
        del self._sources[source.name]
        return tuple(releases)

    def suspend(self) -> tuple[Transition, ...]:
        """Release all actions and invalidate every source on pause/focus loss."""
        releases = tuple(Transition(action, False) for action in sorted(self._holders))
        self._holders.clear()
        self._sources.clear()
        return releases


class InputSource:
    """A single connection; reconnect by obtaining a new handle from the router."""

    def __init__(self, router: InputRouter, name: str):
        self._router = router
        self._name = name

    @property
    def name(self) -> str:
        return self._name

    def set_active(self, action: str, active: bool) -> Optional[Transition]:
        return self._router._set_active(self, action, active)

    def disconnect(self) -> tuple[Transition, ...]:
        return self._router._disconnect(self)
