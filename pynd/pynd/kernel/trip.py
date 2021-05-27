class Trip:
    def __init__(self, period: float):
        pass

    def get_timer(self):
        raise NotImplementedError()

    def set_max_time_in_seconds(self, max_time):
        raise NotImplementedError()
