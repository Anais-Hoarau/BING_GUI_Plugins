from .timestamper import Timestamper


class TimeOfIssueTS(Timestamper):

    def __init__(self):
        Timestamper.__init__(self)

    def timestamp(self, time_of_issue: float, idx: int, data: str, timestamp: float=None) -> float:
        return time_of_issue
