import os
import shutil
import logging as log

log.basicConfig(format='%(asctime)-15s (PID %(process)-5d) [%(levelname)-8s]: %(message)s', level=log.DEBUG,
                     filename='sort_raw_video.log')

# Reference directory
SORTED_DIR = r"\\vrlescot\MADISON\DATA"

# Current raw video location
RAW_VID_DIR = r"F:\MADISON\DATA\IDSCAM\IDSCAM_DROITE_image_out"
# RAW_VID_DIR = r"D:\derollepot\Desktop\TEST\DATA\IDSCAM\IDSCAM_DROITE_image_out"

# New arborescence location
DEST_DIR = r"F:\MADISON\DATA"
# DEST_DIR = r"D:\derollepot\Desktop\TEST\DATA"

# Link record_date, participant name and scenario in a dict
id_P_and_S = dict()

# Exploring the reference directory, and storing the participant and scenario
for root, dirs, files in os.walk(SORTED_DIR):
    if "~" in root.lower():
        continue
    if "a trier" in root.lower():
        continue
    if "logs" in root.lower():
        continue
    if "rtmaps" not in root:
        continue
    for d in dirs:
        if not d.endswith("_RecFile_REC"):
            continue
        rec_folder = os.path.join(root, d)

        # Gather info
        record_date = d[:15]
        split_path = os.path.normpath(rec_folder).split(os.sep)
        scenario: str = split_path[-2]
        participant: str = split_path[-4]

        if not participant.startswith('P'):
            log.debug(f"Surprising participant with {rec_folder}")
            continue

        if record_date not in id_P_and_S.keys():
            id_P_and_S[record_date] = (participant, scenario)
        else:
            log.debug(f"Two identical record_date corresponding to {id_P_and_S[record_date][0]}|{id_P_and_S[record_date][1]} and {participant}|{scenario}")

# Exploring the raw videos
for root, dirs, files in os.walk(RAW_VID_DIR):
    for f in files:
        if f.startswith('RecFile_REC_'):
            record_date = f[12:27]

            if record_date in id_P_and_S.keys():
                participant, scenario = id_P_and_S[record_date]

                target_dir = os.path.join(DEST_DIR, participant, scenario)

                if not os.path.exists(target_dir):
                    os.makedirs(target_dir)

                try:
                    shutil.move(os.path.join(root, f), os.path.join(target_dir, f))
                except:
                    log.error(f"Failed to move {os.path.join(root, f)} to {os.path.join(target_dir, f)}")
            else:
                # This raw video is not pertinent
                continue
