class Error(Exception):
    pass


class ArgumentException(Error):
    pass


class DataException(Error):
    pass


class EventException(Error):
    pass


class SituationException(Error):
    pass


class FileException(Error):
    pass


class MetaInfosException(Error):
    pass


class NetworkException(Error):
    pass


class ObserverException(Error):
    pass


class PluginException(Error):
    pass


class ContentException(Error):
    pass
