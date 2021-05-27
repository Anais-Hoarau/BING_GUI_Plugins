import sqlite3
import logging as log
from collections import defaultdict
import subprocess
import os
import re
from multiprocessing import Pool, cpu_count
import argparse

LOG_FORMAT = '%(asctime)-15s [%(levelname)-8s]: %(message)s'
REC_HEADER = "RTMaps Runtime Release v4.3.0 (build 262912) for Win32\n\
Copyright (c) 2000-2016 INTEMPORA S.A.\n\
Session: unspecified\n\
Launched at 00:00:00.000 (00/00/0000)\n\
[Data]\n"


class BindData:
    """
    Parent class for all types of data from a *.trip file that can be converted into a *.rec file
    """

    def __init__(self):
        self._rec_init = "{timecode} @ Record {source}.{name}({source}.{name}[{type_param}]) as {type_name}\n"
        self.timecodes = []
        self.count = 0
        self.next_timecode = 0

    def _init_timecodes(self):
        if len(self.timecodes) > 0:
            self.next_timecode = self.timecodes[0]

    def format_row_at_time(self, timecode):
        if timecode != self.next_timecode:
            return "", ""

        t = self.format_timecode(timecode)

        rows, init = self.format_data_at_time_child(t)

        self.count += 1
        if self.count < len(self.timecodes):
            self.next_timecode = self.timecodes[self.count]
        return rows, init

    @staticmethod
    def format_timecode(timecode):
        seconds, decimals = divmod(timecode, 1)
        minutes, seconds = divmod(seconds, 60)
        return "%02d:%09.6f" % (minutes, seconds + decimals)

    def format_data_at_time_child(self, timecode_f):
        return "", ""


