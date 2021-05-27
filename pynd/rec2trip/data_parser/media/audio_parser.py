import logging as log

from rec2trip.timestamper import Timestamper
from .media_parser import MediaParser


class AudioParser(MediaParser):
    """
    Data parser for audio recording entries
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, desc="Audio imported from AudioParser"):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        :param desc: Description of the audio file
        """
        MediaParser.__init__(self, component, output, timestamper, "avi", desc)
