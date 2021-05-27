from abc import ABC, abstractmethod


class Timestamper(ABC):

    def __init__(self):
        pass

    @abstractmethod
    def timestamp(self, time_of_issue: float, idx: int, data: str, timestamp: float=None) -> float:
        pass
