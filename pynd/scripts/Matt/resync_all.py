"""
This script splits all raw quadravision video files by scenarios and resync them with simulation data (more or less...)
"""
import os
import cv2
import numpy as np
import logging as log
import pickle
from PIL import Image, ImageOps
import pytesseract
from datetime import datetime
from typing import List, Tuple
import subprocess
import traceback
import shutil

from dirs import DIR_DATA_SPLIT, DIR_DATA_VIDEO_QUADRA, DIR_DOC, DIR_RAW_VIDEO
from utils import read_csv_line, str2time, load_structured_csv, sort_by
from merge_sub_subjects import SubjectAggregate, SUBJECT_FOLDER_PREFIX
from mutiprocessing_log import LoggingPool


class OCRException(Exception):
    pass


class TesseractException(OCRException):
    pass


class ScenarioSync:
    """
    Class that holds timecodes data for a scenario sycnrhonization
    """

    def __init__(self, subject: str, scenario: str, real_time: datetime, video_time: float, video_frame: int):
        self.subject = subject
        self.scenario: str = scenario
        self.real_time: datetime = real_time
        self.video_time: float = video_time
        self.video_frame: int = video_frame

    def video_time_hh_mm_ss(self):
        """
        Converts the video time to an FFmpeg compatible format
        """
        s, ms = divmod(self.video_time, 1000)
        m, s = divmod(s, 60)
        h, m = divmod(m, 60)
        return f"{int(h):02d}:{int(m):02d}:{int(s):02d}.{int(ms):03d}"

    def video_time_s(self):
        return self.video_time / 1000.


