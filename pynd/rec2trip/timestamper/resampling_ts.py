from .timestamper import Timestamper


class ResamplingTS(Timestamper):

    def __init__(self, frequency: float):
        Timestamper.__init__(self)
        self._start_time: float = None
        self._frequency: float = frequency

    def timestamp(self, time_of_issue: float, idx: int, data: str, timestamp: float=None) -> float:
        if self._start_time is None:
            self._start_time = timestamp or time_of_issue
        return self._start_time + idx / self._frequency
