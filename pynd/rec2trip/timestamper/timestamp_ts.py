import logging as log

from .timestamper import Timestamper


class TimestampTS(Timestamper):

    def __init__(self):
        Timestamper.__init__(self)

    def timestamp(self, time_of_issue: float, idx: int, data: str, timestamp: float=None) -> float:
        if timestamp is None:
            # TODO print only once
            # TODO log component/output_name fail
            log.warning("TimestampTS can't find timestamp")
            return time_of_issue
        else:
            return timestamp