class BindVideo(BindData):
    """
    Class to load a video from a trip, reencode it into the correct *.rec format, and insert video
    timestamps into the *.rec file
    """

    def __init__(self, video_path, offset, rec_name, rec_dir):
        BindData.__init__(self)
        self._rec_value = "{timecode} / {source}.{name}#{count}@{timecode_v}\n"
        self.source = "bind"
        self.name = "video"
        # video_ext = os.path.splitext(video_path)[-1]
        video_ext = ".avi"

        # Getting framerate & duration
        result = subprocess.Popen(["ffprobe", "-show_streams", video_path],
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        framerate = None
        duration = None
        for l in result.stdout.readlines():
            ld = l.decode("utf-8", "ignore")
            m = re.search("r_frame_rate=(\d+)/1", ld)
            if m:
                framerate = int(m.group(1))
            m = re.search("duration=(\d+\.\d+)", ld)
            if m:
                duration = float(m.group(1))

        # Generating timestamps
        self.video_timecodes = []
        video_timecode = 0.
        timecode = -offset
        count = 0
        while True:
            self.timecodes.append(timecode)
            self.video_timecodes.append(video_timecode)
            count += 1
            video_timecode = count / framerate
            timecode = video_timecode - offset
            if video_timecode > duration:
                break

        # Copying video
        log.info("Reencoding video")
        video_name_dist = rec_name + "_" + self.source + "_" + self.name
        video_path_dist = os.path.join(rec_dir, video_name_dist + video_ext)
        
        # Checking if video was alreadt converted... using a dirty trick
        inf_path = os.path.join(rec_dir, video_name_dist + ".inf")
        if not os.path.exists(inf_path):
            fnull = open(os.devnull, 'w')
            h = subprocess.Popen(["ffmpeg", "-y", "-i", video_path, "-an", "-c:v", "copy", video_path_dist])
            h.wait()
            fnull.close()

            # Creating inf file
            with open(inf_path, "w") as inf:
                inf.write("avi\n0\n720\n576\nGPJM\nI420\nCOLR\n")

        self._init_timecodes()

    def format_data_at_time_child(self, t):
        init = ""
        timecode_v = self.format_timecode(self.video_timecodes[self.count])
        rows = self._rec_value.format(timecode=t,
                                      source=self.source,
                                      name=self.name,
                                      count=self.count,
                                      timecode_v=timecode_v)
        if self.count == 0:
            init += self._rec_init.format(timecode=t,
                                          source=self.source,
                                          name=self.name,
                                          type_param="0x40,,,16,0",
                                          type_name="video_file")
        return rows, init


class BindTable(BindData):
    """
    Class to load a *.trip table and convert it into a *.rec file
    """

    def __init__(self, name, conn, data_to_export):
        BindData.__init__(self)
        self._rec_value = "{timecode} / {source}.{name}#{count}@{timecode}={value}\n"
        log.info("Preparing {table}".format(table=name))
        self.name = name
        self.conn = conn
        self.vars = []
        self.vars_type = {}
        self.data = defaultdict(list)
        log.debug("Loading variables")
        for var, typename in self.conn.execute('SELECT name, type FROM MetaDataVariables WHERE data_name=?', (self.name,)):
            data_name = name + "." + var
            if data_to_export and data_name not in data_to_export:
                continue
            if var == "time" and var == "timecode":
                continue
            self.vars.append(var)
            self.vars_type[var] = typename

        # No data? Return
        if not self.vars:
            return

        log.debug("Loading timecodes")
        for timecode, in self.conn.execute('SELECT timecode FROM "data_{table}"'.format(table=self.name)):
            # if timecode > 50:
            #     break
            if self.is_timecode_valid(timecode):
                self.timecodes.append(timecode)

        for var in self.vars:
            req = 'SELECT timecode, "{var}" FROM "data_{table}"'.format(var=var, table=self.name)
            for timecode, data in self.conn.execute(req):
                if self.is_timecode_valid(timecode):
                    self.data[var].append(data)

        self._init_timecodes()

    @staticmethod
    def get_type_params(bind_type):
        if bind_type == "REAL":
            return "0x8000000000000004,,,16,1", "tabbed_text"
        elif bind_type == "TEXT":
            return "0x8000000000000008,,,16,258", "txt"

    @staticmethod
    def is_timecode_valid(timecode):
        return timecode != ""

    def format_data_at_time_child(self, t):
        rows = ""
        init = ""
        for var in self.vars:
            var_rtmaps = var.replace("%", "")
            data = self.data[var][self.count]
            rows += self._rec_value.format(timecode=t, source=self.name, name=var_rtmaps, count=self.count, value=data)
            if self.count == 0:
                type_param, type_name = self.get_type_params(self.vars_type[var])
                init += self._rec_init.format(timecode=t,
                                              source=self.name,
                                              name=var_rtmaps,
                                              type_param=type_param,
                                              type_name=type_name)
        return rows, init


class BindSituation(BindData):
    """
    A BIND situation table to be exported as continuous data
    """

    def __init__(self, name, conn):
        BindData.__init__(self)
        self._rec_value = "{timecode} / {source}.{name}#{count}@{timecode}={value}\n"
        log.info("Preparing {table}".format(table=name))
        self.name = name
        self.conn = conn
        self.situations = {}

        req = 'SELECT startTimecode, endTimecode, Modalities FROM "situation_{table}"'.format(table=self.name)
        end_time = None
        for start_timecode, end_timecode, modality in self.conn.execute(req):
            end_time = end_timecode
            self.situations[start_timecode] = modality

        if end_time is not None:
            self.timecodes = [x / 1000 for x in range(0, int(end_time * 1000), 100)]

        self._init_timecodes()


def convert_trip_to_rec(trip_dir, trip_file, rec_dir, export_video, data_to_export):
    """
    Converts the given *.trip file into an RTMaps *.rec file.

    This implies reencoding the video, writing the *.rec and *.idy file and regenerating the index
    file.

    Returns the created *.rec file
    """
    log.info("Converting {trip}".format(trip=trip_file))
    rec_name = os.path.splitext(trip_file)[0]
    c = sqlite3.connect(os.path.join(trip_dir, trip_file))
    # Getting all tables
    datas = []
    timecodes = []

    if export_video:
        log.debug("Loading video data")
        for video, offset, in c.execute('SELECT filename, offset FROM MetaTripVideos'):
            v = BindVideo(os.path.join(trip_dir, video), offset, rec_name, rec_dir)
            datas.append(v)
            timecodes += v.timecodes
        
    # Test if conversion already happened. This is done after video as a workaround to allow video
    # re-encoding whether or not the trip was already converted
    rec_file = os.path.join(rec_dir, rec_name + ".rec")
    idy_file = os.path.join(rec_dir, rec_name + ".idy")
    if os.path.exists(idy_file):
        log.info("Trip already converted, skipping")
        return rec_file
    
    log.info("Preparing all tables")
    for table_name, in c.execute('SELECT name FROM MetaDatas'):
        table = BindTable(table_name, c, data_to_export)
        datas.append(table)
        timecodes += table.timecodes

    log.info("All tables prepared, sorting timestamps")
    # Removing duplicate timecodes
    timecodes = list(set(timecodes))
    # timecodes_count = len(timecodes)
    timecodes.sort()

    log.info("Starting to write to file")
    idy = REC_HEADER.replace("Data", "Misc")
    with open(rec_file, "w") as rec:
        rec.write(REC_HEADER)
        for i, timecode in enumerate(timecodes):
            # if i % 1000 == 0:
                # print("\r{progress:.3}%".format(progress=100 * i / timecodes_count), end="")
            for d in datas:
                rows, inits = d.format_row_at_time(timecode)
                if rows != "":
                    rec.write(rows)
                if inits != "":
                    rec.write(inits)
                    idy += inits
    with open(idy_file, "w") as f_idy:
        f_idy.write(idy)
    
    regenerate_idx(rec_file)
    
    return rec_file


def regenerate_idx(rec_file):
    """
    Regenerates the *.idx file associated to the given *.rec file
    """
    idx_file = rec_file[:-4] + ".idx"
    file_name = os.path.basename(idx_file)
    if os.path.exists(idx_file) and os.path.getsize(idx_file) > 10000:
        log.debug("Idx file " + file_name + " already exists")
        return
    log.info("Regenerating " + file_name)
    h = subprocess.Popen(["IdxRegeneratorCLI.exe", rec_file])
    h.wait()


def main():
    log.basicConfig(format=LOG_FORMAT, level=log.INFO)
    parser = argparse.ArgumentParser(description='Converts BIND *.trip files to RTMaps *.rec files.')
    parser.add_argument('-i', '--input', type=str, help='Input folder where *.trip files are', required=True)
    parser.add_argument('-o', '--output', type=str, help='Output folder where *.rec files will be created',
                        required=True)
    parser.add_argument('-v', '--video', action='store_true', default=False, help='Export video alongside *.trip data')
    parser.add_argument('-t', '--trips', nargs='+', help='Only converts those trips. '
                                                         'If not present, all trips are converted')
    parser.add_argument('-d', '--data', nargs='+', help='All data to be converted, in the form of "table.column". '
                                                        'If not present, everything is converted')

    args = parser.parse_args()

    # I'm such a nice guy, I leave 2 cores for other people
    pool = Pool(cpu_count() - 2)
    for f in os.listdir(args.input):
        if args.trips and f not in args.trips:
            continue
        if f.endswith(".trip"):
            dir_rec = os.path.join(args.output, os.path.splitext(f)[0])
            try:
                os.makedirs(dir_rec)
            except OSError:
                pass
            convert_trip_to_rec(args.input, f, dir_rec, args.video, args.data)
            # pool.apply_async(convert_trip_to_rec, (dir_trip, f, dir_rec))
            # rec_file = os.path.join(dir_rec, os.path.splitext(f)[0] + ".rec")
            # regenerate_idx(rec_file)
            # pool.apply_async(regenerate_idx, (rec_file,))
    pool.close()
    pool.join()

    
if __name__ == '__main__':
    main()