class VideoSplitter:
    def __init__(self, subjects: List[str]):
        self._main_subject = subjects[0]
        self._video_dir = os.path.join(DIR_RAW_VIDEO, self._main_subject)
        # Path where to store scenarios timecodes
        self._sce_times_bck_path = os.path.join(DIR_DATA_VIDEO_QUADRA, f'{self._main_subject}.pickle')
        self._scenarios_time: List[Tuple[str, str, datetime]] = []
        self._load_scenarios_time(subjects)

    def _load_scenarios_time(self, subjects: List[str]):
        for subject in subjects:
            subject_path = os.path.join(DIR_DATA_SPLIT, SUBJECT_FOLDER_PREFIX + subject)
            # Some subjects path actually don't exist and it's normal
            if not os.path.exists(subject_path):
                continue
            for scenario in os.listdir(subject_path):
                subject_file = os.path.join(subject_path, scenario, "sujet.csv")
                for l in read_csv_line(subject_file):
                    # Using raw scenario name instead of the cleared one since we actually need all scenarios, including
                    # invalids, to cut at the right times
                    self._scenarios_time.append((subject, scenario, str2time(l[2])))

    @staticmethod
    def _extract_time_from_frame(frame):
        """
        Given a frame from the quadravision video, returns the time displayed if visible/readable or None
        :param frame: 
        :return: 
        """
        crop = frame[421:458, 385:565]
        # Tests indicate that black average is ~20, and when time is visible it's ~80, and expanded window (ie.
        # invisible time) is 240
        if not 50. < np.mean(crop) < 150.:
            return None
        # Transform to b&w
        bw = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
        # Binary threshold to clarify
        _, bw = cv2.threshold(bw, 100, 255, cv2.THRESH_BINARY)
        # Removing signs ([/:])
        bw[:, 23:28] = 0
        bw[:, 46:50] = 0
        bw[:, 109:113] = 0
        bw[:, 131:135] = 0
        bw[:, 154:158] = 0
        h, w = bw.shape
        # Clearly separating numbers
        bw = np.insert(bw, 167, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 156, values=np.zeros((5, h)), axis=1)
        bw = np.insert(bw, 145, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 133, values=np.zeros((5, h)), axis=1)
        bw = np.insert(bw, 122, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 109, values=np.zeros((5, h)), axis=1)
        bw = np.insert(bw, 100, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 87, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 76, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 69, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 59, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 46, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 37, values=np.zeros((10, h)), axis=1)
        bw = np.insert(bw, 25, values=np.zeros((5, h)), axis=1)
        bw = np.insert(bw, 14, values=np.zeros((10, h)), axis=1)
        # Convert from Numpy array to PIL Image
        img = ImageOps.invert(Image.fromarray(bw))
        # Tesseract it
        txt = pytesseract.image_to_string(img, config='-psm 6 digits')
        # Removing potential blanks spotted by Tesseract
        txt = txt.replace(" ", "")
        # Ensuring that Tesseract found the right number of chars
        if len(txt) != 16:
            raise TesseractException("Tesseract didn't detect the right amount of characters")
        try:
            t = datetime.strptime(txt, "%d%m%Y%H%M%S%f")
        except ValueError:
            # img.save("error_{t}.jpg".format(t=txt))
            # print("Read {txt} before crash".format(txt=txt))
            raise TesseractException("Tesseract character sequence couldn't be converted to time")
        else:
            # img.save("{t}.tiff".format(t=t.strftime("%Y.%m.%d - %Hh%Mm%S.%f")))
            return t

    @staticmethod
    def is_screen_frozen(frame):
        """
        Returns whether the main screen is in a scenario freeze or not
        :param frame: 
        :return: 
        """
        crop = frame[73:143, 475:590]
        # Tests indicate that black average is ~80, and when time is visible it's ~180
        if np.mean(crop) < 130:
            return True

    @staticmethod
    def _cleanup_time_sequence(time_sequence: List[Tuple[datetime, float, int]]) -> List[Tuple[datetime, float, int]]:
        """
        Cleans up the time match sequence by fixing improper read by Tesseract.
        
        To do that, we gather real times that are close between in others, and assume that the biggest gathering
        is the right one. We then fill in the gaps.
        :param time_sequence: 
        :return: 
        """
        cleaned_sequence: List[Tuple[datetime, float, int]] = []
        # List composed of the different gatherings
        split_sequences: List[List[Tuple[datetime, float, int]]] = []
        for real_time, video_time, video_frame in time_sequence:
            # No gathering created? Initialize
            if not split_sequences:
                split_sequences.append([(real_time, video_time, video_frame)])
                continue

            # We check against the last data in all gatherings to find the closest one
            matching_seq_id = None
            for i, seq in enumerate(split_sequences):
                seq_real_time, seq_video_time, _ = seq[-1]

                # If real time is before last time, it's an obvious nogo
                if real_time < seq_real_time:
                    continue

                video_time_offset = (video_time - seq_video_time) / 1000
                real_time_offset = (real_time - seq_real_time).total_seconds()

                # Check that real time offset is fairly close to video time offset
                if (real_time_offset < 0.2) or (real_time_offset < video_time_offset * 2):
                    matching_seq_id = i
                    break

            if matching_seq_id is not None:
                split_sequences[matching_seq_id].append((real_time, video_time, video_frame))
            else:
                split_sequences.append([(real_time, video_time, video_frame)])

        # Finding the longest subsequence
        for s in split_sequences:
            if len(s) > len(cleaned_sequence):
                cleaned_sequence = s

        return cleaned_sequence

    def _get_scenario_from_sequence(self, time_sequence: List[Tuple[datetime, float, int]]) -> ScenarioSync:
        """
        Returns the scenario that started around the time in the time sequence.
        :param time_sequence: 
        :return: 
        """
        real_time, video_time, video_frame = time_sequence[0]
        for subject, scenario, t in self._scenarios_time:
            # Scenario started less than X seconds from the first time in the sequence
            dt = real_time - t
            dt_s = dt.total_seconds()
            if abs(dt_s) < 2:
                return ScenarioSync(subject, scenario, real_time, video_time, video_frame)

    def _process_video(self, video_path) -> List[ScenarioSync]:
        log.info(f"Processing {video_path}")
        try:
            # All unchecked syncs in a single sequence when time is displayed on screen
            read_time_sequence: List[Tuple[datetime, float, int]] = []
            scenarios_sync: List[ScenarioSync] = []
            cap = cv2.VideoCapture(video_path)

            while cap.isOpened():
                ret, frame = cap.read()
                if frame is None:
                    break

                try:
                    real_time = self._extract_time_from_frame(frame)
                except TesseractException:
                    # If Tesseract failed it's not really an issue,
                    continue
                else:
                    if real_time is None:
                        if not read_time_sequence:
                            continue
                        else:
                            cleaned_sequence = self._cleanup_time_sequence(read_time_sequence)
                            r = self._get_scenario_from_sequence(cleaned_sequence)
                            if r:
                                scenarios_sync.append(r)
                                log.info(f"Subject {self._main_subject} had scenario {r.scenario:45} starts at "
                                         f"{r.real_time} (video time: {r.video_time/1000:10.3f}s)")
                            else:
                                log.debug(f"Couldn't find matching scenario "
                                          f"for subject {self._main_subject} at time {cleaned_sequence[0][0]}")
                            read_time_sequence = []
                    else:
                        video_time = cap.get(cv2.CAP_PROP_POS_MSEC)
                        video_frame = int(cap.get(cv2.CAP_PROP_POS_FRAMES))
                        read_time_sequence.append((real_time, video_time, video_frame))
            cap.release()

            return scenarios_sync
        except:
            log.error(f"Failed while reading {video_path}")
            log.error(traceback.format_exc())
            raise

    def _get_videos_scenarios(self, videos: List[str]) -> List[List[ScenarioSync]]:
        with LoggingPool().make_pool() as pool:
            scenarios_sync = pool.map(self._process_video, videos)

        # Backuping results
        with open(self._sce_times_bck_path, 'wb') as f:
            pickle.dump(scenarios_sync, f, pickle.HIGHEST_PROTOCOL)

        return scenarios_sync

    @staticmethod
    def _get_video_frame_offset_from_audio(video: str) -> float:
        """
        Returns the time offset in seconds between the first sound frame and the first video frame in the file.
        :param video: 
        :return: 
        """
        h = subprocess.Popen(['ffprobe', '-show_frames', video], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        first_timestamp = None
        video_timestamp = None
        current_media = None
        while True:
            line = h.stdout.readline().decode("utf-8")
            if line.startswith('media_type'):
                current_media = line.strip().split('=')[1]
            if line.startswith('pkt_pts_time'):
                timestamp = float(line.split('=')[1])
                if current_media == 'audio' and first_timestamp is None:
                    first_timestamp = timestamp
                if current_media == 'video':
                    video_timestamp = timestamp
                    break
        h.kill()
        return video_timestamp - first_timestamp

    def _split_videos_scenarios(self, videos: List[str], scenarios_sync: List[List[ScenarioSync]],
                                overwrite:bool) -> None:
        vid_count = len(scenarios_sync)

        with LoggingPool().make_pool() as pool:
            i = 0
            total_sce = sum([len(x) for x in scenarios_sync])
            # For each videos
            for i_vid, (video_path, syncs) in enumerate(zip(videos, scenarios_sync)):
                # Some videos have audio before video. That's an issue, because OpenCV considers initial timecode (0)
                # at the first image, whereas FFmpeg considers it at the first frame, whether it's image or audio. So
                # if the first image is 500ms after the first audio frame, OpenCV will consider its timecode 0 and
                # FFmpeg 0.5s.
                # This is problematic since OpenCV is used to find the time to cut but FFmpeg performs the cutting. This
                # leads to an offset in the cut video.
                video_offset = self._get_video_frame_offset_from_audio(video_path)
                sce_count = len(syncs)

                # For each scenario
                for i_sync, sync in enumerate(syncs):
                    t = sync.real_time.strftime("%Y.%m.%d-%Hh%Mm%Ss%f")
                    dst_dir = os.path.join(DIR_DATA_VIDEO_QUADRA, sync.subject, sync.scenario)
                    dst_file = os.path.join(dst_dir, f"quadra_{t}.avi")
                    try:
                        os.makedirs(dst_dir)
                    except OSError:
                        pass

                    sce_start = sync.video_time_s() + video_offset
                    if i_sync < sce_count - 1:
                        # The whole scenario is within the file, simply cut it
                        next_sync = syncs[i_sync+1]
                        sce_end = next_sync.video_time_s() + video_offset
                        cmd = ['-i', video_path,
                               '-filter_complex',
                               f'[0:v] select=between(t\,{sce_start}\,{sce_end}), '
                               f'setpts=(PTS-STARTPTS) [v];'
                               f'[0:a] aselect=between(t\,{sce_start}\,{sce_end}), '
                               f'asetpts=(PTS-STARTPTS) [a]',
                               '-map', '[v]',
                               '-map', '[a]',
                               ]
                    elif i_vid < vid_count - 1:
                        # The scenario is the last one of this video and spreads over the next one: concatenate
                        next_video = videos[i_vid+1]
                        next_syncs: List[ScenarioSync] = scenarios_sync[i_vid+1]
                        if next_syncs:
                            # There is at least one scenario in the next video, so we cut to it
                            next_sync = next_syncs[0]
                            sce_end = next_sync.video_time_s() + video_offset
                            cmd = ['-i', video_path,
                                   '-i', os.path.join(self._video_dir, next_video),
                                   '-filter_complex',
                                   f'[0:v] select=gte(t\,{sce_start}), setpts=(PTS-STARTPTS) [av];'
                                   f'[0:a] aselect=gte(t\,{sce_start}), asetpts=(PTS-STARTPTS) [aa];'
                                   f'[1:v] select=lte(t\,{sce_end}), setpts=(PTS-STARTPTS) [bv];'
                                   f'[1:a] aselect=lte(t\,{sce_end}), asetpts=(PTS-STARTPTS) [ba];'
                                   '[av][aa][bv][ba] concat=n=2:v=1:a=1 [v][a]',
                                   '-map', '[v]',
                                   '-map', '[a]',
                                   ]
                        else:
                            # The next video doesn't have a single scenario, so we concatenate it all
                            cmd = ['-i', video_path,
                                   '-i', os.path.join(self._video_dir, next_video),
                                   '-filter_complex',
                                   f'[0:v] select=gte(t\,{sce_start}), setpts=(PTS-STARTPTS) [av];'
                                   f'[0:a] aselect=gte(t\,{sce_start}), asetpts=(PTS-STARTPTS) [aa];'
                                   '[av][aa][1:v][1:a] concat=n=2:v=1:a=1 [v][a]',
                                   '-map', '[v]',
                                   '-map', '[a]',
                                   ]
                    else:
                        # The scenario is the last one of this video, which is the last video: cut until end
                        cmd = ['-i', video_path,
                               '-filter_complex',
                               f'[0:v] select=gte(t\,{sce_start}), setpts=(PTS-STARTPTS) [v];'
                               f'[0:a] aselect=gte(t\,{sce_start}), asetpts=(PTS-STARTPTS) [a]',
                               '-map', '[v]',
                               '-map', '[a]',
                               ]

                    # Building final command line
                    yn = '-y' if overwrite else '-n'
                    cmd = ['ffmpeg', yn] + cmd + ['-c:v', 'mjpeg', '-q:v', '2', '-c:a', 'ac3', dst_file]
                    i += 1
                    pool.apply_async(self._popen, (cmd, f"Cutting {sync.scenario:45} "
                                                        f"for subject {sync.subject} [{self._main_subject}] "
                                                        f"({i}/{total_sce})"))
            pool.close()
            pool.join()

    @staticmethod
    def _popen(cmd, logmsg=None):
        if logmsg:
            log.info(logmsg)
        try:
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).wait()
        except:
            log.error(f"Failed while exeucting {cmd}")
            log.error(traceback.format_exc())
            raise

    def process(self, use_pickle=False, overwrite=True):
        videos = [os.path.join(self._video_dir, f) for f in os.listdir(self._video_dir) if f.endswith('.mpg')]
        if use_pickle and os.path.exists(self._sce_times_bck_path):
            with open(self._sce_times_bck_path, 'rb') as f:
                scenarios_sync = pickle.load(f)
        else:
            scenarios_sync = self._get_videos_scenarios(videos)
        self._split_videos_scenarios(videos, scenarios_sync, overwrite)


