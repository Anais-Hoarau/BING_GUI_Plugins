import os
import logging as log

from pynd import MetaVideoFile
from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper


class MediaParser(DataParser):
    """
    Data parser for media recording entries
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, ext: str=None,
                 desc="Media imported from MediaParser"):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        :param: ext: Extension of the media file
        :param desc: Description of the media file
        """
        DataParser.__init__(self, component, output, timestamper)
        self._ext = ext
        self._desc = desc
        self._import_needed = True

    def _add_media_to_trip(self, path: str, offset: float, description: str = "") -> None:
        meta_video = MetaVideoFile(path, offset, description)
        self._trip.add_video_file(meta_video)

    def _media_path(self) -> str:
        """

        :return: The path to the media file within the folder containing the *.rec file
        """
        root, file = os.path.split(self._rec_file)
        filename, ext = os.path.splitext(file)

        # Build possible paths
        full_path_w_subfolder = os.path.join(root, f"{self._component}_{self._output}", f"{filename}_{self._component}_{self._output}.{self._ext}")
        relative_path_w_subfolder = os.path.join(".", f"{self._component}_{self._output}", f"{filename}_{self._component}_{self._output}.{self._ext}")
        full_path_wo_subfolder = os.path.join(root, f"{filename}_{self._component}_{self._output}.{self._ext}")
        relative_path_wo_subfolder = os.path.join(".", f"{filename}_{self._component}_{self._output}.{self._ext}")

        # Find the file, which can be in the *.rec folder, or in one of its subfolders
        path: str = None
        if os.path.isfile(full_path_w_subfolder):
            path = relative_path_w_subfolder
        elif os.path.isfile(full_path_wo_subfolder):
            path = relative_path_wo_subfolder
        else:
            log.warning(f"File not found for {self._component}.{self._output}")

        return path

    def start_parse(self) -> None:
        pass

    def parse_data(self, data: str, ts: float) -> None:
        if self._import_needed:
            self._import_needed = False
            media_path = self._media_path()
            if media_path is not None:
                log.info(f"Adding media: {media_path}")
                self._add_media_to_trip(media_path, -ts, self._desc)

    def end_parse(self) -> None:
        pass
