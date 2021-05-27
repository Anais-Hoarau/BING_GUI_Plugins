import logging as log
from abc import ABC, abstractmethod
from typing import Dict, List, Tuple, Any

from pynd import MetaVariableBaseType


class PupilLabsSubParser(ABC):
    """
    This abstract class defines how to subparse a specific data field of the Pupil Labs headset dictionary.
    Those data fields can be of different types amongst :
        - an integer
        - a float
        - a string
        - a list of two or three floats
        - a list of dictionaries (TODO Implement such subparser for SurfaceParser)
        - a dictionary, itself possibly containing data with different types amongst:
            * a float
            * a list of two or three floats
    """

    def __init__(self, key: str, entries: List[Tuple[str, MetaVariableBaseType]]):
        """

        :param key: Dictionary key identifying the data field needed to be parsed
        :param entries: List of tuple containing the (name, type) of the variables needed to be extracted
        """
        self.key = key
        self.entries = entries
        self.data: List[Tuple[float, List[Any]]] = []

    def uuid(self) -> str:
        return self.key

    @abstractmethod
    def subparse_data(self, data, ts) -> List[Any]:
        """
        Defines how the data field is parsed
        :param data: Data field
        :param ts: Timecode
        :return: Return the piece of data added to self.data
        TODO Delete that ugly return part currently used in the RecursiveDictSubParser
        """
        return []


class SingleEltSubParser(PupilLabsSubParser):
    """
    This class parse a single element type of datum (integer, float or string)
    """
    def __init__(self, key: str, entry: List[Tuple[str, MetaVariableBaseType]]):
        PupilLabsSubParser.__init__(self, key, entry)

    def subparse_data(self, data, ts) -> List[Any]:
        self.data.append((ts, [data]))
        return [data]


class ListOfEltsSubParser(PupilLabsSubParser):
    """
    This class parse a list of element (typically a list of two or three floats)
    """
    def __init__(self, key: str, entries: List[Tuple[str, MetaVariableBaseType]]):
        PupilLabsSubParser.__init__(self, key, entries)

    def subparse_data(self, data, ts) -> List[Any]:
        if len(data) != len(self.entries):
            log.warning(f"Different number of vector entries and read values detected by ListOfEltsSubParser "
                        f"for {self.key}, ignoring line")
            return []
        self.data.append((ts, data))
        return data


class GazeDictSubParser(PupilLabsSubParser):
    """
    This class specifically parse the dictionaries associated to the keys "eye_centers_3d" and "gaze_normals_3d" from
    gaze data.
    TODO Probably possible to delete this subparser and use the RecursiveDictSubarser instead
    """
    def __init__(self, key: str, entries: List[Tuple[str, MetaVariableBaseType]]):
        PupilLabsSubParser.__init__(self, key, entries)

    def subparse_data(self, data, ts) -> List[Any]:
        """
        The data parsed here is a dictionary with two keys ('0' and '1'), containing data from each eye. One key can be
        missing if the corresponding eye was not detected at this timestamp.
        :param data: Data field
        :param ts: Timecode
        :return: Return the piece of data added to self.data
        """
        tmp_data: List[Any] = []
        # TODO Let pynd accept None so we are not obliged to use NaN for missing data...
        empty_data = ['nan', 'nan', 'nan']
        for key in ['0', '1']:
            if key in data.keys():
                tmp_data += data[key]
            else:
                tmp_data += empty_data
        self.data.append((ts, tmp_data))
        return tmp_data


class RecursiveDictSubParser(PupilLabsSubParser):
    """
    This class is used to parse dictionaries. It offers the possibility to use the PupilLabsSubParser objects to parse
    the different values of the dictionary.
    """
    def __init__(self, key: str):
        entries: List[Tuple[str, MetaVariableBaseType]] = []
        PupilLabsSubParser.__init__(self, key, entries)
        self._subparsers: Dict[str, PupilLabsSubParser] = {}

    def add_subparser(self, subparser: PupilLabsSubParser) -> None:
        """
        Add the given subparser to the list of subparsers that will be used to convert the recording to a trip
        :param subparser: PupilLabsSubParser object used to parse a specific value of the dictionary
        :return:
        """
        self._subparsers[subparser.uuid()] = subparser
        self.entries += subparser.entries

    def subparse_data(self, data, ts) -> List[Any]:
        """
        Parse the dictionary by calling the subparse_data method of each of its subparsers.
        # TODO Find a better way to get back the data from each subparsers
        :param data: Data field
        :param ts: Timecode
        :return: Return the piece of data added to self.data
        """
        subparser_data = []
        for key in data.keys():
            subparser_id = key
            subparser = self._subparsers.get(subparser_id, None)
            if subparser is None:
                # TODO Log something
                continue
            subparser_data += subparser.subparse_data(data[key], ts)
        self.data.append((ts, subparser_data))
        return subparser_data