def main():
    # log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO)
    with LoggingPool('%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO, filename='resync.log') as _:
        # Getting all subjects sub ids as it's needed to parse video files
        subjects_path = os.path.join(DIR_DOC, "Subject_number_clarification.csv")
        subjects_ids = sort_by(list(load_structured_csv(subjects_path, SubjectAggregate, has_header=True, delim=",")),
                               "id")
        for d in os.listdir(DIR_RAW_VIDEO):
            subject_path = os.path.join(DIR_RAW_VIDEO, d)
            if not os.path.isdir(subject_path):
                continue
            subjects = [d] + subjects_ids[d].add_ids
            splitter = VideoSplitter(subjects)
            splitter.process(use_pickle=True, overwrite=False)

        # Issue with raw data: subjet 4574 did both EvtRoute90_LCB_B1_Long_Alt and EvtRoute90_2_LCB_B1_Long_Alt
        # However, only the second one is valid, so we remove the first one.
        shutil.rmtree(os.path.join(DIR_DATA_VIDEO_QUADRA, '4574', 'EvtRoute90_LCB_B1_Long_Alt'))


def debug_user(ids):
    with LoggingPool('%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO, filename='resync.log') as _:
        splitter = VideoSplitter(ids)
        splitter.process(use_pickle=False, overwrite=True)


if __name__ == "__main__":
    # main()
    debug_user(['5940', '4543', '620'])
